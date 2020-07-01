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
    case hidden = 0
    case fullScreen = 1
    case inline = 2
    case mini = 3
}

 class KalturaPlayerController: UIViewController {
    var contentId = "0-0-2464"
    var country = "IN"
    var translation = "en"
    let networkReachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")

    
    var currentDisplayMode: PlayerViewDisplayMode = .hidden
    let container = UIView()
    let activityLoader = Zee5ActivityLoader(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let Singleton:SingletonClass
    
    var delegate: ZEE5PlayerDelegate?
    
    // MARK: - Lifecycle
    
    required init() {
        self.Singleton = SingletonClass .sharedManager() as! SingletonClass
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        
        ZEE5PlayerManager.sharedInstance().delegate = self
        
        // Add appication observer
        self.addNotifiactonObserver()
        
        checkForReachability()
    }
    override func viewWillAppear(_ animated: Bool) {
        ZEE5PlayerManager.sharedInstance().playbackcheck()
    }
    
    public func play() {
        // Initialize Zee5Player
        let config = ZEE5PlayerConfig()
        country = Zee5UserDefaultsManager.shared.getCountryDetailsFromCountryResponse().country
        translation =  Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage() ?? "en"
        
        ZEE5PlayerManager.sharedInstance().playVODContent(contentId, country: country, translation: translation, playerConfig: config, playbackView: self.view) { (data,token) in
            self.ShowIndicator()
        }
    }
    
    private func addNotifiactonObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(wentBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(wentForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func wentBackground() {
        if self.view.window != nil {
            Zee5PlayerPlugin.sharedInstance().player.pause()
        }
    }
    
    @objc private func wentForeground() {
        if self.view.window != nil {
            Zee5PlayerPlugin.sharedInstance().player.play()
        }
    }
    
    
   @objc public func ShowIndicator()  {
    ShowIndicator(onParent: self.view)
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
        if Singleton.viewsArray.contains(view) == false {
             Singleton.viewsArray.add(view)
        }
     }
    
    @objc public func HideIndicator()  {
     container .removeFromSuperview()
     activityLoader.stopAnimating()
    
    }
    
  @objc public func checkForReachability() {
        self.networkReachabilityManager?.listener = { status in
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
        if self.currentDisplayMode == .inline {
            self.delegate?.didFinishPlaying?()
        }
        else {
            ZEE5PlayerManager.sharedInstance().setFullScreen(false)
        }
    }
    
    func didTapOnEnableAutoPlay() {
    }
    
    func didTapOnAddToWatchList() {
    }
    
    func playerData(_ dict: [AnyHashable : Any]) {
    }
    
   func didFinishWithError(_ error: ZEE5SdkError) {
    }
    
    func availableAudioTracks(_ aryModels: [Any]) {
    }
    
    func availableSubTitles(_ aryModels: [Any]) {
    }
    
    func didTaponNextButton() {
    }
    
   func didTaponPrevButton() {
    }
    
    func getPlayerEvent(_ event:PlayerEvent) {
        
    }
    
    func hidePlayerLoader() {
        self.HideIndicator()
              
    }
    func showPlayerLoader() {
        self.ShowIndicator()
    }
    
}
