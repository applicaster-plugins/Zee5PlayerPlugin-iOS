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
    let networkReachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")

    public var currentDisplayMode: PlayerViewDisplayMode = .hidden {
        didSet {
            self.updateDisplayMode()
        }
    }
    
    var loadingContainer: UIView!
    var zeeActivityIndicator: Zee5ActivityLoader!
    let Singleton:SingletonClass
    
    var delegate: ZEE5PlayerDelegate?
    
    public func updateDisplayMode() {
        switch self.currentDisplayMode {
        case .fullScreen:
            ZEE5PlayerManager.sharedInstance().showFullScreen()
        default:
            ZEE5PlayerManager.sharedInstance().hideFullScreen()
        }
    }
    
    // MARK: - Lifecycle
    
    required init() {
        self.Singleton = SingletonClass .sharedManager() as! SingletonClass
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = PlaybackViewWithLoader()
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
    
    public func showIndicator()  {
        guard !self.isLoading() else {
            return
        }
                
        let loadingContainer = UIView()
        loadingContainer.accessibilityLabel = "LoadingContainer"

        self.loadingContainer = loadingContainer

        self.view.insertSubview(loadingContainer, at: max(self.view.subviews.count - 1, 0))

        loadingContainer.fillParent()
        
        loadingContainer.backgroundColor = UIColor(hue: 0/360, saturation: 0/100, brightness: 0/100, alpha: 0.4)
        loadingContainer.isUserInteractionEnabled = false
        
        (self.view as? PlaybackViewWithLoader)?.overlay = loadingContainer
        
        let zeeActivityIndicator = Zee5ActivityLoader(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        self.zeeActivityIndicator = zeeActivityIndicator
        
        loadingContainer.addSubview(zeeActivityIndicator)

        zeeActivityIndicator.centerInParent(size: CGSize(width: 40, height: 40))
        zeeActivityIndicator.startAnimating()
        
        checkForReachability()
        
        if Singleton.viewsArray.contains(loadingContainer) == false {
            Singleton.viewsArray.add(loadingContainer)
        }

        if Singleton.viewsArray.contains(zeeActivityIndicator) == false {
            Singleton.viewsArray.add(zeeActivityIndicator)
        }
    }
    
    public func hideIndicator()  {
        self.loadingContainer?.removeFromSuperview()
        self.zeeActivityIndicator?.stopAnimating()
    }
    
    public func isLoading() -> Bool {
        return self.loadingContainer?.superview != nil
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
        self.hideIndicator()
        self.delegate?.didFinishPlaying?()
    }
    
    func didTaponMinimizeButton() {
        if self.currentDisplayMode == .fullScreen {
            ZEE5PlayerManager.sharedInstance().setFullScreen(false)
        }
        else {
            self.delegate?.didFinishPlaying?()
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
        self.hideIndicator()
              
    }
    
    func showPlayerLoader() {
        self.showIndicator()
    }
}

class PlaybackViewWithLoader: UIView {
    var overlay: UIView?
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        if let overlay = self.overlay {
            self.bringSubviewToFront(overlay)
        }
    }
}
