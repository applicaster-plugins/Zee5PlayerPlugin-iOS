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


class HybridViewController: UIViewController {
    
    var configurationJSON: NSDictionary?
    public var pluginStyles: [String : Any]?
    
    var kalturaPlayerController: KalturaPlayerController?
    
    var isPortraitUpsideDownOrientation: Bool?
    public var isViewWillAppear = true
    private var circularRing = UICircularProgressRing()
    var dataSource:[Any] = []
    private let bundle = Bundle(for: DownloadRootController.self)
    
    @IBOutlet weak var playerContainer: UIView?
    @IBOutlet weak var playerView: UIView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var buttonsViewCollection: [UIButton]?
    @IBOutlet var viewCollection: [UIView]?
    @IBOutlet var labelsCollection: [UILabel]?
    @IBOutlet weak var viewProgress: UIView!
    @IBOutlet weak var viewPause: UIView!
    
    @IBOutlet weak var itemNameLabel: UILabel?
    @IBOutlet weak var itemDescriptionLabel: UILabel?
    
    var consumptionFeedType: ConsumptionFeedType?
    var consumptionContentView: UIView?
    
    var castDataSource: [(title: String?, subtitle: String?, description: String?)]?
    var creatorsDataSource: [(title: String?, subtitle: String?, description: String?)]?
    var languagesSubtitlesDataSource: [(title: String?, subtitle: String?, description: String?)]?
     
    var currentPlayableItem: ZPPlayable? {
        didSet {
            if self.currentPlayableItem != nil {
                self.view.isHidden = false
                self.commonInit()
            }
        }
    }
    
    var currentItem: DownloadItem? {
        didSet {
            
            // For show/episodes
            
            
            let firstNegative = buttonsViewCollection?.first(where: { $0.tag ==  ItemTag.Button.downloadButton})
//
//            if self.currentItem?.downloadState == .inProgress {
////                self.lblDownloading.text = "Downloading..."
//            }
//            else if self.currentItem?.downloadState == .paused {
//                self.lblDownloading.text = "Paused"
//            }
//            else if self.currentItem?.downloadState == .expired {
//                self.lblDownloading.text = "Download Expired"
//            }
            
            // Checking download state image and progress bar
            if self.currentItem?.downloadState == .inProgress {
                self.viewProgress.isHidden = false
                if let firstNegative = buttonsViewCollection?.first(where: { $0.tag ==  ItemTag.Button.downloadButton}){
                firstNegative.isHidden = false}
                
                self.viewPause.isHidden = true
            }
            else {
                if let firstNegative = buttonsViewCollection?.first(where: { $0.tag ==  ItemTag.Button.downloadButton}){
                    firstNegative.isHidden = false}
                self.viewProgress.isHidden = true
                self.viewPause.isHidden = true
                
                if self.currentItem?.downloadState == .completed {
                    if #available(iOS 13.0, *) {
                        let img = UIImage(named: "complete_download", in: bundle, with: nil)
                        firstNegative!.setImage(img, for: .normal)
                    } else {
                        // Fallback on earlier versions
                        let ab = UIImage(named: "complete_download", in: bundle, compatibleWith: nil)
                        firstNegative!.setImage(ab, for: .normal)
                    }
                }
                else if self.currentItem?.downloadState == .failed || self.currentItem?.downloadState == .interrupted || self.currentItem?.downloadState == .dbFailure || self.currentItem?.downloadState == .expired {
                    if #available(iOS 13.0, *) {
                        let img = UIImage(named: "error_download", in: bundle, with: nil)
                        firstNegative!.setImage(img, for: .normal)
                    } else {
                        // Fallback on earlier versions
                        let ab = UIImage(named: "error_download", in: bundle, compatibleWith: nil)
                        firstNegative!.setImage(ab, for: .normal)
                    }
                }
                else
            if self.currentItem?.downloadState == .paused {
                    if let firstNegative = buttonsViewCollection?.first(where: { $0.tag ==  ItemTag.Button.downloadButton}){
                    firstNegative.isHidden = false}
                    self.viewProgress.isHidden = false
                    self.viewPause.superview?.isHidden = false
                    self.viewPause.isHidden = false
                }
            }

            // Upadating progress bar
            if let downloadedBytes = self.currentItem?.downloadedBytes, let estimatedBytes = self.currentItem?.estimatedBytes, estimatedBytes > 0 {
                let percentage = CGFloat(downloadedBytes) / CGFloat(estimatedBytes) * CGFloat(100)
                
                if self.currentItem?.downloadState == .completed {
                    self.circularRing.value = 100
                }
                else if let size = self.currentItem?.estimatedBytes, size > 0 {
                    self.circularRing.value = percentage
                }
                else {
                    self.circularRing.value = 0
                }
            }
        }
    }
    
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
        
        if self.currentPlayableItem == nil {
            self.view.isHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard self.currentPlayableItem != nil, consumptionContentView != nil else {
            return
        }
        
        NotificationCenter.default.post(name: Notification.Name("kConsumptionCellLayoutHeightChangedNotification"), object: consumptionContentView!.frame.size.height)
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
        
        self.itemNameLabel?.text = self.currentPlayableItem?.playableName()
        self.itemDescriptionLabel?.text = self.currentPlayableItem?.playableDescription()
        
        setupModel()
        setupButtons()
        setupLabels()
        setupViews()
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
