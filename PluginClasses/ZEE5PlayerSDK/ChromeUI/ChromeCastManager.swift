//
//  ChromeCastManager.swift
//  ZEE5PlayerSDK
//
//  Created by Mani on 16/07/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

import UIKit
import GoogleCast
let kPrefEnableMediaNotifications = "enable_media_notifications"

public protocol ChromeCastDelegate {
    func didSelectMenuOption(with: ChromQueueMenu)
}

public class ChromeCastManager: NSObject {
    
    public static let shared = ChromeCastManager()
    public var delegate: ChromeCastDelegate?
    private let appId = "E05C51D0"
    var CastDeviceName = ""
    
    public var currentSession: GCKSessionManager?
    private var mediaClient: GCKRemoteMediaClient!
    private var addQueue: ChromeAddQueue!
    private var miniControllerView :ChromeMiniControllerView!
    private var enableSDKLogging = true
    
    let bundle = Bundle(for: ChromeCastManager.self)
    
    @objc public func initializeCastOptions() {
        
        let options = GCKCastOptions(receiverApplicationID: self.appId)
        options.suspendSessionsWhenBackgrounded = true
        options.physicalVolumeButtonsWillControlDeviceVolume = true
        GCKCastContext.setSharedInstanceWith(options)
        self.currentSession?.add(self)
        
        
        GCKLogger.sharedInstance().delegate = self
        GCKCastContext.sharedInstance().sessionManager.add(self)
        self.customizeCastManager()
        self.setupCastLogging()
    }
    
    func customizeCastManager() {
        GCKUICastButton.appearance().tintColor = UIColor.gray
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
        
        // Customize connection controller
        let connection = GCKUIStyle.sharedInstance().castViews.deviceControl.connectionController
        connection.playImage = UIImage(named: "playPlayer") ?? UIImage()
        connection.pauseImage = UIImage(named: "pausePlayer") ?? UIImage()
        connection.volumeImage = UIImage(named: "speaker") ?? UIImage()
        connection.skipPreviousImage = UIImage(named: "backwardIcon") ?? UIImage()
        connection.skipPreviousImage = UIImage(named: "forwardIcon") ?? UIImage()
        connection.headingTextFont = UIFont.systemFont(ofSize: 14)
        connection.buttonTextFont = UIFont.systemFont(ofSize: 14)
        connection.headingTextColor = UIColor.white
        connection.buttonTextColor = UIColor.gray
        GCKUIStyle.sharedInstance().castViews.mediaControl.expandedController.iconTintColor = .black
        GCKUIStyle.sharedInstance().castViews.mediaControl.miniController.backgroundColor = UIColor (hex: "2E0130")
        let miniControllerCustomize = GCKUIStyle.sharedInstance().castViews.mediaControl.miniController
        miniControllerCustomize.playImage = UIImage(named: "playPlayer") ?? UIImage()
        miniControllerCustomize.pauseImage = UIImage(named: "pausePlayer") ?? UIImage()
        miniControllerCustomize.headingTextColor = UIColor.white
        miniControllerCustomize.headingTextFont = UIFont.systemFont(ofSize: 14)
    }
    
    func setupCastLogging() {
        let logFilter = GCKLoggerFilter()
        let classesToLog = ["GCKDeviceScanner", "GCKDeviceProvider", "GCKDiscoveryManager", "GCKCastChannel", "GCKMediaControlChannel", "GCKUICastButton", "GCKUIMediaController", "NSMutableDictionary"]
        logFilter.setLoggingLevel(.verbose, forClasses: classesToLog)
        GCKLogger.sharedInstance().filter = logFilter
        GCKLogger.sharedInstance().delegate = self
    }
    
    func closeCurrentSession() {
        self.currentSession?.endSessionAndStopCasting(true)
    }
    
    @objc public func playSelectedItemRemotely() {
        self.loadSelectedItem(byAppending: false, with: nil, token: nil)
        GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()
        AnalyticEngine .shared .castingStartedAnalytics(with:CastDeviceName)
    }
    
    @objc public func playTappedItemRemotely(with data: VODContentDetailsDataModel, token: String){
        self.loadSelectedItem(byAppending: false, with: data, token: token)
        GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()
    }
    
    @objc public func enqueueSelectedItemRemotely(with data: VODContentDetailsDataModel, token: String) {
        self.loadSelectedItem(byAppending: true, with: data, token: token)
    }
    
    func loadSelectedItem(byAppending appending: Bool, with data: VODContentDetailsDataModel?, token: String?) {
        let mediaInfo: GCKMediaInformation!
        if data == nil {
            let customData: NSMutableDictionary = [:]
            customData["licenseCustomData"] = ZEE5PlayerManager.sharedInstance().currentItem.drm_token
            customData["licenseUrl"] = "https://wv-keyos-aps1.licensekeyserver.com"
            mediaInfo = self.getMediaInformation(with: customData)
        }
        else {
            let customData: NSMutableDictionary = [:]
            customData["licenseCustomData"] = token
            customData["licenseUrl"] = "https://wv-keyos-aps1.licensekeyserver.com"
            mediaInfo = self.getVODMediaInformation(with: data, customData: customData)
        }
        if GCKCastContext.sharedInstance().sessionManager.hasConnectedCastSession() {
            if let mediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient {
                let mediaQueue = GCKMediaQueueItemBuilder()
                mediaQueue.mediaInformation = mediaInfo
                mediaQueue.autoplay = true
                let mediaItem = mediaQueue.build()
                if appending {
                    let request = mediaClient.queueInsert(mediaItem, beforeItemWithID: kGCKMediaQueueInvalidItemID)
                    request.delegate = self
                }
                else {
                    let request = mediaClient.loadMedia(mediaInfo, autoplay: true)
                    request.delegate = self
                }
            }
        }
    }
    
    func getMediaInformation(with data: NSMutableDictionary) -> GCKMediaInformation {
        let currentItem = ZEE5PlayerManager.sharedInstance().currentItem
        var metadataType: GCKMediaMetadataType = .generic
        metadataType = currentItem.asset_type.lowercased() == "movie" ? .movie : .tvShow
        
        let str = currentItem.asset_type == "1" ? currentItem.originalTitle : currentItem.asset_subtype
        let metadata = GCKMediaMetadata(metadataType: metadataType)
        metadata.setString(str, forKey: kGCKMetadataKeySubtitle)
        metadata.setString(currentItem.channel_Name, forKey: kGCKMetadataKeyTitle)
        metadata.setString(currentItem.info, forKey: "description")
        metadata.setInteger(Int(currentItem.asset_type) ?? 0, forKey: "assetType")
        metadata.setInteger(currentItem.duration, forKey: "contentLength")
        
        if let url = URL(string: currentItem.imageUrl) {
            metadata.addImage(GCKImage(url: url, width: 480, height: 720))
        }
        return GCKMediaInformation(contentID: currentItem.hls_Url, streamType: .buffered, contentType: "mp4", metadata: metadata, streamDuration: TimeInterval(currentItem.duration), mediaTracks: nil, textTrackStyle: nil, customData: data)
    }
    
    func getVODMediaInformation(with data: VODContentDetailsDataModel?, customData: NSMutableDictionary) -> GCKMediaInformation? {
        guard let data = data else { return nil }
        var metadaType: GCKMediaMetadataType = .generic
        metadaType = data.assetType.lowercased() == "movie" ? .movie : .tvShow
        
        let str = data.assetType == "1" ? data.title : data.assetSubtype
        let metadata = GCKMediaMetadata(metadataType: metadaType)
        metadata.setString(data.title , forKey: kGCKMetadataKeyTitle)
        metadata.setString(str, forKey: kGCKMetadataKeySubtitle)
        metadata.setString(data.contentDescription, forKey: "description")
        metadata.setInteger(Int(data.assetType) ?? 0, forKey: "assetType")
        metadata.setInteger(data.duration, forKey: "contentLength")
        
        if let url = URL(string: data.imageUrl) {
            metadata.addImage(GCKImage(url: url, width: 480, height: 720))
        }
        let tempurl = "https://zee5vod.akamaized.net" + data.hlsUrl
        return GCKMediaInformation(contentID: tempurl, streamType: .buffered, contentType: "mp4", metadata: metadata, streamDuration: TimeInterval(data.duration), customData: customData)
    }
}

extension ChromeCastManager: ChromeQueueMenuDelegate {
    
    @objc public func showAddToQueueMenu() {
        self.addQueue = bundle.loadNibNamed(ChromeAddQueue.identifier, owner: self, options: nil)?.first as? ChromeAddQueue
        self.addQueue.delegate = self
        if let frame = UIApplication.shared.keyWindow?.frame {
            self.addQueue.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        }
        self.addQueue.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        UIApplication.shared.keyWindow?.addSubview(addQueue)
    }
    
    @objc public func removeAddToQueueMenu() {
        if self.addQueue != nil {
            self.addQueue.removeFromSuperview()
        }
    }
    
    @objc public func showMiniController(){
        self.miniControllerView = bundle.loadNibNamed(ChromeMiniControllerView.identifier, owner: self, options: nil)?.first as? ChromeMiniControllerView
        if let frame = UIApplication.shared.keyWindow?.frame {
            self.miniControllerView.frame = CGRect(x: 0, y: 700, width: frame.width, height: 50)
        }
        self.miniControllerView.miniMediaControlsViewEnabled = true
        UIApplication.shared.keyWindow?.addSubview(miniControllerView)
    }
    
    @objc public func  removeMiniController() {
        self.miniControllerView.removeFromSuperview()
    }
    
    func didSelectMenu(for option: ChromQueueMenu) {
        switch option {
        case .play:
            self.delegate?.didSelectMenuOption(with: .play)
        case .queue:
            self.delegate?.didSelectMenuOption(with: .queue)
        case .cancel:
            self.delegate?.didSelectMenuOption(with: .cancel)
        }
    }
}


extension ChromeCastManager: GCKLoggerDelegate {
    public func logMessage(_ message: String, fromFunction function: String) {
        ZeeUtility.utility.console("Chromecast Message = \(message) ** \(function)")
    }
    
    public func logMessage(_ message: String, at _: GCKLoggerLevel, fromFunction function: String, location: String) {
        if enableSDKLogging {
            ZeeUtility.utility.console("Message from Chromecast *** \(location) :: \(function) :: \(message)")
        }
    }
}

extension ChromeCastManager: GCKSessionManagerListener
{
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        self.playSelectedItemRemotely()
    }
    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: Error?) {
        AnalyticEngine .shared .castingEndAnalytics(with:CastDeviceName)
    }
    
    public func sessionManager(_ sessionManager: GCKSessionManager, session: GCKSession, didUpdate device: GCKDevice) {
        CastDeviceName = device.friendlyName ?? "Unable to get name"
    }
}


extension ChromeCastManager: GCKRequestDelegate, GCKRemoteMediaClientListener {
    public func requestDidComplete(_ request: GCKRequest) {
        ZeeUtility.utility.console("Completed request \(Int(request.requestID)) completed")
    }
    
    public func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        ZeeUtility.utility.console("Failed Error: request \(Int(request.requestID)) failed with error \(error)")
    }
}
