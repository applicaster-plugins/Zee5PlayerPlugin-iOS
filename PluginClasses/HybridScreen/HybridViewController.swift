//
//  HybridPlayerViewController.swift
//  Zee5PlayerPlugin
//
//  Created by Miri on 19/12/2018.
//  Copyright © 2018 Applicaster Ltd. All rights reserved.
//

import UIKit
import AVFoundation;
import ApplicasterSDK
import ZappPlugins
import Foundation
import MediaPlayer


class HybridViewController: UIViewController {

    var configurationJSON: NSDictionary?
    public var pluginStyles: [String : Any]?

    var currentPlayableItem: ZPPlayable?
    var kalturaPlayerController: KalturaPlayerController?

    var isPortraitUpsideDownOrientation: Bool?
    public var isViewWillAppear = true
    var dataSource:[Any] = []

    @IBOutlet weak var playerContainer: UIView?
    @IBOutlet weak var playerView: UIView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    // MARK: Orientation

    override open var shouldAutorotate: Bool {
        return true
    }

    override open var prefersStatusBarHidden: Bool {
        return false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    @objc func rotated() {
        if UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
            self.isPortraitUpsideDownOrientation = true
        }
        else {
            self.isPortraitUpsideDownOrientation = false
        }
        if !UIDevice.current.orientation.isFlat {
            if UIDevice.current.orientation.isLandscape {
                if self.isPortraitUpsideDownOrientation == false,
                    let mode = self.kalturaPlayerController?.currentDisplayMode,
                    mode != .mini {
                    self.kalturaPlayerController?.changePlayer(displayMode: .fullScreen)
                }
            } else {
                if let mode = self.kalturaPlayerController?.currentDisplayMode,
                    mode != .mini,
                    self.isPortraitUpsideDownOrientation == false {
                    self.kalturaPlayerController?.changePlayer(displayMode: .inline)
                }
            }
        }
    }
    
    // MARK:
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
    }

    func commonInit() {
        self.stylesConfiguration()

        self.activityIndicator?.isHidden = false
        self.activityIndicator?.startAnimating()

        self.observer()

        self.isPortraitUpsideDownOrientation = false

        kalturaPlayerConfiguration()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.playerView?.addGestureRecognizer(panGestureRecognizer)
    }

    var originalPosition: CGPoint?
    var currentPositionTouched: CGPoint?

    @objc func changePlayerDisplayToMini() {
//        self.playerViewController?.changePlayerDisplayMode(.mini)
    }

    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let velocity = panGesture.velocity(in: view)
        let currentPositionTouched = panGesture.location(in: view)

        if velocity.y >= 0,
            let playerViewBottom = self.playerView?.bottom,
            currentPositionTouched.y < (playerViewBottom * 4/5) {
            closePlayer()
//            self.playerViewController?.changePlayerDisplayMode(.mini)
        }
    }

    func observer() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rotated),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changePlayerDisplayToMini),
                                               name: NSNotification.Name(rawValue: "chromecastPlayerWasMinimized"),
                                               object: nil)

    }

    // MARK:

    func stylesConfiguration() {
        StylesHelper.setColorforView(view: self.view, key: "player_screen_bg_color", from: pluginStyles)
    }

    
    public func kalturaPlayerConfiguration() {
        guard let playerView = self.playerView,
            let playerVC = self.kalturaPlayerController else {
                return
        }
        self.addChildViewController(playerVC , to: playerView)
        playerVC.loadViewIfNeeded()
        self.kalturaPlayerController?.changePlayer(displayMode: .inline)
        self.kalturaPlayerController?.currentDisplayMode = .inline

    }
    
    public func updatePlayerConfiguration() {
//        self.extensionConfiguration()
        self.kalturaPlayerConfiguration()
    }

    func closePlayer() {
         self.dismiss(animated: true, completion: nil)
    }
     
    // MARK: Video Loading View

    public func videoLoadingView() -> (UIView & APLoadingView)? {
        var loadingView: (UIView & APLoadingView)?

        if let videoLoadingView = (Bundle(for: HybridViewController.self).loadNibNamed("Zee5VideoLoadingView", owner: self, options: nil)?.first) {
            loadingView = videoLoadingView as? UIView & APLoadingView
        }
        return loadingView
    }
    
    
}
