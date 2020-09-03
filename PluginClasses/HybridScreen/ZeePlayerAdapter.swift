//
//  ZeePlayerAdapter.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 01.07.20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

import ZappPlugins
import Zee5CoreSDK

protocol ZeePlayerAdapterDelegate: class {
    func playerAdapterDidLoadPlayable(_ playable: ZeePlayable)
}

class ZeePlayerAdapter {
    weak var delegate: ZeePlayerAdapterDelegate?
    fileprivate var playbackSession: PlaybackSession? = nil
    
    func startSession(_ contentId: String) {        
        if  let session = self.playbackSession,
            session.hasEqual(contentId: contentId),
            session.canResume(),
            let playable = session.playable() {
            
            self.delegate?.playerAdapterDidLoadPlayable(playable)
            session.play()
        }
        else {
            let session = PlaybackSessionBuilder.build(from: contentId)
            self.playbackSession = session
            
            session.loadContent() { [weak self] in
                guard
                    let self = self,
                    let playable = session.playable() else {
                        return
                }
                
                self.delegate?.playerAdapterDidLoadPlayable(playable)
                session.play()
            }
        }
    }
    
    func endSession() {
        guard let session = self.playbackSession else {
            return
        }
        
        session.end()
    }
    
    func sessionHasEqual(contentId: String) -> Bool {
        return self.playbackSession?.hasEqual(contentId: contentId) ?? false
    }
}

fileprivate protocol PlaybackSession {
    typealias LoadContentCompletion = () -> ()
    
    init(with contentId: String)
    func hasEqual(contentId: String) -> Bool
    
    func loadContent(completion: @escaping LoadContentCompletion)
    func play()
    func end()
    func canResume() -> Bool
    func playable() -> ZeePlayable?
}

fileprivate class PlaybackSessionBuilder {
    static func build(from contentId: String) -> PlaybackSession {
        var contentType: String? = nil
        
        let components = contentId.components(separatedBy: "-")
        if components.count > 1 {
            contentType = components[1]
        }

        switch contentType {
        case "9":
            return LivePlaybackSession(with: contentId)
            
        case "6":
            return TvShowPlaybackSession(with: contentId)
            
        default:
            return VodPlaybackSession(with: contentId)
        }
    }
}

fileprivate typealias ItemResponse = [AnyHashable : Any]

fileprivate class BasePlaybackSession: PlaybackSession {
    let contentId: String
    
    var baseDelegate: BasePlaybackSessionDelegate!
    var itemResponse: ItemResponse? = nil
    
    var didEnd: Bool = false
    
    required init(with contentId: String) {
        self.contentId = contentId
        self.baseDelegate = self as? BasePlaybackSessionDelegate
    }

    func hasEqual(contentId: String) -> Bool {
        return self.contentId == contentId
    }
    
    func loadContent(completion: @escaping LoadContentCompletion) {
        
        let url = self.baseDelegate.sessionContentUrl()
        
        let country = Zee5UserDefaultsManager.shared.getCountryDetailsFromCountryResponse().country
        let language =  Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage() ?? "en"
        let token = Zee5UserDefaultsManager.shared.getPlatformToken()
        
        let params = [
            "country": country,
            "translation": language
        ]
        
        let headers = [
            "Content-Type": "application/json",
            "X-Access-Token": token
        ]
        
        ZEE5PlayerManager.sharedInstance().showloaderOnPlayer()
        
        NetworkHelper.requestJsonObject(forUrlString: url, method: .get, parameters: params, headers: headers) { [weak self] (data, error, zee5SdkError, statusCode) in
            guard let self = self, !self.didEnd else {
                return
            }
            
            if let zee5SdkError = zee5SdkError {
                switch zee5SdkError.zeeErrorCode {
                // Data not found
                case 101: self.handleUnavailableContent()
                default: break
                }
                completion()
                return
            }
            
            guard let response = data as? ItemResponse else {
                return
            }
            
            self.itemResponse = response
            self.baseDelegate.sessionParseResponse(response)
            
            completion()
        }
    }
    
    func end() {
        self.didEnd = true
        
        ZEE5PlayerManager.sharedInstance().stop()
        ZEE5PlayerManager.sharedInstance().destroyPlayer()
        AnalyticEngine.shared.VideoExitAnalytics()
        AnalyticEngine.shared.cleanupVideoSesssion()
    }
    
    func canResume() -> Bool {
        var result = false
        
        if self.baseDelegate.sessionHasLoadedContent() {
            result = true
        }
        
        return result
    }
    
    func play() {
        self.didEnd = false

        ZEE5PlayerSDK.initialize(with: User.shared.getUserId())
        
        self.baseDelegate.sessionPlay()
        
        AnalyticEngine.shared.screenViewEvent()
    }
    
    func playable() -> ZeePlayable? {
        return self.baseDelegate.sessionPlayable()
    }
    
    private func handleUnavailableContent() {
        ZEE5PlayerManager.sharedInstance().hideLoaderOnPlayer()
        ZEE5PlayerManager.sharedInstance().setContentUnavailable()
    }
}

fileprivate protocol BasePlaybackSessionDelegate {
    func sessionParseResponse(_ response: ItemResponse)
    func sessionContentUrl() -> String
    func sessionPlayable() -> ZeePlayable?
    func sessionHasLoadedContent() -> Bool
    func sessionPlay()
}

fileprivate class VodPlaybackSession: BasePlaybackSession, BasePlaybackSessionDelegate {
    var vodItem: VODContentDetailsDataModel? = nil
    
    func sessionParseResponse(_ response: ItemResponse) {
        self.vodItem = VODContentDetailsDataModel.initFromJSONDictionary(response)
    }
    
    func sessionContentUrl() -> String {
        return "https://gwapi.zee5.com/content/details/" + self.contentId
    }
    
    func sessionPlayable() -> ZeePlayable? {
        guard let extensions = self.itemResponse else {
            return nil
        }
        
        return ZeePlayable(extensions)
    }
    
    func sessionHasLoadedContent() -> Bool {
        return self.vodItem != nil
    }
    
    func sessionPlay() {
        guard
            let item = self.vodItem else {
            return
        }
        
        ZEE5PlayerManager.sharedInstance().playVODContent(with: item)
    }
}

fileprivate class LivePlaybackSession: BasePlaybackSession, BasePlaybackSessionDelegate {
    var liveItem: LiveContentDetails? = nil
    
    func sessionParseResponse(_ response: ItemResponse) {
        self.liveItem = LiveContentDetails.initFromJSONDictionary(response)
    }
    
    func sessionContentUrl() -> String {
        return "https://catalogapi.zee5.com/v1/channel/" + self.contentId
    }
    
    func sessionPlayable() -> ZeePlayable? {
        guard let extensions = self.itemResponse else {
            return nil
        }
        
        return ZeePlayable(extensions)
    }
    
    func sessionHasLoadedContent() -> Bool {
        return self.liveItem != nil
    }
    
    func sessionPlay() {
        guard
            let item = self.liveItem else {
                return
        }
        
        ZEE5PlayerManager.sharedInstance().playLiveContent(withModel: item);
    }
}


fileprivate class TvShowPlaybackSession: BasePlaybackSession, BasePlaybackSessionDelegate {
    var tvShowItem: tvShowModel? = nil
    var episodePlaybackSession: VodPlaybackSession? = nil
    
    override func loadContent(completion: @escaping BasePlaybackSession.LoadContentCompletion) {
        super.loadContent() {
            guard let response = self.itemResponse else {
                return
            }
            
            let showPlayable = ZeePlayable(response)
            
            guard
                let latestEpisode = showPlayable.latestEpisode,
                let episodeContentId = latestEpisode.contentId else {
                    return
            }
            
            let episodePlaybackSession = VodPlaybackSession(with: episodeContentId)
            self.episodePlaybackSession = episodePlaybackSession
            
            episodePlaybackSession.loadContent {
                completion()
            }
        }
    }
    
    func sessionParseResponse(_ response: ItemResponse) {
        self.tvShowItem = tvShowModel.initFromJSONDictionary(response)
        if let tvshowModel = self.tvShowItem {
            ZEE5PlayerManager.sharedInstance().getShowModel(tvshowModel)
        }
    }
    
    func sessionContentUrl() -> String {
        return "https://gwapi.zee5.com/content/tvshow/" + self.contentId
    }
    
    func sessionHasLoadedContent() -> Bool {
        return self.tvShowItem != nil && self.episodePlaybackSession?.sessionHasLoadedContent() ?? false
    }
    
    func sessionPlayable() -> ZeePlayable? {
        return self.episodePlaybackSession?.sessionPlayable()
    }
    
    func sessionPlay() {
        guard let episodePlaybackSession = self.episodePlaybackSession else {
            return
        }
        
        episodePlaybackSession.sessionPlay()
    }
}
