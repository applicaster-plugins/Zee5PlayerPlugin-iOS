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
    
    private var client: CISClientProtocol?
    public var videoSessionID: Int32? = NO_SESSION_KEY
    
    private var zeePlayer: Player?
    private var zeePlayerInterface: PlayerInterface?
    public var playerStateManager: CISPlayerStateManagerProtocol?
    
    // Ad Events
    private var zeeAdPlayer: Player?
    private var zeeAdInterface: PlayerInterface?
    private var adSessionId: Int32? = NO_SESSION_KEY
    private var adStateManager: CISPlayerStateManagerProtocol?
    
    
    /**
     Initialize conviva analytics for `Production` mode
     
     - Parameters:
     - customerKey: Unique customer key get it from conviva dashboard.
     
     - Throws: `ZeeErrorAnalytic.withError`
     If unable to initialize the sdk.
     */
    public func initializeConviva(customerKey: String) throws {
        
        let systemInterface = IOSSystemInterfaceFactory.initializeWithSystemInterface()
        let setting = CISSystemSettings()
        setting.logLevel = .LOGLEVEL_NONE
        let systemFactory = CISSystemFactoryCreator.create(withCISSystemInterface: systemInterface, setting: setting)
        do {
            let clientSetting = try CISClientSettingCreator.create(withCustomerKey: customerKey)
            clientSetting.setGatewayUrl("https://\(customerKey).cws.conviva.com")
            self.client = try CISClientCreator.create(withClientSettings: clientSetting, factory: systemFactory)
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
        
        let systemInterface = IOSSystemInterfaceFactory.initializeWithSystemInterface()
        let setting = CISSystemSettings()
        setting.logLevel = .LOGLEVEL_NONE
        let systemFactory = CISSystemFactoryCreator.create(withCISSystemInterface: systemInterface, setting: setting)
        do {
            let clientSetting = try CISClientSettingCreator.create(withCustomerKey: testCustomerKey)
            clientSetting.setGatewayUrl(touchStoneUrl)
            self.client = try CISClientCreator.create(withClientSettings: clientSetting, factory: systemFactory)
        }
        catch {
            throw ZeeErrorAnalytic.withError(message: "Conviva Analytics: Internal error occured - Error: \(error.localizedDescription)")
        }
    }
    
    public func ReportErrorConviva(with ErrorMsg: NSString, Severity:NSInteger) {
    
        if let sessionID = self.videoSessionID
        {
            var ConvivaSeverity = ErrorSeverity.ERROR_WARNING
            
            if Severity == 0 {
                ConvivaSeverity = ErrorSeverity.ERROR_FATAL
            }
            self.client?.reportError(sessionID, errorMessage: ErrorMsg as String, errorSeverity:ConvivaSeverity)
            
       if Severity == 0 {
            cleanupSession()
            cleanupAdSession()
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
        
        let Duration = Int(duration)
        
        let metadata = CISContentMetadata()
        metadata.assetName = assetName
        metadata.viewerId = viewerId
        metadata.applicationName = applicationName
        metadata.streamType = streamType?.lowercased().contains("live") ?? false ? .CONVIVA_STREAM_LIVE : .CONVIVA_STREAM_VOD
        metadata.streamUrl = streamUrl
        metadata.duration = Duration ?? 0
        
        ZeeUtility.utility.console("|****** client: \(String(describing: client)) data: \(metadata) ******|")
        self.videoSessionID = self.client?.createSession(with: metadata)
        ZeeUtility.utility.console("|******** Session Created ********|")
    }
    
    public func updateContentMetadata(with data: NSDictionary) {
        if let sessionID = self.videoSessionID
        {
            let dict: NSMutableDictionary = NSMutableDictionary.init(dictionary: data)
            dict.setValue(AllAnalyticsClass.shared.Age, forKey:"viewerAge")
            dict.setValue(analytics.getGender(), forKey:"viewerGender")
            let metadata = CISContentMetadata()
            metadata.custom = dict
            
            self.client?.updateContentMetadata(sessionID, metadata: metadata)
            ZeeUtility.utility.console("|******** Session Updated ********|")
        }
    }
    
    // Player setup
    public func setupPlayerInterface() {
        if self.client != nil
        {
            self.createPlayerInstance()
            self.createPlayerStateManagerInstance()
            self.createPlayerInterfaceInstance()
            self.assignPlayerToPlayerStateManager()
            self.assignPlayerStateManager()
        }
    }
    
    // Create Player Instance
    private func createPlayerInstance() {
        if self.zeePlayer == nil
        {
            self.zeePlayer = Zee5PlayerPlugin.sharedInstance().player
        }
    }
    
    // Create PlayerStateManager Instance
    private func createPlayerStateManagerInstance()
    {
        if self.playerStateManager == nil
        {
            self.playerStateManager = self.client?.getPlayerStateManager()
        }
    }
    
    // Create Player Interface Instance
    private func createPlayerInterfaceInstance()
    {
        if self.zeePlayerInterface == nil {
            if let stateManager = self.playerStateManager, let player = self.zeePlayer
            {
                self.zeePlayerInterface = PlayerInterface(playerStateManger: stateManager, player: player)
            }
        }
    }
    
    // Assign the Player instance to PlayerStateManager
    private func assignPlayerToPlayerStateManager()
    {
        self.playerStateManager?.setCISIClientMeasureInterface?(self.zeePlayerInterface)
    }
    
    // Attach PlayerStateManager to Conviva session
    private func assignPlayerStateManager() {
        if let sessionID = self.videoSessionID {
            if ((self.playerStateManager != nil) && sessionID != NO_SESSION_KEY) {
                self.client?.attachPlayer(sessionID, playerStateManager: self.playerStateManager)
            }
        }
    }
    
    // Clean up the session
    public func cleanupSession() {
        if var sessionID = self.videoSessionID {
            if sessionID != NO_SESSION_KEY {
                self.client?.cleanupSession(sessionID)
                videoSessionID = NO_SESSION_KEY
                self.zeePlayerInterface = nil
                self.playerStateManager = nil
                self.zeePlayer?.stop()
                self.zeePlayer = nil
            }
        }
    }
    
    public func reportError() {
        if (self.client != nil) {
            if ((self.playerStateManager != nil) && (self.zeePlayerInterface != nil)) {
                //                self.zeePlayerInterface.reportError()
            }
            else {
                if let sessionID = self.videoSessionID {
                    if sessionID != NO_SESSION_KEY {
                        self.client?.reportError(sessionID, errorMessage: "Video start error", errorSeverity: .ERROR_FATAL)
                    }
                }
            }
        }
    }
    
    public func sendCustomEvent() {
        if let sessionID = self.videoSessionID {
            if (self.client != nil && sessionID != NO_SESSION_KEY) {
                let keys = ["test key 1", "test key 2", "test key 3"]
                let values = ["test value1", "test value2", "test value3"]
                let attributes: NSDictionary = [keys : values]
                self.client?.sendCustomEvent(sessionID, eventname: "global event", withAttributes: attributes as Any as? [AnyHashable : Any])
            }
        }
    }
    
    // Player State can be reported as following. It must be done when player reports a state change event
     public func reportPlayerState(currentState: PlayerState) {
        
        if self.playerStateManager != nil {
            var state: PlayerState = .CONVIVA_UNKNOWN
            switch currentState {
            case .CONVIVA_BUFFERING:
                ZeeUtility.utility.console(".CONVIVA_BUFFERING")
                state = .CONVIVA_BUFFERING
            case .CONVIVA_STOPPED:
                ZeeUtility.utility.console(".CONVIVA_STOPPED")
                state = .CONVIVA_STOPPED
            case .CONVIVA_PLAYING:
                ZeeUtility.utility.console(".CONVIVA_PLAYING")
                state = .CONVIVA_PLAYING
            case .CONVIVA_PAUSED:
                ZeeUtility.utility.console(".CONVIVA_PAUSED")
                state = .CONVIVA_PAUSED
            case .CONVIVA_NOT_MONITORED:
                ZeeUtility.utility.console(".CONVIVA_NOT_MONITORED")
                state = .CONVIVA_NOT_MONITORED
            case .CONVIVA_UNKNOWN:
                ZeeUtility.utility.console(".CONVIVA_UNKNOWN")
                state = .CONVIVA_UNKNOWN
            @unknown default:
                fatalError()
            }
        
            self.playerStateManager?.setPlayerState?(state)
        }
    }
    
    // Bitrate can be reported as following. It must be done when player reports a bitrate change event
    public func reportPlayerBitrate(bitrate: Int) {
        if (self.playerStateManager != nil && bitrate > 0) {
            self.playerStateManager?.setBitrateKbps?(bitrate)
        }
    }
}

// MARK:- For Ad Events
extension ConvivaAnalytics {
    
    public func createConvivaAdSession(with data: NSDictionary, tags: NSDictionary) {
        if let sessionId = self.videoSessionID {
            
//            let assetName = data.value(forKey: "assetName") as? String
//            let applicationName = data.value(forKey: "applicationName") as? String
//            let streamType = data.value(forKey: "streamType") as? String
//            let streamUrl = data.value(forKey: "streamUrl") as? String
//            let duration = data.value(forKey: "duration") as? Int
//            let adMetadata = CISContentMetadata()
//            adMetadata.assetName = assetName
//            adMetadata.applicationName = applicationName
//            adMetadata.streamType = streamType?.lowercased().contains("live") ?? false ? .CONVIVA_STREAM_LIVE : .CONVIVA_STREAM_VOD
//            adMetadata.streamUrl = streamUrl
//            adMetadata.duration = duration ?? 1
            //  let dict: NSMutableDictionary = NSMutableDictionary.init(dictionary: tags)
            //  adMetadata.custom = dict
            //  self.adSessionId = self.client?.createAdSession(sessionId, adMetadata: adMetadata)
            
            var adPosition = AdPosition.ADPOSITION_PREROLL
            if ((tags.value(forKey: "c3.ad.position") as? String) == "Mid-roll") {
                adPosition = AdPosition.ADPOSITION_MIDROLL
            }else if ((tags.value(forKey: "c3.ad.position") as? String) == "Post-roll"){
                adPosition = AdPosition.ADPOSITION_POSTROLL
            }
            if let sessionId = self.videoSessionID {
                self.client?.adStart(sessionId, adStream: AdStream.ADSTREAM_SEPARATE, adPlayer: AdPlayer.ADPLAYER_CONTENT, adPosition:adPosition)
            }
           
            ZeeUtility.utility.console("|******** Ad Session Created: \(String(describing: self.adSessionId)) ********|")
        }
    }
    
    public func EndAdSession(){
        if let SessionId = self.videoSessionID {
            self.client?.adEnd(SessionId)
        }
        if self.adStateManager != nil {
                       self.client?.releasePlayerStateManager(self.adStateManager)
                       self.adStateManager = nil
                       
                       ZeeUtility.utility.console("|******** Cleanup Ad Session ********|")
                   }
    }
    
    public func reportAdPlayerState(currentState:PlayerState) {
        
        if self.adStateManager != nil {
            var state: PlayerState = .CONVIVA_UNKNOWN
            switch currentState {
            case .CONVIVA_BUFFERING:
                ZeeUtility.utility.console(".CONVIVA_BUFFERING")
                state = .CONVIVA_BUFFERING
            case .CONVIVA_STOPPED:
                ZeeUtility.utility.console(".CONVIVA_STOPPED")
                state = .CONVIVA_STOPPED
            case .CONVIVA_PLAYING:
                ZeeUtility.utility.console(".CONVIVA_PLAYING")
                state = .CONVIVA_PLAYING
            case .CONVIVA_PAUSED:
                ZeeUtility.utility.console(".CONVIVA_PAUSED")
                state = .CONVIVA_PAUSED
            case .CONVIVA_NOT_MONITORED:
                ZeeUtility.utility.console(".CONVIVA_NOT_MONITORED")
                state = .CONVIVA_NOT_MONITORED
            case .CONVIVA_UNKNOWN:
                ZeeUtility.utility.console(".CONVIVA_UNKNOWN")
                state = .CONVIVA_UNKNOWN
            @unknown default:
                fatalError()
            }
            
            self.adStateManager?.setPlayerState?(state)
        }
    }
    
    public func detachMainVideoPlayer() {
        if let sessionId = self.videoSessionID {
            self.client?.detachPlayer(sessionId)
            ZeeUtility.utility.console("|******** Detach Main Video Player ********|")
        }
    }
    
    public func attachMainVideoPlayer() {
        if let sessionId = self.videoSessionID {
            self.client?.attachPlayer(sessionId, playerStateManager: self.playerStateManager)
            ZeeUtility.utility.console("|******** Attach Main Video Player ********|")
        }
    }
    
    public func setupAdPlayerInterface() {
        if self.client != nil {
           // self.createAdplayerInstance()
            if self.adStateManager == nil {
                self.adStateManager = self.client?.getPlayerStateManager()
                //  Attach player for monitoring Ad session
                if let sessionId = self.videoSessionID {
                    self.client?.attachPlayer(sessionId, playerStateManager: self.adStateManager)
                    ZeeUtility.utility.console("||*** Attach Ad Player: \(sessionId)) ***||")
                }
            }
             //self.createAdPlayerInterfaceInstance()
        }
    }
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
    public func cleanupAdSession() {
        if let sessionId = self.videoSessionID {
            self.client?.cleanupSession(sessionId)
            self.adSessionId = NO_SESSION_KEY
            self.zeeAdPlayer = nil
            self.zeeAdInterface = nil
            
            if self.adStateManager != nil {
                self.client?.releasePlayerStateManager(self.adStateManager)
                self.adStateManager = nil
                ZeeUtility.utility.console("|******** Cleanup Ad Session ********|")
            }
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
