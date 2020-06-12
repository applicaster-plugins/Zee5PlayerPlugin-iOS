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
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var mainCollectionViewContainer: UIView!
    @IBOutlet var metadataViewContainer: UIView!
    var mainCollectionViewController: StaticViewCollectionViewController?

    var consumptionFeedType: ConsumptionFeedType?
    
    var castDataSource: [(title: String?, subtitle: String?, description: String?)]?
    var creatorsDataSource: [(title: String?, subtitle: String?, description: String?)]?
    var languagesSubtitlesDataSource: [(title: String?, subtitle: String?, description: String?)]?
    
    var currentPlayableItem: ZPPlayable? {
        willSet(newValue) {
            guard self.isViewLoaded else {
                return
            }
            
            if self.currentPlayableItem !== newValue || newValue == nil {
                self.itemNameLabel?.text = nil
                self.itemDescriptionLabel?.text = nil
                
                self.castDataSource = nil
                self.creatorsDataSource = nil
                self.languagesSubtitlesDataSource = nil
                
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
        }
        
        didSet {
            guard self.isViewLoaded else {
                return
            }
            
            if self.currentPlayableItem != nil {
                self.commonInit()
            }
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
                playerViewController.changePlayer(displayMode: .fullScreen) {
                    DownloadHelper.shared.transition(to: playerViewController.view)
                    if let shareViwController = shareViwController {
                        playerViewController.present(shareViwController, animated: false)
                    }

                }
            default:
                playerViewController.changePlayer(displayMode: .inline) {
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
        self.stylesConfiguration()
        
        self.itemNameLabel?.text = self.currentPlayableItem?.playableName()
        self.itemDescriptionLabel?.text = self.currentPlayableItem?.playableDescription()
        self.itemDescriptionLabel.isHidden = false
        
        setupModel()
        setupButtons()
        setupLabels()
        setupViews()
        
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
    
    func setupModel() {
        //setup feed type of consumption model
        if let atom = self.currentPlayableItem {
            if let type: String = atom.extensionsDictionary?["consumption_feed_type"] as? String {
                consumptionFeedType = ConsumptionFeedType.allCases.filter({ (feedType) -> Bool in
                    return feedType.rawValue.lowercased() == type
                }).first
            }
        }
    }
    
    func setupDataSources() {
        if castDataSource == nil && creatorsDataSource == nil && languagesSubtitlesDataSource == nil {
            
            guard let extensions = self.currentPlayableItem?.extensionsDictionary, let extaData = extensions[ExtensionsKey.extraData], let exta = extaData as? [String: Any] else {
                return
            }
            
            //populate cast data source
            castDataSource = []
            if let cast: [String: Any] = exta[ExtensionsKey.cast] as? [String : Any] {
                let allKeys = cast.keys
                allKeys.forEach({ (key) in
                    let values: [String] = cast[key] as! [String]
                    values.forEach({ (value) in
                        let components: [String] = value.components(separatedBy: ":")
                        castDataSource!.append((title: components.last, subtitle: nil, description: components.first))
                    })
                })
            }
            
            //populate creators data source
            creatorsDataSource = []
            if let creators: [String: Any] = exta[ExtensionsKey.creators] as? [String : Any] {
                let allKeys = creators.keys
                allKeys.forEach({ (key) in
                    let values: [String] = creators[key] as! [String]
                    values.forEach({ (value) in
                        creatorsDataSource!.append((title: key, subtitle: nil, description: value))
                    })
                })
            }
            
            //populate languages & subtitles data source
            languagesSubtitlesDataSource = []
            if let languages: [String] = exta[ExtensionsKey.languages] as? [String] {
                
                //setup languages info
                let title: String = "MoviesConsumption_MovieDetails_AudioLanguage_Text".localized(hashMap: [:])
                let subtitle: String = " \(languages.count > 0 ? languages.first! : "MoviesConsumption_SubtitlesSelection_Off_Selection".localized(hashMap: [:]))"
                
                var description: String = String()
                if languages.count == 1 || languages.count == 0  {
                    description = "MoviesConsumption_MovieDetails_AvailableInOneLanguage_Text".localized(hashMap: [
                        "count": "\(languages.count)"])
                } else if languages.count > 1 {
                    description = "MoviesConsumption_MovieDetails_AvailableInMultipleLanguages_Text".localized(hashMap: [
                        "count": "\(languages.count)"])
                }
                
                languagesSubtitlesDataSource!.append((title: title, subtitle: subtitle, description: description))
            }
            
            if let subtitles: [String] = exta[ExtensionsKey.subtitleLanguages] as? [String] {
                
                let title: String = "MoviesConsumption_MovieDetails_Subtitles_Text".localized(hashMap: [:])
                let subtitle: String = " \(subtitles.count > 0 ? subtitles.first! : "MoviesConsumption_SubtitlesSelection_Off_Selection".localized(hashMap: [:]))"
                
                var description: String = String()
                if subtitles.count == 1 || subtitles.count == 0  {
                    description = "MoviesConsumption_MovieDetails_AvailableInOneLanguage_Text".localized(hashMap: [
                        "count": "\(subtitles.count)"])
                } else if subtitles.count > 1 {
                    description = "MoviesConsumption_MovieDetails_AvailableInMultipleLanguages_Text".localized(hashMap: [
                        "count": "\(subtitles.count)"])
                }
                
                languagesSubtitlesDataSource!.append((title: title, subtitle: subtitle, description: description))
            }
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
        guard let playerView = self.playerView,
            let playerVC = self.kalturaPlayerController else {
                return
        }
        
        self.addChildViewController(playerVC , to: playerView)
        self.kalturaPlayerController?.changePlayer(displayMode: .inline)
        self.kalturaPlayerController?.currentDisplayMode = .inline
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
    
    private func addGestureRecognizerHandler() {
        guard let playerManager = ZPPlayerManager.sharedInstance.lastActiveInstance as? Zee5PluggablePlayer else {
            return
        }
        playerManager.addGesturePanDownHandler(closePlayer)
    }
}

extension HybridViewController: ZEE5PlayerDelegate {
    func didFinishPlaying() {
        self.closePlayer()
    }
}

extension HybridViewController {
    func showLoadingActivityIndicator() {
        kalturaPlayerController?.ShowIndicator(onParent: view)
    }
    
    func hideLoadingActivityIndicator() {
        kalturaPlayerController?.HideIndicator()
    }
}
