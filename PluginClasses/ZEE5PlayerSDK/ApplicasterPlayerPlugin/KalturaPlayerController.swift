//
//  KalturaPlayerController.swift
//  ZEE5PlayerSDK
//
//  Created by User on 26/09/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

import Foundation
import ZappPlugins
import ApplicasterSDK
import Zee5CoreSDK

internal enum PlayerViewDisplayMode : Int {
    case unknown = 0
    case fullScreen = 1
    case inline = 2
    case mini = 3
}

 class KalturaPlayerController: UIViewController {

    // MARK: - Properties
    var builder: PlayerViewBuilderProtocol
    var playerAdapter: PlayerAdapterProtocol?
    
    var playerView: UIView!
    var contentId = "0-0-2464"
    var country = "IN"
    var translation = "en"
    
    
    // Current player display mode
    var currentDisplayMode: PlayerViewDisplayMode?
    var previousParentViewController: UIViewController?
    var previousContainerView: UIView?
    
    // MARK: - Lifecycle
    
    required init(builder: PlayerViewBuilderProtocol, player: PlayerAdapterProtocol) {
        self.builder = builder
        self.playerAdapter = player
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup player view for applicaster
        self.playerView = UIView()
        self.view.addSubview(self.playerView)
        self.playerView.matchParent()  // Applicaster
                
        // Initialize Zee5Player
        let config = ZEE5PlayerConfig()
        country = Zee5UserDefaultsManager.shared.getCountryDetailsFromCountryResponse().country
        translation =  Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage() ?? "en"
        
        ZEE5PlayerManager.sharedInstance().playVODContent(contentId, country: country, translation: translation, playerConfig: config, playbackView: playerView) { (data,token) in
            print(data?.title ?? nil ?? "Welcome")
        }
        ZEE5PlayerManager.sharedInstance().delegate = self
        
        // Add appication observer
        self.addNotifiactonObserver()
        
        //  Register the player events
        self.playerAdapter?.registerPlayerEvents()
    }
    
    private func addNotifiactonObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(wentBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(wentForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func wentBackground() {
        print("wentBackground ****")
        if self.view.window != nil {
            print("wentBackground **")
            self.playerAdapter?.pause()
        }
    }
    
    @objc private func wentForeground() {
        print("wentForeground ****")
        if self.view.window != nil {
            print("wentForeground **")
            self.playerAdapter?.resume()
        }
    }
    
}

// MARK: - ZEE5PlayerDelegate Method

extension KalturaPlayerController: ZEE5PlayerDelegate {
    
    func didFinishPlaying() {
        print("KalturaPlayerController ** ZEE5PlayerDelegate didFinishPlaying ***")
        self.playerAdapter?.stop()
        
        Zee5ToastView.showToastAboveKeyboard(withMessage: "Error")
        
    }
    
   func didTaponMinimizeButton() {
        print("KalturaPlayerController ** ZEE5PlayerDelegate didTaponMinimizeButton ***")
    
       dismissViewController(withAnimation: false)
    }
    
    func didTapOnEnableAutoPlay() {
        print("KalturaPlayerController ** ZEE5PlayerDelegate didTapOnEnableAutoPlay ***")
    }
    
    func didTapOnAddToWatchList() {
        print("KalturaPlayerController ** ZEE5PlayerDelegate didTapOnAddToWatchList ***")
    }
    
    func playerData(_ dict: [AnyHashable : Any]) {
        print("KalturaPlayerController ** ZEE5PlayerDelegate PlayerData ::: \(dict)")
    }
    
   func didFinishWithError(_ error: ZEE5SdkError) {
        print("KalturaPlayerController ** ZEE5PlayerDelegate didFinishWithError ::: \(error)")
    }
    
    func availableAudioTracks(_ aryModels: [Any]) {
        print("KalturaPlayerController ** ZEE5PlayerDelegate availableAudioTracks ::: \(aryModels)")
    }
    
    func availableSubTitles(_ aryModels: [Any]) {
        print("KalturaPlayerController ** ZEE5PlayerDelegate availableSubTitles ::: \(aryModels)")
    }
    
    func didTaponNextButton() {
        print("KalturaPlayerController ** ZEE5PlayerDelegate didTaponNextButton ***")
    }
    
   func didTaponPrevButton() {
        print("KalturaPlayerController ** ZEE5PlayerDelegate didTaponPrevButton ***")
    }
    
     func getPlayerEvent(_ event: PlayerEvent) {
        print("KalturaPlayerController ** ZEE5PlayerDelegate getPlayerEvent ::: \(event)")
        
    }
}
