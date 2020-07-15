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
    
    //***OLD Method******////
//      private var client: CISClientProtocol?
//      public var videoSessionID: Int32? = NO_SESSION_KEY
//      private var zeePlayerInterface: PlayerInterface?
//      public var playerStateManager: CISPlayerStateManagerProtocol?
//
//    // Ad Events
//      private var zeeAdPlayer: Player?
//      private var zeeAdInterface: PlayerInterface?
//      private var adSessionId: Int32? = NO_SESSION_KEY
//      private var adStateManager: CISPlayerStateManagerProtocol?
    


    
  
    
    ///**NEW Conviva Integration
     private var zeePlayer: Player?
     var Mainanalytics:CISAnalytics?
     var videoAnalytics:CISVideoAnalytics?
     var adAnalytics:CISAdAnalytics?
    var backgroundUpdateTask = UIBackgroundTaskIdentifier(rawValue: 0)
    
    /**
     Initialize conviva analytics for `Production` mode
     
     - Parameters:
     - customerKey: Unique customer key get it from conviva dashboard.
     
     - Throws: `ZeeErrorAnalytic.withError`
     If unable to initialize the sdk.
     */
    public func initializeConviva(customerKey: String) throws {
        
//        let systemInterface = IOSSystemInterfaceFactory.initializeWithSystemInterface()
//        let setting = CISSystemSettings()
//        setting.logLevel = .LOGLEVEL_NONE
//        let systemFactory = CISSystemFactoryCreator.create(withCISSystemInterface: systemInterface, setting: setting)
        do {
            let clientSetting = try CISClientSettingCreator.create(withCustomerKey: customerKey)
            clientSetting.setGatewayUrl("https://\(customerKey).cws.conviva.com")
          // self.client = try CISClientCreator.create(withClientSettings: clientSetting, factory: systemFactory)
            self.Mainanalytics = CISAnalyticsCreator.create(withCustomerKey: customerKey)
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
        
//        let systemInterface = IOSSystemInterfaceFactory.initializeWithSystemInterface()
//        let setting = CISSystemSettings()
//        setting.logLevel = .LOGLEVEL_NONE
//        let systemFactory = CISSystemFactoryCreator.create(withCISSystemInterface: systemInterface, setting: setting)
        do {
            let clientSetting = try CISClientSettingCreator.create(withCustomerKey: testCustomerKey)
            clientSetting.setGatewayUrl(touchStoneUrl)
           // self.client = try CISClientCreator.create(withClientSettings: clientSetting, factory: systemFactory)
                  let settings = [CIS_SSDK_SETTINGS_GATEWAY_URL:touchStoneUrl,CIS_SSDK_SETTINGS_LOG_LEVEL:NSNumber(value: LogLevel.LOGLEVEL_WARNING.rawValue)] as [String : Any];
            self.Mainanalytics = CISAnalyticsCreator.create(withCustomerKey: testCustomerKey,settings:settings);
        }
        catch {
            throw ZeeErrorAnalytic.withError(message: "Conviva Analytics: Internal error occured - Error: \(error.localizedDescription)")
        }
    }
    
    public func ReportErrorConviva(with ErrorMsg: NSString, Severity:NSInteger) {
    
        if videoAnalytics != nil
        {
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
//
//        let metadata = CISContentMetadata()
//        metadata.assetName = assetName
//        metadata.viewerId = viewerId
//        metadata.applicationName = applicationName
//        metadata.streamType = streamType?.lowercased().contains("live") ?? false ? .CONVIVA_STREAM_LIVE : .CONVIVA_STREAM_VOD
//        metadata.streamUrl = streamUrl
//        metadata.duration = Duration ?? 0
//
//        ZeeUtility.utility.console("|****** client: \(String(describing: client)) data: \(metadata) ******|")
//        self.videoSessionID = self.client?.createSession(with: metadata)
        
              let assetName = data.value(forKey: "assetName") as? String
              let applicationName = data.value(forKey: "applicationName") as? String
              let streamType = data.value(forKey: "streamType") as? String
              let streamUrl = data.value(forKey: "streamUrl") as? String
              let duration = data.value(forKey: "duration") as! String
              let viewerId = data.value(forKey: "viewerId") as? String

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
           // contentInfo[CIS_SSDK_PLAYER_FRAMEWORK_VERSION] = "frameworkversion";
        
        
        if nil != self.Mainanalytics  {
                  self.videoAnalytics = self.Mainanalytics?.createVideoAnalytics();
               self.videoAnalytics?.reportPlaybackRequested(contentInfo);
                ZeeUtility.utility.console("|******** Session Created ********|")
              }
    }
    
    public func updateContentMetadata(with data: NSDictionary) {
//        if let sessionID = self.videoSessionID
//        {
            //           let metadata = CISContentMetadata()
            //            metadata.custom = dict
            // self.client?.updateContentMetadata(sessionID, metadata: metadata)
 //   }
            let dict: NSMutableDictionary = NSMutableDictionary.init(dictionary: data)
            dict.setValue(AllAnalyticsClass.shared.Age, forKey:"viewerAge")
            dict.setValue(analytics.getGender(), forKey:"viewerGender")
            ZeeUtility.utility.console("|******** Session Updated ********|")
            var contentInfo = [AnyHashable : Any]();
             contentInfo["tags"] = dict;
        
               if nil != self.videoAnalytics {
                      self.videoAnalytics!.setContentInfo(contentInfo);
                  }
    }
    
    // Player setup
    public func setupPlayerInterface() {
//        if self.client != nil
//        {
//            self.createPlayerStateManagerInstance()
//            self.createPlayerInterfaceInstance()
//            self.assignPlayerToPlayerStateManager()
//            self.assignPlayerStateManager()
//        }
           self.createPlayerInstance()
           endBackgroundTask()
           registerBackgroundTask()
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
    
    @objc func appStateChangeHandler(_ notification : NSNotification)  {
        if(notification.name == UIApplication.didEnterBackgroundNotification){
              self.Mainanalytics?.reportAppBackgrounded();
          }else{
//              adSessionTasks(adPlayingBeforeBackground)
//              adPlayingBeforeBackground = false
              self.Mainanalytics?.reportAppForegrounded();
              
          }
      }
    
    // Create Player Instance
    private func createPlayerInstance() {
        if self.zeePlayer == nil
        {
            self.zeePlayer = Zee5PlayerPlugin.sharedInstance().player
        }
    }
    // Clean up the session
    public func cleanupSession() {
//        if var sessionID = self.videoSessionID {
//            if sessionID != NO_SESSION_KEY {
//               // videoSessionID = NO_SESSION_KEY
//                self.client?.cleanUp()
//                self.zeePlayerInterface = nil
//                self.playerStateManager = nil
//                self.zeePlayer?.stop()
//                self.zeePlayer = nil
//            }
//        }
        if nil != self.videoAnalytics {
                  self.videoAnalytics!.reportPlaybackEnded();
                  self.videoAnalytics!.cleanup();
                  self.Mainanalytics!.cleanup()
                  self.videoAnalytics = nil;
                  self.zeePlayer?.stop()
                  self.zeePlayer = nil
              }
    }
    
    // Player State can be reported as following. It must be done when player reports a state change event
     public func reportPlayerState(currentState: PlayerState) {
        
//        if self.playerStateManager != nil {
            var state: PlayerState = .CONVIVA_UNKNOWN
            switch currentState {
            case .CONVIVA_BUFFERING:
                ZeeUtility.utility.console(".CONVIVA_BUFFERING")
                state = .CONVIVA_BUFFERING
                self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: NSNumber(integerLiteral: Int(PlayerState.CONVIVA_BUFFERING.rawValue)));
                
            case .CONVIVA_STOPPED:
                ZeeUtility.utility.console(".CONVIVA_STOPPED")
                state = .CONVIVA_STOPPED
                self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: NSNumber(integerLiteral: Int(PlayerState.CONVIVA_STOPPED.rawValue)));
                
            case .CONVIVA_PLAYING:
                ZeeUtility.utility.console(".CONVIVA_PLAYING")
                state = .CONVIVA_PLAYING
                self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: NSNumber(integerLiteral: Int(PlayerState.CONVIVA_PLAYING.rawValue)));
                
            case .CONVIVA_PAUSED:
                ZeeUtility.utility.console(".CONVIVA_PAUSED")
                state = .CONVIVA_PAUSED
                self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: NSNumber(integerLiteral: Int(PlayerState.CONVIVA_PAUSED.rawValue)));
                
            case .CONVIVA_NOT_MONITORED:
                ZeeUtility.utility.console(".CONVIVA_NOT_MONITORED")
                state = .CONVIVA_NOT_MONITORED
                self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: NSNumber(integerLiteral: Int(PlayerState.CONVIVA_NOT_MONITORED.rawValue)));
                
            case .CONVIVA_UNKNOWN:
                ZeeUtility.utility.console(".CONVIVA_UNKNOWN")
                state = .CONVIVA_UNKNOWN
                self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: NSNumber(integerLiteral: Int(PlayerState.CONVIVA_UNKNOWN.rawValue)));
                
            @unknown default:
                fatalError()
            }
        
           // self.playerStateManager?.setPlayerState?(state)
        //}
    }
    
    // Bitrate can be reported as following. It must be done when player reports a bitrate change event
    public func reportPlayerBitrate(bitrate: Int) {
        if (self.videoAnalytics != nil && bitrate > 0) {
            self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_BITRATE, value: bitrate)
        }
    }
    
    // Seek Start time Of  Player
    public func SeekStarted(SeekStart: Int64) {
        if (self.videoAnalytics != nil && SeekStart > 0) {
            self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_SEEK_STARTED, value: SeekStart)
        }
    }
    
    // Seek Start time Of  Player
       public func SeekEnded(SeekEnd: Int64) {
           if (self.videoAnalytics != nil && SeekEnd > 0) {
               self.videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_SEEK_ENDED, value: SeekEnd)
           }
       }
}

// MARK:- For Ad Events
extension ConvivaAnalytics {
    
    public func createConvivaAdSession(with data: NSDictionary, tags: NSDictionary) {
//        if let sessionId = self.videoSessionID {
//
////            let assetName = data.value(forKey: "assetName") as? String
////            let applicationName = data.value(forKey: "applicationName") as? String
////            let streamType = data.value(forKey: "streamType") as? String
////            let streamUrl = data.value(forKey: "streamUrl") as? String
////            let duration = data.value(forKey: "duration") as? Int
////            let adMetadata = CISContentMetadata()
////            adMetadata.assetName = assetName
////            adMetadata.applicationName = applicationName
////            adMetadata.streamType = streamType?.lowercased().contains("live") ?? false ? .CONVIVA_STREAM_LIVE : .CONVIVA_STREAM_VOD
////            adMetadata.streamUrl = streamUrl
////            adMetadata.duration = duration ?? 1
//            //  let dict: NSMutableDictionary = NSMutableDictionary.init(dictionary: tags)
//            //  adMetadata.custom = dict
//            //  self.adSessionId = self.client?.createAdSession(sessionId, adMetadata: adMetadata)
//
//            var adPosition = AdPosition.ADPOSITION_PREROLL
//            if ((tags.value(forKey: "c3.ad.position") as? String) == "Mid-roll") {
//                adPosition = AdPosition.ADPOSITION_MIDROLL
//            }else if ((tags.value(forKey: "c3.ad.position") as? String) == "Post-roll"){
//                adPosition = AdPosition.ADPOSITION_POSTROLL
//            }
//            if let sessionId = self.videoSessionID {
//                self.client?.adStart(sessionId, adStream: AdStream.ADSTREAM_SEPARATE, adPlayer: AdPlayer.ADPLAYER_CONTENT, adPosition:adPosition)
//            }
//        }
          if let _ = self.videoAnalytics {
            
            var adPosition = AdPosition.ADPOSITION_PREROLL
                       if ((tags.value(forKey: "c3.ad.position") as? String) == "Mid-roll") {
                           adPosition = AdPosition.ADPOSITION_MIDROLL
                       }else if ((tags.value(forKey: "c3.ad.position") as? String) == "Post-roll"){
                           adPosition = AdPosition.ADPOSITION_POSTROLL
                       }
            var adAttributes = [AnyHashable:Any]();
                adAttributes["podDuration"] = data.value(forKey: "duration") as? Int;
                adAttributes["podPosition"] = CISConstants.getAdPositionStringValue(adPosition);
                          
                self.videoAnalytics?.reportAdBreakStarted(.ADPLAYER_CONTENT, adType: .CLIENT_SIDE, adBreakInfo: adAttributes)
                 ZeeUtility.utility.console("|******** Ad Session Created********|")
        }
        
    }
    
    public func EndAdSession(){
//        if let SessionId = self.videoSessionID {
//            self.client?.adEnd(SessionId)
//        }
//        if self.adStateManager != nil {
//                       self.client?.releasePlayerStateManager(self.adStateManager)
//                       self.adStateManager = nil
    //}
            if nil != videoAnalytics {
                    self.videoAnalytics!.reportAdBreakEnded();
                    ZeeUtility.utility.console("|******** Cleanup Ad Session ********|")
            }
    }
    
        //MARK:- Create PlayerStateManager Instance(OLD Code Player)
    //    private func createPlayerStateManagerInstance()
    //    {
    //        if self.playerStateManager == nil
    //        {
    //            self.playerStateManager = self.client?.getPlayerStateManager()
    //        }
    //    }
        
        // Create Player Interface Instance
    //    private func createPlayerInterfaceInstance()
    //    {
    //        if self.zeePlayerInterface == nil {
    //            if let stateManager = self.playerStateManager, let player = self.zeePlayer
    //            {
    //                self.zeePlayerInterface = PlayerInterface(playerStateManger: stateManager, player: player)
    //            }
    //        }
    //    }
        
        // Assign the Player instance to PlayerStateManager
    //    private func assignPlayerToPlayerStateManager()
    //    {
    //        self.playerStateManager?.setCISIClientMeasureInterface?(self.zeePlayerInterface)
    //    }
        
        // Attach PlayerStateManager to Conviva session
    //    private func assignPlayerStateManager() {
    //        if let sessionID = self.videoSessionID {
    //            if ((self.playerStateManager != nil) && sessionID != NO_SESSION_KEY) {
    //                self.client?.attachPlayer(sessionID, playerStateManager: self.playerStateManager)
    //            }
    //        }
    //    }
    
    
    //MARK:- Old Conviva Code AD Session
    //    public func reportError() {
    //        if (self.client != nil) {
    //            if ((self.playerStateManager != nil) && (self.zeePlayerInterface != nil)) {
    //                //                self.zeePlayerInterface.reportError()
    //            }
    //            else {
    //                if let sessionID = self.videoSessionID {
    //                    if sessionID != NO_SESSION_KEY {
    //                        self.client?.reportError(sessionID, errorMessage: "Video start error", errorSeverity: .ERROR_FATAL)
    //                    }
    //                }
    //            }
    //        }
    //    }
    
  //  public func reportAdPlayerState(currentState:PlayerState) {
        
//        if self.adStateManager != nil {
//            var state: PlayerState = .CONVIVA_UNKNOWN
//            switch currentState {
//            case .CONVIVA_BUFFERING:
//                ZeeUtility.utility.console(".CONVIVA_BUFFERING")
//                state = .CONVIVA_BUFFERING
//            case .CONVIVA_STOPPED:
//                ZeeUtility.utility.console(".CONVIVA_STOPPED")
//                state = .CONVIVA_STOPPED
//            case .CONVIVA_PLAYING:
//                ZeeUtility.utility.console(".CONVIVA_PLAYING")
//                state = .CONVIVA_PLAYING
//            case .CONVIVA_PAUSED:
//                ZeeUtility.utility.console(".CONVIVA_PAUSED")
//                state = .CONVIVA_PAUSED
//            case .CONVIVA_NOT_MONITORED:
//                ZeeUtility.utility.console(".CONVIVA_NOT_MONITORED")
//                state = .CONVIVA_NOT_MONITORED
//            case .CONVIVA_UNKNOWN:
//                ZeeUtility.utility.console(".CONVIVA_UNKNOWN")
//                state = .CONVIVA_UNKNOWN
//            @unknown default:
//                fatalError()
//            }
//
//            self.adStateManager?.setPlayerState?(state)
//        }
  // }
    
//    public func detachMainVideoPlayer() {
////        if let sessionId = self.videoSessionID {
////            self.client?.detachPlayer(sessionId)
////            ZeeUtility.utility.console("|******** Detach Main Video Player ********|")
////        }
//
//        let event = CISConstants.getEventsStringValue(.USER_WAIT_STARTED);
//            self.videoAnalytics?.reportPlaybackEvent(event!,withAttributes: nil);
//    }

//    public func attachMainVideoPlayer() {
//
////        if self.adStateManager != nil {
////            adStateManager = nil;
////        }
////        if let sessionId = self.videoSessionID {
////            self.client?.attachPlayer(sessionId, playerStateManager: self.playerStateManager)
////            ZeeUtility.utility.console("|******** Attach Main Video Player ********|")
////        }
//
//        if let _ = self.Mainanalytics {
//                  // CREATE PLAYER INSTANCE HERE OR BEFORE
//                  if (zeePlayer == nil){
//                      zeePlayer = Zee5PlayerPlugin.sharedInstance().player
//                  }
//            let event = CISConstants.getEventsStringValue(.USER_WAIT_ENDED)!;
//                  self.videoAnalytics?.reportPlaybackEvent(event,withAttributes: nil);
//              }
//
//    }
    
//    public func setupAdPlayerInterface() {
//        if self.client != nil {
//           // self.createAdplayerInstance()
//            if self.adStateManager == nil {
//               // self.adStateManager = self.client?.getPlayerStateManager()
//                //  Attach player for monitoring Ad session
////                if let sessionId = self.videoSessionID {
////                   self.client?.attachPlayer(sessionId, playerStateManager: self.adStateManager)
////                    ZeeUtility.utility.console("||*** Attach Ad Player: \(sessionId)) ***||")
////                }
//            }
//             //self.createAdPlayerInterfaceInstance()
//        }
//    }
    // Create Player Instance
//    private func createAdplayerInstance() {
//        if self.zeeAdPlayer == nil
//        {
//            self.zeeAdPlayer = Zee5PlayerPlugin.sharedInstance().player
//        }
//    }
//    private func createAdPlayerInterfaceInstance()
//       {
//           if self.zeeAdInterface == nil {
//               if let stateManager = self.adStateManager, let player = self.zeeAdPlayer
//               {
//                self.zeeAdInterface = PlayerInterface(playerStateManger: stateManager, player: player)
//               }
//           }
//       }
//
//    public func cleanupAdSession() {
//        if let sessionId = self.videoSessionID {
//           // self.client?.cleanupSession(sessionId)
//
//            if self.adStateManager != nil {
//                self.client?.releasePlayerStateManager(self.adStateManager)
//                self.adStateManager = nil
//                ZeeUtility.utility.console("|******** Cleanup Ad Session ********|")
//            }
//        }
//    }
    
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
