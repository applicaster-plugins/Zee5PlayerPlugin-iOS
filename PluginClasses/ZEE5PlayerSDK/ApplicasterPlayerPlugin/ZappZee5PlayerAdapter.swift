//
//  ZappZee5PlayerAdapter.swift
//  ZEE5PlayerSDK
//
//  Created by User on 25/09/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

import Foundation
import ZappPlugins
import ApplicasterSDK

protocol PlayerAdapterProtocol: class {
    var currentItem: ZPPlayable? { get }
    var player: Player? { get set }
    
    var playbackState: Progress { get }
    var playerState: ZPPlayerState { get }
    
    var didSwitchToItem: ((ZPPlayable) -> Void)? { get set }
    var didEndPlayback: (() -> Void)? { get set }
    
    func play()
    func pause()
    func stop()
    func resume()
    func serverType()
    
    func registerPlayerEvents()
}

class ZappZee5PlayerAdapter: NSObject, PlayerAdapterProtocol, ZEE5PlayerDelegate {
   

    
    // MARK: - Properties
    
    var player: Player?
    
    private(set) var playerState: ZPPlayerState = .undefined
    private(set) var playbackState: Progress = Progress()
    
    var didSwitchToItem: ((ZPPlayable) -> Void)?
    var didEndPlayback: (() -> Void)?
    
    private(set) var currentItem: ZPPlayable? {
        didSet {
            currentItem.flatMap { didSwitchToItem?($0) }
        }
    }
    
    // MARK: - Lifecycle
    
    init(items: [ZPPlayable]) {
        self.currentItem = items.first
        
        super.init()
    }
    
    // MARK: - PlayerAdapterProtocol methods

    func registerPlayerEvents() {
        self.player?.addObserver(self, event: PlayerEvent.playing, block: { (event) in
            print("Event Player:: Playing")
        })
    }
    
    func play() {
        self.player?.play()
    }
    
    func serverType() {
        let serverType = APThirdPartyServerSwitchManager.serverType()
        
            switch serverType {
            case .productionServer:
                ZEE5PlayerSDK.setDevEnvirnoment(production)
            case .developmentServer:
                ZEE5PlayerSDK.setDevEnvirnoment(development)
            case.customServer:
                ZEE5PlayerSDK.setDevEnvirnoment(development)
            default:
                break
    }
    }
    func pause() {
        self.player?.pause()
    }
    
    func stop() {
        self.player?.stop()
    }
    
    func resume() {
        self.player?.resume()
    }
    
    // MARK: - ZEE5PlayerDelegate Method
    
    func didFinishPlaying() {
        print("ZappZee5PlayerAdapter ** ZEE5PlayerDelegate didFinishPlaying ***")
        self.didEndPlayback?()
    }
    
    func didTaponMinimizeButton() {
        print("ZappZee5PlayerAdapter ** ZEE5PlayerDelegate didTaponMinimizeButton ***")
        
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            print("NAV === \(navigationController)")
            navigationController.popToRootViewController(animated: true)
            
        }
        
    }
    
    func didTapOnEnableAutoPlay() {
        print("ZappZee5PlayerAdapter ** ZEE5PlayerDelegate didTapOnEnableAutoPlay ***")
    }
    
    func didTapOnAddToWatchList() {
        print("ZappZee5PlayerAdapter ** ZEE5PlayerDelegate didTapOnAddToWatchList ***")
    }
    
    func playerData(_ dict: [AnyHashable : Any]) {
        print("ZappZee5PlayerAdapter ** ZEE5PlayerDelegate PlayerData ::: \(dict)")
    }
}
