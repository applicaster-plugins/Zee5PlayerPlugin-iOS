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

@objcMembers public class ChromeCastManager: NSObject {
    public static let shared = ChromeCastManager()
    
    public var isCasting: Bool {
         return GCKCastContext.sharedInstance().sessionManager.hasConnectedSession()
    }
    
    public var delegate: ChromeCastDelegate?
    public static var appId = "E05C51D0"
    var CastDeviceName = ""
    private var addQueue: ChromeAddQueue!
    private var miniControllerView :ChromeMiniControllerView!

    let bundle = Bundle(for: ChromeCastManager.self)
    
    @objc public func initializeCastOptions() {
        let discoveryCriteria = GCKDiscoveryCriteria(applicationID: ChromeCastManager.appId)

        let options = GCKCastOptions(discoveryCriteria: discoveryCriteria)
        options.physicalVolumeButtonsWillControlDeviceVolume = true
        
        GCKCastContext.setSharedInstanceWith(options)
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
        
        GCKCastContext.sharedInstance().sessionManager.add(self)
        
        setupCastLogging()
        customizeCastManager()
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
        let classesToLog = ["GCKDeviceScanner", "GCKDeviceProvider", "GCKDiscoveryManager", "GCKCastChannel",
                            "GCKMediaControlChannel", "GCKUICastButton", "GCKUIMediaController", "NSMutableDictionary"]
        logFilter.setLoggingLevel(.verbose, forClasses: classesToLog)
        GCKLogger.sharedInstance().filter = logFilter
        GCKLogger.sharedInstance().delegate = self
    }
    
    @objc public func playSelectedItemRemotely() {
        self.loadSelectedItem(byAppending: false, with: nil, token: nil)
        GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()
        AnalyticEngine .shared .castingStartedAnalytics(with:CastDeviceName)
    }
    
    @objc public func enqueueSelectedItemRemotely(with data: VODContentDetailsDataModel, token: String) {
        self.loadSelectedItem(byAppending: true, with: data, token: token)
    }
    
    func loadSelectedItem(byAppending appending: Bool, with data: VODContentDetailsDataModel?, token: String?) {
        guard
            GCKCastContext.sharedInstance().sessionManager.hasConnectedCastSession(),
            let mediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient else {
                return
        }
        
        let mediaInfo: GCKMediaInformation!
        
        let customData: NSMutableDictionary = [:]
        customData["licenseCustomData"] = ZEE5PlayerManager.sharedInstance().currentItem.drm_token
        customData["licenseUrl"] = "https://pr-keyos-aps1.licensekeyserver.com/core/rightsmanager.asmx"
        mediaInfo = self.getMediaInformation(with: customData)

        let mediaQueueItemBuilder = GCKMediaQueueItemBuilder()
        mediaQueueItemBuilder.mediaInformation = mediaInfo
        mediaQueueItemBuilder.autoplay = true
        let mediaQueueItem = mediaQueueItemBuilder.build()
        

        if appending {
            let request = mediaClient.queueInsert(mediaQueueItem, beforeItemWithID: kGCKMediaQueueInvalidItemID)
            request.delegate = self
        }
        else {
            let queueDataBuilder = GCKMediaQueueDataBuilder(queueType: .generic)

            queueDataBuilder.items = [mediaQueueItem]
            queueDataBuilder.repeatMode = .off
            
            let requestDataBuilder = GCKMediaLoadRequestDataBuilder()
            requestDataBuilder.queueData = queueDataBuilder.build()
            
            let request = mediaClient.loadMedia(with: requestDataBuilder.build())
            request.delegate = self
        }
        
        mediaClient.add(self)
    }
    
    func getMediaInformation(with data: NSMutableDictionary) -> GCKMediaInformation? {
        let currentItem = ZEE5PlayerManager.sharedInstance().currentItem
        
        let builder = GCKMediaInformationBuilder()

        let contentUrlValue: String?
        
        if currentItem.asset_type == "9" {
            contentUrlValue = currentItem.hls_Url
            builder.streamType = .live
            builder.contentType = "application/x-mpegURL"
        }
        else if !currentItem.isDRM {
            contentUrlValue = currentItem.hls_Url
            builder.contentType = "mp4"
        }
        else {
            contentUrlValue = currentItem.mpd_Url
            builder.contentType = "application/x-mpegURL"
        }
        
        var metadataType: GCKMediaMetadataType = .generic
        metadataType = currentItem.asset_type.lowercased() == "movie" ? .movie : .tvShow
        
        let subtitle = currentItem.asset_type == "1" ? currentItem.originalTitle : currentItem.asset_subtype
        
        let metadata = GCKMediaMetadata(metadataType: metadataType)
        metadata.setString(subtitle, forKey: kGCKMetadataKeySubtitle)
        metadata.setString(currentItem.channel_Name, forKey: kGCKMetadataKeyTitle)
        metadata.setString(currentItem.info, forKey: "description")
        metadata.setInteger(Int(currentItem.asset_type) ?? 0, forKey: "assetType")
        metadata.setInteger(currentItem.duration, forKey: "contentLength")
        
        if let imageUrl = URL(string: currentItem.imageUrl) {
            metadata.addImage(GCKImage(url: imageUrl, width: 480, height: 720))
        }
        
        builder.contentID = contentUrlValue
        builder.metadata = metadata
        builder.streamDuration = currentItem.duration <= 0 ? 0 : TimeInterval(currentItem.duration)
        
        builder.customData = data
        
        return builder.build()
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
    public func logMessage(_ message: String, at _: GCKLoggerLevel, fromFunction function: String, location: String) {
    }
}

extension ChromeCastManager: GCKSessionManagerListener
{
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        ZEE5PlayerManager.sharedInstance().castCurrentItem()
    }
    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: Error?) {
        ZEE5PlayerManager.sharedInstance().playWithCurrentItem()
    }
    
    public func sessionManager(_ sessionManager: GCKSessionManager, session: GCKSession, didUpdate device: GCKDevice) {
        CastDeviceName = device.friendlyName ?? "Unable to get name"
    }
    
    public func sessionManager(_ sessionManager: GCKSessionManager, didSuspend session: GCKSession, with reason: GCKConnectionSuspendReason) {
    }
}


extension ChromeCastManager: GCKRequestDelegate, GCKRemoteMediaClientListener {
    public func remoteMediaClientDidUpdatePreloadStatus(_ client: GCKRemoteMediaClient) {
    }
        
    public func remoteMediaClient(_: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        guard let mediaStatus = mediaStatus else {
            return
        }

        let playerState: String
        switch mediaStatus.playerState {
        case .unknown:
            playerState = "unknown"
        case .idle:
            playerState = "idle"
        case .playing:
            playerState = "playing"
        case .paused:
            playerState = "paused"
        case .buffering:
            playerState = "buffering"
        case .loading:
            playerState = "loading"
        @unknown default:
            playerState = "default"
        }
        
        let idleReason: String
        switch mediaStatus.idleReason {
        case .error:
            idleReason = "error"
        case .interrupted:
            idleReason = "interrupted"
        case .cancelled:
            idleReason = "cancelled"
        case .none:
            idleReason = "none"
        case .finished:
            idleReason = "finished"
        @unknown default:
            idleReason = "default"
        }
    }
    
    public func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
    }
    
    public func requestDidComplete(_ request: GCKRequest) {
    }
    
    public func request(_ request: GCKRequest, didFailWithError error: GCKError) {
    }
}
