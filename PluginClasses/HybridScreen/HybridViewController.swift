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

enum ConsumptionFeedType: String, CaseIterable {
    case movie = "Movie"
    case episode = "Episode"
    case news = "News"
    case music = "Music"
    case live = "Live"
    case trailer = "Trailer"
    case show = "Show"
    case original = "Original"
}

struct ExtensionsKey {
    static let consumptionFeedType = "consumption_feed_type"
    static let isFree = "isFree"
    static let trailerDeeplink = "trailer_deeplink"
    static let playProgress = "playProgress"
    static let promotedUrl = "promoted_url"
    static let durationDate = "durationDate"
    static let assetType = "asset_type"
    static let rating = "rating"
    static let extraData = "extra_data"
    static let releaseYear = "release_year"
    static let duration = "duration"
    static let mainGenre = "main_genre"
    static let genres = "genres"
    static let ageRating = "age_rating"
    static let seasonDetails = "season_details"
    static let currentEpisode = "current_episode"
    static let totalEpisodes = "total_episodes"
    static let contentOwner = "content_owner"
    static let leftDuration = "leftDuration"
    static let numberTagText = "numberTagText"
    static let upNext = "upNext"
    static let openWithPluginId = "open_with_plugin_id"
    static let cast = "cast"
    static let creators = "creators"
    static let languages = "languages"
    static let subtitleLanguages = "subtitle_languages"
    static let primaryCategory = "primary_category"
    static let isReminder = "is_reminder"
    static let releaseDate = "release_date"
    static let screenName = "screen_name"
    static let itemDetailsUrl = "item_details_url"
}

public struct ItemTag {
    struct Button {
        static let playImage = 109
        static let clearButton = 110
        static let getPremiumButton = 111
        static let searchBarCleanButton = 116
        static let searchBarBackButton = 117
        static let consumptionMoreButton = 117
        
        static let shareButton = 806
        static let watchlistButton = 807
        static let castButton = 808
        static let downloadButton = 809
        static let trailerButton = 810
        
        static let consumptionMoreLessDescriptionButton = 823
        
        static let reminderButton = 824
    }
    struct Image {
        static let premiumImage = 112
        static let top10Image = 113
    }
    struct View {
        static let progressBarView = 114
        static let searchBarTextField = 118
        
        static let consumptionCastCollection = 827
        static let consumptionCastCollectionStackView = 828
        static let consumptionCreatorCollection = 830
        static let consumptionCreatorCollectionStackView = 831
        static let consumptionLanguagesSubtitlesCollection = 855
        static let consumptionLanguagesSubtitlesCollectionStackView = 856
        static let consumptionVideoContainerView = 857
        
        static let consumptionContentView = 870
        static let consumptionButtonsView = 871
        static let consumptionRelatedVideosView = 872

    }
    struct Label {
        
        static let searchBarErrorLabel = 837
        
        static let numberTagLabel = 115
        static let timeLeftLabel = 119
        static let episodeNumberAndDateLabel = 120
        static let upNextLabel = 121
        static let timeFromToLabel = 122
        
        static let consumptionTitleLabel = 800
        static let consumptionMainInfoLabel = 801
        static let consumptionIMDBRatingLabel = 802
        static let consumptionAvailableInLabel = 803
        static let consumptionDescriptionLabel = 825
        static let consumptionCastLabel = 804
        static let consumptionCreatorsLabel = 805
        
        static let releasingOnLabel = 835
        static let storyLineLabel = 836
    }
}

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
    @IBOutlet var buttonsViewCollection: [UIButton]?
    @IBOutlet var viewCollection: [UIView]?
    @IBOutlet var labelsCollection: [UILabel]?
    
    @IBOutlet weak var itemNameLabel: UILabel?
    @IBOutlet weak var itemDescriptionLabel: UILabel?
    
    var consumptionFeedType: ConsumptionFeedType?
    var consumptionContentView: UIView?
    
    var castDataSource: [(title: String?, subtitle: String?, description: String?)]?
    var creatorsDataSource: [(title: String?, subtitle: String?, description: String?)]?
    var languagesSubtitlesDataSource: [(title: String?, subtitle: String?, description: String?)]?
     
    
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
        StylesHelper.setColorforView(view: self.view, key: "player_screen_bg_color", from: pluginStyles)
    }
    
    
    public func kalturaPlayerConfiguration() {
        guard let playerView = self.playerView,
            let playerVC = self.kalturaPlayerController else {
                return
        }
        self.addChildViewController(playerVC , to: playerView)
        //        playerVC.loadViewIfNeeded()
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
