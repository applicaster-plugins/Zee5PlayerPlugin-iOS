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
import Alamofire


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
    let networkReachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")

    
    
    // Current player display mode
    var currentDisplayMode: PlayerViewDisplayMode?
    var previousParentViewController: UIViewController?
    var previousContainerView: UIView?
    let container = UIView()
    let activityLoader = Zee5ActivityLoader(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let Singleton:SingletonClass
    
    
    var delegate: ZEE5PlayerDelegate?
    
    // MARK: - Lifecycle
    
    required init(builder: PlayerViewBuilderProtocol, player: PlayerAdapterProtocol) {
        self.builder = builder
        self.playerAdapter = player
        self.Singleton = SingletonClass .sharedManager() as! SingletonClass
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
        
        ZEE5PlayerManager.sharedInstance().delegate = self
        
        // Add appication observer
        self.addNotifiactonObserver()
        
        //  Register the player events
        self.playerAdapter?.registerPlayerEvents()
        checkForReachability()
    }
    
    public func play() {
        self.playerAdapter?.serverType()

        // Initialize Zee5Player
        let config = ZEE5PlayerConfig()
        country = Zee5UserDefaultsManager.shared.getCountryDetailsFromCountryResponse().country
        translation =  Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage() ?? "en"
        
        ZEE5PlayerManager.sharedInstance().playVODContent(contentId, country: country, translation: translation, playerConfig: config, playbackView: playerView) { (data,token) in
            self.ShowIndicator()
        }
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
    
    
   @objc public func ShowIndicator()  {
    ShowIndicator(onParent: playerView)
   }
    
    @objc public func ShowIndicator(onParent view: UIView)  {
      HideIndicator()
      container.frame = view.bounds
      container.backgroundColor = UIColor(hue: 0/360, saturation: 0/100, brightness: 0/100, alpha: 0.4)
      let loadingView: UIView = UIView()
      loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
      loadingView.center = container.center
      loadingView.clipsToBounds = true
      loadingView.layer.cornerRadius = 20
      activityLoader.center = CGPoint(x: loadingView.frame.size.width / 2,y : loadingView.frame.size.height / 2)
      loadingView.addSubview(activityLoader)
      container.addSubview(loadingView)
      view.addSubview(container)
      activityLoader.startAnimating()
      checkForReachability()

        if Singleton.viewsArray.contains(container) == false {
            Singleton.viewsArray.add(container)
        }
        if Singleton.viewsArray.contains(loadingView) == false {
             Singleton.viewsArray.add(loadingView)
        }
        if Singleton.viewsArray.contains(activityLoader) == false {
             Singleton.viewsArray.add(activityLoader)
        }
     }
    
    @objc public func HideIndicator()  {
     container .removeFromSuperview()
     activityLoader.stopAnimating()
    
    }
    
  @objc public func checkForReachability() {
        self.networkReachabilityManager?.listener = { status in
            print("Network Status: \(status)")
            switch status {
            case .notReachable:
                ZEE5PlayerSDK.setConnection(NoInternet)
                Zee5ToastView.showToast(withMessage: "No Internet Connection")
                break;
            case .reachable(.ethernetOrWiFi), .unknown:
                ZEE5PlayerSDK.setConnection(Wifi)
                break;
            case .reachable(.wwan):
                ZEE5PlayerSDK.setConnection(WWAN)
                break;
            }
        }

        self.networkReachabilityManager?.startListening()
    }
}

// MARK: - ZEE5PlayerDelegate Method

extension KalturaPlayerController: ZEE5PlayerDelegate {
    func didFinishPlaying() {
        self.HideIndicator()
        self.delegate?.didFinishPlaying?()
    }
    
    func didTaponMinimizeButton() {
        guard let currentDisplayMode = self.currentDisplayMode else {
            return
        }
    
        if currentDisplayMode == .inline {
            self.delegate?.didFinishPlaying?()
        }
        else {
            ZEE5PlayerManager.sharedInstance().setFullScreen(false)
        }
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
    
    func getPlayerEvent(_ event:PlayerEvent) {
        print("KalturaPlayerController ** ZEE5PlayerDelegate getPlayerEvent ::: \(event)")
        
    }
    
    func hidePlayerLoader() {
        print("KalturaPlayerController ** ZEE5PlayerDelegate Hide Loader ***")
            self.HideIndicator()
              
    }
    func showPlayerLoader() {
        print("KalturaPlayerController ** ZEE5PlayerDelegate Show Loader ***")
            self.ShowIndicator()
              
    }
    
}
