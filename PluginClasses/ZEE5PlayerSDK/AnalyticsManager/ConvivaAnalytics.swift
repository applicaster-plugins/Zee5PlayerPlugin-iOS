//
//  ConvivaAnalytics.swift
//  ZEE5PlayerSDK
//
//  Created by Abbas's Mac Mini on 22/08/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

import Foundation
import ConvivaSDK
import Zee5CoreSDK

public class ConvivaAnalytics: NSObject {
    public static let shared = ConvivaAnalytics()
    public override init() {}
    
    ///**NEW Conviva Integration
    private var zeePlayer: Player?
    var Mainanalytics:CISAnalytics?
    var videoAnalytics:CISVideoAnalytics?
    var adAnalytics:CISAdAnalytics?
    var adSession = false
    
    var backgroundUpdateTask = UIBackgroundTaskIdentifier(rawValue: 0)
    
    /**
     Initialize conviva analytics for `Production` mode
     
     - Parameters:
     - customerKey: Unique customer key get it from conviva dashboard.
     
     - Throws: `ZeeErrorAnalytic.withError`
     If unable to initialize the sdk.
     */
    public func initializeConviva(customerKey: String) throws {
        do {
            let clientSetting = try CISClientSettingCreator.create(withCustomerKey: customerKey)
            clientSetting.setGatewayUrl("https://\(customerKey).cws.conviva.com")
            if  let gatewayUrl = clientSetting.getGatewayUrl() {
                let settings = [CIS_SSDK_SETTINGS_GATEWAY_URL:gatewayUrl,CIS_SSDK_SETTINGS_LOG_LEVEL:NSNumber(value: LogLevel.LOGLEVEL_WARNING.rawValue)] as [String : Any];
                if self.Mainanalytics == nil {
                    self.Mainanalytics = CISAnalyticsCreator.create(withCustomerKey:customerKey,settings:settings);
                }
            }
        }
        catch {
            throw ZeeErrorAnalytic.withError(message: "Conviva Analytics: Internal error occured - Error: \(error.localizedDescription)")
        }
    }
    
    /**
     Initialize conviva analytics only for `Development` mode https://touchstone.conviva.com/instructions
     
     - Parameters:
     - testCustomerKey: Unique test customer key get it touch stone dashbard.
     - gatewayUrl: Unique gateway url for dashboard to logged events.
     
     - Throws: `ZeeError.withError`
     If unable to initialize the sdk.
     */
    public func inititializeConvivaForTesting(testCustomerKey: String, touchStoneUrl: String) throws {
        do {
            let clientSetting = try CISClientSettingCreator.create(withCustomerKey: testCustomerKey)
            clientSetting.setGatewayUrl(touchStoneUrl)
            
            let settings = [CIS_SSDK_SETTINGS_GATEWAY_URL:touchStoneUrl,CIS_SSDK_SETTINGS_LOG_LEVEL:NSNumber(value: LogLevel.LOGLEVEL_WARNING.rawValue)] as [String : Any];
            if self.Mainanalytics == nil {
                self.Mainanalytics = CISAnalyticsCreator.create(withCustomerKey: testCustomerKey,settings:settings);
            }
        }
        catch {
            throw ZeeErrorAnalytic.withError(message: "Conviva Analytics: Internal error occured - Error: \(error.localizedDescription)")
        }
    }
    
    public func ReportErrorConviva(with ErrorMsg: NSString, Severity:NSInteger) {
        if videoAnalytics != nil {
            var ConvivaSeverity = ErrorSeverity.ERROR_WARNING
            
            if Severity == 0 {
                ConvivaSeverity = ErrorSeverity.ERROR_FATAL
            }
            
            self.videoAnalytics?.reportPlaybackError(ErrorMsg as String, errorSeverity: ConvivaSeverity)
            
            if Severity == 0 {
                cleanupSession()
            }
        }
    }
    
    public func createConvivaSession(with data: NSDictionary) {
        let assetName = data.value(forKey: "assetName") as? String
        let applicationName = data.value(forKey: "applicationName") as? String
        let streamType = data.value(forKey: "streamType") as? String
        let streamUrl = data.value(forKey: "streamUrl") as? String
        let duration = data.value(forKey: "duration") as! String
        let viewerId = data.value(forKey: "viewerId") as? String
        let frameworkVersion = data.value(forKey: "playerSdkVersion") as? String
        
        let Duration = Int(duration)
        var contentInfo = [AnyHashable : Any]();
        
        contentInfo[CIS_SSDK_METADATA_ASSET_NAME] = assetName;
        contentInfo[CIS_SSDK_METADATA_IS_LIVE] = streamType?.lowercased().contains("live") ?? false ? true : false;
        contentInfo[CIS_SSDK_METADATA_PLAYER_NAME] = data.value(forKey: "playerName") as? String;
        contentInfo[CIS_SSDK_METADATA_VIEWER_ID] = viewerId;
        //contentInfo[CIS_SSDK_METADATA_DEFAULT_RESOURCE] = "resource";
        contentInfo[CIS_SSDK_METADATA_DURATION] = Duration;
        contentInfo[CIS_SSDK_METADATA_STREAM_URL] = streamUrl;
        contentInfo[CIS_SSDK_PLAYER_FRAMEWORK_NAME] = applicationName;
        contentInfo[CIS_SSDK_PLAYER_FRAMEWORK_VERSION] = frameworkVersion;
        if nil != self.Mainanalytics
        {
            self.videoAnalytics = self.Mainanalytics?.createVideoAnalytics();
            self.videoAnalytics?.reportPlaybackRequested(contentInfo);
            ZeeUtility.utility.console("|******** Session Created ********|")
        }
    }
    
    public func updateContentMetadata(with data: NSDictionary) {
        let dict: NSMutableDictionary = NSMutableDictionary.init(dictionary: data)
        dict.setValue(AllAnalyticsClass.shared.Age, forKey:"viewerAge")
        dict.setValue(analytics.getGender(), forKey:"viewerGender")
        ZeeUtility.utility.console("|******** Session Updated ********|")
        
        var contentInfo = [AnyHashable : Any]()
        contentInfo["tags"] = dict;
        
        if nil != self.videoAnalytics {
            self.videoAnalytics!.setContentInfo(contentInfo);
        }
    }
    
    // Player setup
    public func setupPlayerInterface() {
        self.createPlayerInstance()
        registerBackGroundForeGroundHandler()
    }
    
    //MARK:- New Functions And Method
    
    func endBackgroundTask()   {
        UIApplication.shared.endBackgroundTask(backgroundUpdateTask)
        backgroundUpdateTask = UIBackgroundTaskIdentifier.invalid
    }
    
    func registerBackgroundTask()  {
        backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            
        })
    }
    
    func registerBackGroundForeGroundHandler()  {
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(appStateChangeHandler(_:)),
                                               name:UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(appStateChangeHandler(_:)),
                                               name:UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc func appStateChangeHandler(_ notification : NSNotification) {
        if(notification.name == UIApplication.didEnterBackgroundNotification){
            self.Mainanalytics?.reportAppBackgrounded();
        }
        else {
            self.Mainanalytics?.reportAppForegrounded();
        }
    }
    
    // Create Player Instance
    private func createPlayerInstance() {
        if self.zeePlayer == nil {
            self.zeePlayer = Zee5PlayerPlugin.sharedInstance().player
        }
    }
    
    // Clean up the session
    public func cleanupSession() {
        if nil != self.videoAnalytics {
            self.videoAnalytics!.reportPlaybackEnded();
            self.videoAnalytics!.cleanup();
            self.videoAnalytics = nil;
            adSession = false;
            self.zeePlayer?.stop()
            self.zeePlayer = nil
        }
    }
    
    // Player State can be reported as following. It must be done when player reports a state change event
    public func reportPlayerState(currentState: ZEEConvivaPlayerState.RawValue) {
        if self.videoAnalytics != nil {
            switch currentState {
            case 6:
                ZeeUtility.utility.console(".CONVIVA_BUFFERING")
                self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: NSNumber(integerLiteral:6));
                
            case 1:
                ZeeUtility.utility.console(".CONVIVA_STOPPED")
                self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: NSNumber(integerLiteral:1));
                
            case 3:
                ZeeUtility.utility.console(".CONVIVA_PLAYING")
                self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: NSNumber(integerLiteral:3));
                
            case 12:
                ZeeUtility.utility.console(".CONVIVA_PAUSED")
                self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: NSNumber(integerLiteral:12));
                
            case 98:
                ZeeUtility.utility.console(".CONVIVA_NOT_MONITORED")
                self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: NSNumber(integerLiteral:98));
                
            case 100:
                ZeeUtility.utility.console(".CONVIVA_UNKNOWN")
                self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: NSNumber(integerLiteral:100));
                
            default:
                fatalError()
            }
        }
    }
    
    // Bitrate can be reported as following. It must be done when player reports a bitrate change event
    public func reportPlayerBitrate(bitrate: Int64) {
        if (self.videoAnalytics != nil && bitrate > 0) {
            self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_BITRATE, value:NSNumber(value:bitrate))
        }
    }
    
    // Seek Start time Of  Player
    public func SeekStarted(SeekStart: Int64) {
        if (self.videoAnalytics != nil && SeekStart > 0) {
            self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_SEEK_STARTED, value:NSNumber(integerLiteral: Int(SeekStart)))
        }
    }
    
    // Seek Start time Of  Player
    public func SeekEnded(SeekEnd: Int64) {
        if (self.videoAnalytics != nil && SeekEnd > 0) {
            self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_SEEK_ENDED, value:NSNumber(integerLiteral: Int(SeekEnd)))
        }
    }
    // User Wait for PlayBack
    public func userWaitPlayback(Event: convivaUserWait) {
        if (self.videoAnalytics != nil) {
            switch Event {
            case userWaitStarted:
                let event = CISConstants.getEventsStringValue(.USER_WAIT_STARTED)!;
                self.videoAnalytics?.reportPlaybackEvent(event, withAttributes: nil)
            case userWaitEnded:
                let event = CISConstants.getEventsStringValue(.USER_WAIT_ENDED)!;
                self.videoAnalytics?.reportPlaybackEvent(event, withAttributes: nil)
            default:
               break
            }
          
        }
    }
}

// MARK:- For Ad Events
extension ConvivaAnalytics {
    public func createConvivaAdSession(with data: NSDictionary, tags: NSDictionary) {
        if let _ = self.videoAnalytics {
            var adPosition = AdPosition.ADPOSITION_PREROLL
            if ((tags.value(forKey: "c3.ad.position") as? String) == "Mid-roll") {
                adPosition = AdPosition.ADPOSITION_MIDROLL
            }
            else if ((tags.value(forKey: "c3.ad.position") as? String) == "Post-roll") {
                adPosition = AdPosition.ADPOSITION_POSTROLL
            }
            
            var adAttributes = [AnyHashable:Any]();
            adAttributes["podDuration"] = data.value(forKey: "duration") as? Int;
            adAttributes["podPosition"] = CISConstants.getAdPositionStringValue(adPosition);
            if adSession == false {
                adSession = true
                self.videoAnalytics?.reportAdBreakStarted(.ADPLAYER_CONTENT, adType: .CLIENT_SIDE, adBreakInfo: adAttributes)
                ZeeUtility.utility.console("|******** Ad Session Created********|")
            }
        }
    }
    
    public func EndAdSession() {
        if nil != videoAnalytics {
            adSession = false
            self.videoAnalytics!.reportAdBreakEnded();
            ZeeUtility.utility.console("|******** Cleanup Ad Session ********|")
        }
    }
}

class PlayerInterface: NSObject, CISIClientMeasureInterface {
    let playerStateManger: CISPlayerStateManagerProtocol?
    let player: Player?
    
    init(playerStateManger: CISPlayerStateManagerProtocol, player: Player) {
        self.playerStateManger = playerStateManger
        self.player = player
    }
}

public enum ZeeErrorAnalytic: LocalizedError {
    case withError(message: String)
    
    public var errorDescription: String? {
        switch self {
        case .withError(let message):
            return message
        }
    }
}
