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
import ZappSDK
import ZeeHomeScreen

class HybridViewController: UIViewController {
    
    var configurationJSON: NSDictionary?
    public var pluginStyles: [String : Any]?
    
    var kalturaPlayerController: KalturaPlayerController?
    
    public var isViewWillAppear = true
    var dataSource:[Any] = []
    private let bundle = Bundle(for: DownloadRootController.self)
    
    @IBOutlet var playerView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    
    @IBOutlet var buttonsViewCollection: [UIButton]!
    @IBOutlet var viewCollection: [UIView]!
    @IBOutlet var labelsCollection: [UILabel]!
    
    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var itemDescriptionLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var streamTranslationsView: StreamTranslationsView!
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var mainCollectionViewContainer: UIView!
    @IBOutlet var metadataViewContainer: UIView!
    var mainCollectionViewController: StaticViewCollectionViewController?
    
    typealias CellItem = (title: String?, subtitle: String?, description: String?)
    var castDataSource: [CellItem]?
    var creatorsDataSource: [CellItem]?
        
    var playable: ZeePlayable? {
        willSet(newValue) {
            guard self.isViewLoaded else {
                return
            }
            
            guard self.playable !== newValue else {
                return
            }
            
            self.resetContent()
        }
        
        didSet {
            guard
                self.isViewLoaded,
                self.playable != nil else {
                    return
            }
            
            self.commonInit()
        }
    }
    
    // MARK: Orientation
        
    override open var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
  
        guard let playerViewController = self.kalturaPlayerController else {
            return
        }
        
        DownloadHelper.shared.transition(to: nil)
        
        let shareViwController = ZEE5PlayerManager.sharedInstance().currentShareViewController
        if let shareViwController = shareViwController {
            shareViwController.dismiss(animated: false)
        }
        
        coordinator.animate(alongsideTransition: nil, completion: { (context) in
            switch newCollection.verticalSizeClass {
            case .compact:
                playerViewController.changePlayer(displayMode: .fullScreen, parentViewController: self, viewContainer: self.playerView) {
                    DownloadHelper.shared.transition(to: playerViewController.view)
                    if let shareViwController = shareViwController {
                        playerViewController.present(shareViwController, animated: false)
                    }

                }
            default:
                playerViewController.changePlayer(displayMode: .inline, parentViewController: self, viewContainer: self.playerView) {
                    DownloadHelper.shared.transition(to: self.view)
                    
                    if let shareViwController = shareViwController {
                        self.present(shareViwController, animated: false)
                    }
                }
            }
        })
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
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.playerView.addGestureRecognizer(panGestureRecognizer)
        
        self.addGradient()
        
        self.kalturaPlayerController?.delegate = self
        
        initKalturaPlayer()
        
        addGestureRecognizerHandler()
    }
    
    func initKalturaPlayer() {
        self.observer()
                
        kalturaPlayerConfiguration()
    }
    
    func commonInit() {
        guard let playable = self.playable else {
            return
        }
        
        self.stylesConfiguration()
        
        self.itemNameLabel.text = playable.title
        self.itemDescriptionLabel.text = playable.description
        self.itemDescriptionLabel.isHidden = self.itemDescriptionLabel.text == nil
        
        self.configureForType()
        
        self.setupButtons()
        self.setupLabels()
        self.setupViews()
        
        self.metadataViewContainer.isHidden = false
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changePlayerDisplayToMini),
                                               name: NSNotification.Name(rawValue: "chromecastPlayerWasMinimized"),
                                               object: nil)
        
    }
    
    // MARK:
    
    func setupDataSources() {
        guard let playable = self.playable else {
            return
        }
        
        func setupCast() {
            guard self.castDataSource == nil, let cast = playable.cast else {
                return
            }
            
            var castDataSource = [CellItem]()
            cast.forEach { (castMember) in
                castDataSource.append((title: castMember.character, subtitle: nil, description: castMember.actor))
            }
            
            self.castDataSource = castDataSource
        }
        
        func setupCreators() {
            guard self.creatorsDataSource == nil, let creators = playable.creators else {
                return
            }
            
            var creatorsDataSource = [CellItem]()
            creators.forEach { (creator) in
                creatorsDataSource.append((title: creator.title, subtitle: nil, description: creator.name))
            }
            
            self.creatorsDataSource = creatorsDataSource
        }
    }
    
    
    func stylesConfiguration() {
        
        guard let buttonsBackgroundStyle = ZAAppConnector.sharedInstance().layoutsStylesDelegate.styleParams?(byStyleName: "LayoutGenericListItemBGColor"),
             let color = buttonsBackgroundStyle["color"] as? UIColor else {
                 return
         }
        self.view.backgroundColor = color
    }
    
    
    public func kalturaPlayerConfiguration() {
        guard
            let playerView = self.playerView,
            let kalturaPlayerController = self.kalturaPlayerController else {
                return
        }
        
        kalturaPlayerController.changePlayer(displayMode: .inline, parentViewController: self, viewContainer: playerView)
    }
    
    public func updatePlayerConfiguration() {
        self.kalturaPlayerConfiguration()
    }
    
    func closePlayer() {
        guard let playerManager = ZPPlayerManager.sharedInstance.lastActiveInstance as? Zee5PluggablePlayer else {
            return
        }
        
        playerManager.stopAndDismiss()
    }
    
    // MARK: Video Loading View
    
    public func videoLoadingView() -> (UIView & APLoadingView)? {
        var loadingView: (UIView & APLoadingView)?
        
        if let videoLoadingView = (Bundle(for: HybridViewController.self).loadNibNamed("Zee5VideoLoadingView", owner: self, options: nil)?.first) {
            loadingView = videoLoadingView as? UIView & APLoadingView
        }
        return loadingView
    }
    
    fileprivate func addGradient() {
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame = self.mainCollectionViewContainer.bounds
 
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        gradientLayer.colors = [UIColor(red: 19/255, green: 0, blue: 20/255, alpha: 1).cgColor, UIColor(red: 43/255, green: 2/255, blue: 37/255, alpha: 1).cgColor]
        gradientLayer.shouldRasterize = true
        
        self.backgroundView.layer.sublayers?.removeAll()
        self.backgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    fileprivate func removeGradient() {
        self.mainCollectionViewContainer.layer.sublayers?.removeAll()
    }
    
    fileprivate func resetContent() {
        self.itemNameLabel?.text = nil
        self.itemDescriptionLabel?.text = nil
        
        self.castDataSource = nil
        self.creatorsDataSource = nil
        
        self.labelsCollection.forEach { (label) in
            label.text = nil
            label.isHidden = true
        }
        
        self.viewCollection.forEach { (view) in
            if let actionBarView = view as? ActionBarView {
                actionBarView.resetButtons()
            }
            else if let metaDataCollectionView = view as? UICollectionView {
                metaDataCollectionView.reloadData()
            }
            else if let adBanner = view as? AdBanner {
                adBanner.isHidden = true
            }
            else if let premiumBanner = view as? PremiumBanner {
                premiumBanner.isHidden = true
            }
        }
        
        self.mainCollectionViewContainer.removeAllSubviews()
        
        self.metadataViewContainer.isHidden = true
    }
    
    private func addGestureRecognizerHandler() {
        ZEE5PlayerManager.sharedInstance().setPanDownGestureHandler(closePlayer)
    }
}

extension HybridViewController: ZEE5PlayerDelegate {
    func didFinishPlaying() {
        self.closePlayer()
    }
}
