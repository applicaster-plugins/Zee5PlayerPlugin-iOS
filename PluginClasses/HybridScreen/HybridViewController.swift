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

public protocol hyBridViewControllerProtocol {
    func showMiniPlayer()
    func hyBridPlayerControlsView() -> (UIView & APPlayerControls)?
    func dismissSleepModeViewIfNeeded()
}

class HybridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, hybridCollectionViewFooter {

    var configurationJSON: NSDictionary?
    public var pluginStyles: [String : Any]?

    public var delegate: hyBridViewControllerProtocol!
    var currentPlayableItem: ZPPlayable?
    var playerControls: (UIView & APPlayerControls)?
    var playerViewController: Zee5PlayerViewController?
    var isPortraitUpsideDownOrientation: Bool?
    var templateLiveHeader : HybridCollectionViewLiveHeaderCell?
    var templateOnDemandHeader : HybridCollectionViewOnDemandHeaderCell?
    var sleepModeView: SleepModeView?

    public var isViewWillAppear = true

    private let cellReuseIdentifier = "hybridViewcell"
    private let headerCellLiveReuseIdentifier = "hybridViewLiveHeaderCell"
    private let headerCellOnDemandReuseIdentifier = "hybridViewOnDemandHeaderCell"
    private let footerCellReuseIdentifier = "hybridViewFooterCell"

    var dataSource:[Any] = []

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playerContainer: UIView?
    @IBOutlet weak var playerView: UIView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?

    // Info Player View
    @IBOutlet weak var lineView: UIView?
    @IBOutlet weak var logoImageView: UIImageView?
    @IBOutlet weak var liveLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel?

    // Info Program View
    @IBOutlet weak var infoProgramView: UIView?
    @IBOutlet weak var programHeaderLabel: UILabel?
    @IBOutlet weak var programTitleLabel: UILabel?

    // Info Program View
    @IBOutlet weak var moreButton: UIButton?

    // Sleep Mode
    var sleepModeCountDown: Int = 0

    // MARK: Extensions Properties

    var currentModel: NSObject?
    var live: Live?
    var onDemand: OnDemand?
    var recommendation: Recommendation?

    // Determined if the video is live
    var isLive: Bool {
        var retVal = false
        if let currentPlayableItem = self.currentPlayableItem as? APAtomEntryPlayable,
            let extensionsDictionary = currentPlayableItem.extensionsDictionary,
            (extensionsDictionary["live"] != nil) {
            retVal = true
        }
        return retVal
    }

    // Recommendations limit
    var recommendationsLimit: Int? {
        guard let configurationJSON = self.configurationJSON,
        let limit = configurationJSON["recommendations_limit"] as? String else {
            return nil
        }
        return Int(limit)
    }

    // UI Builder screen id to use for opening related feeds
    var showScreenId: String? {
        guard let configurationJSON = self.configurationJSON,
            let limit = configurationJSON["show_screen_id"] as? String else {
                return nil
        }
        return limit
    }

    // Image of item
    var imageItem: APImageView? {
        guard let currentPlayableItem = self.currentPlayableItem as? APAtomEntryPlayable,
            let mediaGroups = currentPlayableItem.mediaGroups else {
                return nil
        }
        var image: String? = nil
        if let mediaItem = APAtomMediaGroup.stringURL(fromMediaItems: mediaGroups, key: "image_base_16x9") {
            image = mediaItem
        }
        else if let mediaItem = APAtomMediaGroup.stringURL(fromMediaItems: mediaGroups, key: "image_base") {
            image = mediaItem
        }

        guard let imageName = image else {
            return nil
        }
        let imageView =  APImageView()
        imageView.contentMode = .center
        imageView.setImageWith(NSURL(string: imageName)! as URL, placeholderImage: Zee5ResourceHelper.imageNamed("placeholder_special_2"))
        return imageView
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
        if self.currentPlayableItem?.isAudioOnly == false && !ZAAppConnector.sharedInstance().chromecastDelegate.isSynced() && self.playerViewController?.playerController.isLoading == false {
            if UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
                self.isPortraitUpsideDownOrientation = true
            }
            else {
                self.isPortraitUpsideDownOrientation = false
            }
            if !UIDevice.current.orientation.isFlat {
             if UIDevice.current.orientation.isLandscape {
                 if self.isPortraitUpsideDownOrientation == false,
                    let mode = self.playerViewController?.currentDisplayMode,
                    mode != .mini {
                     self.delegate.dismissSleepModeViewIfNeeded()
                     self.playerViewController?.changePlayerDisplayMode(.fullScreen)
                 }
             } else {
                 if let mode = self.playerViewController?.currentDisplayMode,
                     mode != .mini,
                      self.isPortraitUpsideDownOrientation == false {
                     self.delegate.dismissSleepModeViewIfNeeded()
                     self.playerViewController?.changePlayerDisplayMode(.inline)
                 }
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

    override func viewWillAppear(_ animated: Bool) {
        self.isViewWillAppear = true
        if Thread.isMainThread {
            self.changeStatusBar(contentColor: .white, bgAlpha: 0.3)
        } else {
            DispatchQueue.main.sync {
                self.changeStatusBar(contentColor: .white, bgAlpha: 0.3)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.isViewWillAppear = false
        if Thread.isMainThread {
            self.changeStatusBar(contentColor: .black, bgAlpha: 0.0)
        } else {
            DispatchQueue.main.sync {
                self.changeStatusBar(contentColor: .black, bgAlpha: 0.0)
            }
        }
    }

    func commonInit() {
        self.stylesConfiguration()
        self.extensionConfiguration()

        self.activityIndicator?.isHidden = false
        self.activityIndicator?.startAnimating()

        self.observer()

        self.collectionView.register(UINib.init(nibName: "HybridCollectionViewCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: cellReuseIdentifier)

        if self.isLive == true {
            let nib = UINib(nibName: "HybridCollectionViewLiveHeaderCell", bundle:Bundle(for: HybridCollectionViewLiveHeaderCell.self))
            self.templateLiveHeader = (nib.instantiate(withOwner: nil, options:nil)[0] as! HybridCollectionViewLiveHeaderCell)

            self.collectionView.register(UINib.init(nibName: "HybridCollectionViewLiveHeaderCell", bundle: Bundle(for: type(of: self))), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerCellLiveReuseIdentifier)

            self.reloadNextProgram()
        }
        else {
            let nib = UINib(nibName: "HybridCollectionViewOnDemandHeaderCell", bundle:Bundle(for: HybridCollectionViewOnDemandHeaderCell.self))
            self.templateOnDemandHeader = (nib.instantiate(withOwner: nil, options:nil)[0] as! HybridCollectionViewOnDemandHeaderCell)

            self.collectionView.register(UINib.init(nibName: "HybridCollectionViewOnDemandHeaderCell", bundle: Bundle(for: type(of: self))), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerCellOnDemandReuseIdentifier)
        }

        self.collectionView.register(UINib.init(nibName: "HybridCollectionViewFooterCell", bundle: Bundle(for: type(of: self))), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerCellReuseIdentifier)

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        self.isPortraitUpsideDownOrientation = false

        Zee5AnalyticsManager.shared.playerEnter()
        observerAnalytics()
        setupBackgroundMediaPlayerNotificationView()

        self.playerConfiguration()

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.playerView?.addGestureRecognizer(panGestureRecognizer)
    }

    var originalPosition: CGPoint?
    var currentPositionTouched: CGPoint?

    @objc func changePlayerDisplayToMini() {
        self.playerViewController?.changePlayerDisplayMode(.mini)
    }

    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let velocity = panGesture.velocity(in: view)
        let currentPositionTouched = panGesture.location(in: view)

        if self.playerViewController?.playerController.isLoading == false,
            velocity.y >= 0,
            let playerViewBottom = self.playerView?.bottom,
            currentPositionTouched.y < (playerViewBottom * 4/5) {
            self.playerViewController?.changePlayerDisplayMode(.mini)
        }
//        let translation = panGesture.translation(in: view)

//        if panGesture.state == .began {
//            originalPosition = view.center
//            currentPositionTouched = panGesture.location(in: view)
//        } else if panGesture.state == .changed {
//            view.frame.origin = CGPoint(
//                x: 0.0,
//                y: translation.y
//            )
//        } else if panGesture.state == .ended {
//            let velocity = panGesture.velocity(in: view)
//
//            if velocity.y >= 1500 {
//                UIView.animate(withDuration: 0.2
//                    , animations: {
//                        self.view.frame.origin = CGPoint(
//                            x: 0.0,
//                            y: self.view.frame.size.height
//                        )
//                }, completion: { (isCompleted) in
//                    if isCompleted {
////                        self.removeViewFromParentViewController()
//                        self.playerViewController?.changePlayerDisplayMode(.mini)
//                    }
//                })
//            } else {
//                UIView.animate(withDuration: 0.2, animations: {
//                    self.view.center = self.originalPosition!
//                })
//            }
//        }
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

//        NotificationCenter.default.removeObserver(
//            self,
//            name: NSNotification.Name(rawValue: "APApplicasterPlayerStartSleepModeNotification"),
//            object: nil)
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(showSleepModeView),
//            name: NSNotification.Name(rawValue: "APApplicasterPlayerStartSleepModeNotification"),
//            object: nil)
//
//        NotificationCenter.default.removeObserver(
//            self,
//            name: NSNotification.Name(rawValue: "APApplicasterPlayerMiniCloseNotification"),
//            object: nil)
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(miniPlayerClose),
//            name: NSNotification.Name(rawValue: "APApplicasterPlayerMiniCloseNotification"),
//            object: nil)

    }

    func observerAnalytics() {

        // Pause button tapped
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: kControlsPauseButtonTapped),
            object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(pauseButtonTapped),
                                               name: NSNotification.Name(rawValue: kControlsPauseButtonTapped),
                                               object: nil)

        // Pause notification
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "APPlayerDidPauseNotification"),
            object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(pauseNotification),
                                               name: NSNotification.Name(rawValue: "APPlayerDidPauseNotification"),
                                               object: nil)


        // Resume
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: kControlsPlayButtonTapped),
            object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playButtonTapped),
                                               name: NSNotification.Name(rawValue: kControlsPlayButtonTapped),
                                               object: nil)

        // Play notification
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "APPlayerDidPlayNotification"),
            object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playNotification),
                                               name: NSNotification.Name(rawValue: "APPlayerDidPlayNotification"),
                                               object: nil)

        // Full screen
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "kControlsExpandButtonTapped"),
            object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fullScreenButtonTapped),
                                               name: NSNotification.Name(rawValue: "kControlsExpandButtonTapped"),
                                               object: nil)

        // Share
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "PlayerShareNotification"),
            object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(shareButtonTapped),
                                               name: NSNotification.Name(rawValue: "PlayerShareNotification"),
                                               object: nil)

    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfRows = dataSource.count
        if let limit = self.recommendationsLimit {
            numberOfRows = min(limit, dataSource.count)
        }
        return numberOfRows
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        return CGSize(width:width, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)

        if let cell = cell as? HybridCollectionViewCell,
            let atomEntry = self.dataSource[indexPath.row] as? APAtomEntryProtocol
        {
            cell.setAtomEntry(atomEntry: atomEntry,pluginStyles: pluginStyles)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:

            if self.isLive == true {
                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerCellLiveReuseIdentifier, for: indexPath) as! HybridCollectionViewLiveHeaderCell
                reusableview.set(model: self.live, pluginStyles:pluginStyles)
                if let recommendationTitleLabel = reusableview.recommendationTitleLabel,
                    let recommendation = self.recommendation {
                    recommendationTitleLabel.text = recommendation.title
                }
                reusableview.setNeedsUpdateConstraints()
                reusableview.updateConstraintsIfNeeded()
                reusableview.setNeedsLayout()
                reusableview.layoutIfNeeded()
                return reusableview
            }
            else {
                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerCellOnDemandReuseIdentifier, for: indexPath) as! HybridCollectionViewOnDemandHeaderCell
                reusableview.set(model: self.onDemand, pluginStyles: pluginStyles)
                if let recommendationTitleLabel = reusableview.recommendationTitleLabel,
                    let recommendation = self.recommendation {
                    recommendationTitleLabel.text = recommendation.title
                }
                reusableview.setNeedsUpdateConstraints()
                reusableview.updateConstraintsIfNeeded()
                reusableview.setNeedsLayout()
                reusableview.layoutIfNeeded()
                return reusableview

            }

        case UICollectionView.elementKindSectionFooter:
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerCellReuseIdentifier, for: indexPath) as! HybridCollectionViewFooterCell
            reusableview.delegate = self
            if let recommendation = self.recommendation,
                let title = recommendation.moreTitle {
                reusableview.setData(title: title, pluginStyles: pluginStyles)
            }
            return reusableview

        default:  fatalError("Unexpected element kind")
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        if #available(iOS 11.0, *) {
            if self.isLive == true,
                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerCellLiveReuseIdentifier, for: IndexPath(item: 0, section: 0)) as? HybridCollectionViewLiveHeaderCell {
                reusableview.set(model: self.live, pluginStyles: pluginStyles)

                reusableview.setNeedsUpdateConstraints()
                reusableview.updateConstraintsIfNeeded()
                reusableview.setNeedsLayout()
                reusableview.layoutIfNeeded()

                var targetSize = UIView.layoutFittingCompressedSize
                targetSize.width = collectionView.bounds.size.width
                let computedSize = reusableview.systemLayoutSizeFitting(targetSize,
                                                                        withHorizontalFittingPriority: .required,
                                                                        verticalFittingPriority: .defaultLow)
                return computedSize

            }
            else if let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerCellOnDemandReuseIdentifier, for: IndexPath(item: 0, section: 0)) as? HybridCollectionViewOnDemandHeaderCell {
                reusableview.set(model: self.onDemand, pluginStyles: pluginStyles)

                reusableview.setNeedsUpdateConstraints()
                reusableview.updateConstraintsIfNeeded()
                reusableview.setNeedsLayout()
                reusableview.layoutIfNeeded()

                var targetSize = UIView.layoutFittingCompressedSize
                targetSize.width = collectionView.bounds.size.width
                let computedSize = reusableview.systemLayoutSizeFitting(targetSize,
                                                                        withHorizontalFittingPriority: .required,
                                                                        verticalFittingPriority: .defaultLow)
                return computedSize
            }
            else{
                return CGSize(width: self.collectionView.width , height: 220.0)
            }
        } else {
            return CGSize(width: self.collectionView.width , height: (self.isLive == true ? 180.0 : 220.0))
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        let height: CGFloat = (self.recommendation?.moreLink != nil ? 50.0 : 0.0)
        return CGSize(width: self.collectionView.width , height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let atomEntry = self.dataSource[indexPath.row] as? APAtomEntry {
            if atomEntry.entryType == .video ||  atomEntry.entryType == .channel || atomEntry.entryType == .audio {
                if let playable = atomEntry.playable() {
                    if let p = atomEntry.parentFeed,
                        let pipesObject = p.pipesObject {
                        playable.pipesObject = pipesObject as NSDictionary
                    }
                    if atomEntry.content.type == "youtube-id",
                        let playerVC = self.playerViewController {
                        self.dismiss(animated: true) {
                            playerVC.stop()
                            self.playerViewController = nil
                            playable.play()
                        }
                    }
                    else {
                        playable.play()
                    }
                }
            }
            else if atomEntry.entryType == .link {
                if let urlstring = atomEntry.link,
                    let linkURL = URL(string: urlstring),
                    APUtils.shouldOpenURLExternally(linkURL) {
                    self.playerViewController?.changePlayerDisplayMode(.mini)
                    self.dismiss(animated: true) {
                        UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
                    }
                }
            }
        }
        else if let atomFeed = self.dataSource[indexPath.row] as? APAtomFeed {
            // Open atom feed with url scheme
            guard let urlScheme = ZAAppConnector.sharedInstance().urlDelegate.appUrlSchemePrefix(),
                let screenId = self.getScreenType(model: atomFeed),
                let source = atomFeed.link,
                let base64Encoded = APCoreUtils.toBase64(source) else {
                    return
            }

            //            <scheme-prefix>://present?screen_id=<screen_id>&data_source=<data_source>&source_type=<source_type>
            let urlstring = String(format: "%@://present?screen_id=%@&data_source=%@",urlScheme, screenId, base64Encoded)

            if let  linkURL = URL(string: urlstring),
                APUtils.shouldOpenURLExternally(linkURL) {
                self.playerViewController?.changePlayerDisplayMode(.mini)
                UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
            }
        }
    }

    public func replacePluggablePlayer(playableItem item: ZPPlayable?) {
        if self.playerViewController != nil,
            let item = item {
            self.currentPlayableItem = item
            self.playerViewController?.stop()
            self.playerViewController = Zee5PlayerViewController(playableItem: [item] as? ZPPlayable)
        }
    }

    // MARK:

    func extensionConfiguration() {

        if let currentPlayableItem = self.currentPlayableItem as? APAtomEntryPlayable,
            let extensionsDictionary = currentPlayableItem.extensionsDictionary {

            if let liveExtension = extensionsDictionary["live"] as? [String:Any],
            let liveModel = Live.init(object: liveExtension) as? Live {
                if let configurationJSON = self.configurationJSON,
                    let nextProgramTitle = configurationJSON["next_program_title"] as? String {
                    liveModel.nextProgramTitle = nextProgramTitle
                }
                if let isDigital = extensionsDictionary["is_digital_radio"] as? Bool {
                    liveModel.isDigitalRadio = isDigital
                    liveModel.entryTitle = self.currentPlayableItem?.playableDescription()
                }
                currentModel = liveModel
                self.live = liveModel
            }

            if let recommendationExtension = extensionsDictionary["recommendation"] as? [String:Any],
                let recommendationModel = Recommendation.init(object: recommendationExtension) as? Recommendation {
                self.recommendation = recommendationModel
            }

            if let onDemandExtension = extensionsDictionary["on_demand"] as? [String:Any],
                let onDemandModel = OnDemand.init(object: onDemandExtension) as? OnDemand {
                if let publishDate = currentPlayableItem.publishDate {
                    onDemandModel.publishDate = publishDate
                }
                currentModel = onDemandModel
                self.onDemand = onDemandModel
            }
        }

    }

    func stylesConfiguration() {
        StylesHelper.setColorforView(view: self.view, key: "player_screen_bg_color", from: pluginStyles)
    }

    public func playerConfiguration() {
        guard let playerView = self.playerView,
            let playerVC = self.playerViewController,
            let playerController = playerVC.playerController else {
                return
        }
        if let configurationJSON = configurationJSON,
            let skipInterval = configurationJSON["skip_interval"] as? String {
            playerVC.skipInterval = skipInterval
        }
        // set the 'presentation style' of playerViewcontroller to Full Screen, then the supportedInterface override will get called. (iOS13)
        playerVC.modalPresentationStyle = .fullScreen
        playerVC.currentPlayerDisplayMode = .inline
        // set the video loading view
        playerVC.playerController.loadingView = self.videoLoadingView()
        // set the player controls
        playerVC.controls = self.playerViewController?.hyBridPlayerControls()
        // add the player view controller on the container view
        self.addChildViewController(playerVC , to: playerView)
        // set audio image on the player controller view
        if playerVC.playerController.currentItem.isAudioOnly == true,
            let imageItem = self.imageItem {
            imageItem.frame = playerVC.playerController.view.frame
            playerVC.playerController.player.view.insertSubview(imageItem, belowSubview: playerVC.playerController.player.playerView)
            imageItem.matchParent()

        }
        // Set current model
        playerVC.currentZee5PlableModel = currentModel
        // set the persistent resume
        playerController.alwaysResumeLastPlayingTime = true
        playerController.shouldIgnoreInterruptScreen = true
        // load related content
        if let recommendation = self.recommendation,
            let src = recommendation.src {
            self.loadRelatedContent(stringURL: src)
        }

        Zee5AnalyticsManager.shared.sendEvent(action: .play, playerType: .regularPlayer , itemType: .native, zee5Player: self.playerViewController)
        startObserveProgress()
//        self.playerViewController?.sleepModeConfiguration(self.sleepModeCountDown)
    }

//    // Info view in the
//    func infoPlayerViewConfiguration() {
//        if let lineView = self.lineView {
//            lineView.backgroundColor = UIColor.white
//        }
//
//        if let logoImageView = self.logoImageView,
//            let image = UIImage(named: "kanicon_header.png", in: Bundle(for: type(of: self)), compatibleWith: nil) {
//            logoImageView.image = image
//        }
//
//        if let playerVC = self.playerViewController,
//            let playerController = playerVC.playerController {
//
//            if let liveLabel = self.liveLabel {
//                liveLabel.isHidden = !self.isLive
//
//                guard let extensions = self.currentPlayableItem?.extensionsDictionary else {
//                    return
//                }
//
//                // Needs to take the default color from zapp
//                var liveColorString = "#008F9FFF"
//                if let colorString = extensions["player_channel_brand_color"] as? String {
//                    liveColorString = colorString
//                }
//                self.liveLabel?.backgroundColor = self.hexStringToUIColor(hex: liveColorString)
//            }
//
//            if let titleLabel = self.titleLabel,
//                let item = playerController.currentItem,
//                let title = item.playableName() {
//                titleLabel.text = title
//            }
//
//            if let item = playerController.currentItem,
//                let infoProgramView = self.infoProgramView {
//                infoProgramView.isHidden = !item.isLive()
//            }
//        }
//    }

    func infoProgramViewConfiguration() {
        if let titleLabel = self.programTitleLabel,
            let program = self.currentPlayableItem as? APProgramProtocol {
            titleLabel.text = program.name
        }
    }

    func moreContentButtonConfiguration() {
        if let morebutton = self.moreButton,
            let recommendation = self.recommendation,
            let title = recommendation.moreTitle {
            morebutton.setTitle(title, for: .normal)
            morebutton.setTitle(title, for: .highlighted)
        }
    }

    public func updatePlayerConfiguration() {
        self.extensionConfiguration()
        self.playerConfiguration()
    }

    func reloadNextProgram() {
        if let live = self.live,
            let programs = live.programs,
            programs.count > 0,
            let currentProgram = programs[0] as? Program,
            let endTime = currentProgram.endTime {

            let timestamp = Date().timeIntervalSince1970
            let dif = endTime - Int(timestamp)
            if dif > 0 {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateNextProgramData), object: nil)
                perform(#selector(updateNextProgramData), with: nil, afterDelay: TimeInterval(dif))
            }
        }
    }

    @objc func updateNextProgramData() {
        if let live = self.live,
            let programs = live.programs,
            let reusableview = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? HybridCollectionViewLiveHeaderCell {
            let currentProgram: Program = programs[1]
            if let programNameLabel = reusableview.programNameLabel {
                programNameLabel.text = currentProgram.title
            }
            let nextProgram: Program = programs[2]
            if let nextProgramNameLabel = reusableview.nextProgramNameLabel {
                nextProgramNameLabel.text = nextProgram.title
            }
            if let nextProgramTimeLabel = reusableview.nextProgramTimeLabel,
                let startTime = nextProgram.startTime,
                let endTime = nextProgram.endTime {

                let startTimeDate = NSDate(timeIntervalSince1970: TimeInterval(startTime))
                let endTimeDate = NSDate(timeIntervalSince1970: TimeInterval(endTime))

                nextProgramTimeLabel.text = String(format: "%@ - %@", endTimeDate.getTimeAsString() ,startTimeDate.getTimeAsString())
            }
            reusableview.setNeedsUpdateConstraints()
            reusableview.updateConstraintsIfNeeded()
            reusableview.setNeedsLayout()
            reusableview.layoutIfNeeded()

            if let channelSrc = live.src {
                self.loadNextChannel(stringURL: channelSrc)
            }
        }
    }
    // MARK: Video Loading View

    public func videoLoadingView() -> (UIView & APLoadingView)? {
        var loadingView: (UIView & APLoadingView)?

        if let videoLoadingView = (Bundle(for: HybridViewController.self).loadNibNamed("Zee5VideoLoadingView", owner: self, options: nil)?.first) {
            loadingView = videoLoadingView as? UIView & APLoadingView
        }
        return loadingView
    }

    //MARK - Related Content

    func loadRelatedContent(stringURL: String?) {
        if let atomFeed = APAtomFeed.init(url: stringURL) {
            APAtomFeedLoader.loadPipes(model: atomFeed) { [weak self] (success, atomFeed) in
                if success,
                    let atomFeed = atomFeed,
                    let entries = atomFeed.entries,
                    entries.count > 0 {
                    self?.dataSource = entries
                    self?.activityIndicator?.isHidden = true
                    self?.activityIndicator?.stopAnimating()
                    self?.collectionView.reloadData()
                    self?.collectionView.collectionViewLayout.invalidateLayout()
                }
            }
        }
    }

    func loadNextChannel(stringURL: String?) {
        if let atomFeed = APAtomFeed.init(url: stringURL) {
            APAtomFeedLoader.loadPipes(model: atomFeed) { [weak self] (success, atomFeed) in
                if success,
                    let atomFeed = atomFeed,
                    let entries = atomFeed.entries,
                    entries.count > 0 {
                    print("entries \(entries)")

                    for index in 0...entries.count-1 {
                        if let entry = entries[index] as? APAtomEntry,
                        let identifier = entry.identifier,
                            let currentItemId = self?.currentPlayableItem?.identifier {
                            print("idebtifier \(identifier)")
                            print("currentItemId \(currentItemId)")

                        if (currentItemId.isEqual(to: identifier))  {
                            if let playable = entry.playable() {
                                self?.currentPlayableItem = playable
                                self?.extensionConfiguration()
                                self?.reloadNextProgram()
                                break
                             }
                         }
                       }
                    }
                }
            }
        }
    }

    func getScreenType(model: APAtomFeed?) -> String? {
        var retVal: String? = nil
        if let model = model,
            let screenType = model.screenType {
            retVal = screenType
        }
        else if let showScreenId = self.showScreenId {
            retVal = showScreenId
        }
        return retVal
    }

    // MARK: hybridCollectionViewFooter

    func loadMoreRelatedContent() {
        if let recommendation = self.recommendation,
            let urlstring = recommendation.moreLink,
            let linkURL = URL(string: urlstring),
            APUtils.shouldOpenURLExternally(linkURL) {
            self.playerViewController?.changePlayerDisplayMode(.mini)
            UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
        }
    }

    // MARK: statusbar configuration

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if isViewWillAppear == true {
            return .lightContent
        }
        else if #available(iOS 13.0, *) {
            return .darkContent
        }
        return .default
    }

   func changeStatusBar(contentColor: UIColor, bgAlpha: CGFloat) {
        if #available(iOS 13.0, *) {
            let tag = 12321
            if let window = UIApplication.shared.keyWindow,
                let taggedView = window.viewWithTag(tag) {
                taggedView.removeFromSuperview()
            }
            let statusBar = UIView()
            statusBar.frame = UIApplication.shared.statusBarFrame
            statusBar.backgroundColor = .clear
            statusBar.tag = tag
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        }
        else {
            if let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView {
                statusBar.setValue(contentColor, forKey: "foregroundColor")
            }
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: Analytics

    func startObserveProgress() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(self.observeProgress), with: nil, afterDelay: 60.0)
    }

    @objc func observeProgress() {
        if stateFromPlayerPhase() == .playing {
            Zee5AnalyticsManager.shared.sendEvent(action: .progress, playerType: playerType(), itemType: .native, zee5Player: playerViewController)
        }
        self.perform(#selector(self.observeProgress), with: nil, afterDelay: 60.0)
    }

    @objc func pauseButtonTapped() {
        Zee5AnalyticsManager.shared.sendEvent(action: .pause, playerType: playerType(), itemType: .native, zee5Player: playerViewController)
    }

    @objc func pauseNotification() {
        Zee5AnalyticsManager.shared.pauseButtonClicked()
    }

    @objc func playButtonTapped() {
        Zee5AnalyticsManager.shared.sendEvent(action: .resume, playerType: playerType(), itemType: .native, zee5Player: playerViewController)
    }

    @objc func playNotification() {
        Zee5AnalyticsManager.shared.resumeButtonClicked()
    }

    @objc func fullScreenButtonTapped() {
        Zee5AnalyticsManager.shared.sendEvent(action: .moveToFullScreen, playerType: playerType(), itemType: .native, zee5Player: playerViewController)
    }

    @objc func shareButtonTapped() {
        Zee5AnalyticsManager.shared.sendEvent(action: .share, playerType: .backgroundPlayer, itemType: .native,  zee5Player: playerViewController)
    }

    func  setupBackgroundMediaPlayerNotificationView() {
        let commandCenter =  MPRemoteCommandCenter.shared()
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            Zee5AnalyticsManager.shared.sendEvent(action: .resume, playerType: .backgroundPlayer, itemType: .native, zee5Player: self.playerViewController)
            return .success
        }
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            Zee5AnalyticsManager.shared.sendEvent(action: .pause, playerType: self.playerType(), itemType: .native, zee5Player: self.playerViewController)
            return .success
        }
    }

    func playerType() -> Zee5AnalyticsManager.PlayerType {
        var retval:Zee5AnalyticsManager.PlayerType = .regularPlayer

        if let currentPlayerMode = self.playerViewController?.currentDisplayMode {
            if (currentPlayerMode == .mini) {
                retval = .miniPlayer
            }
            else {
                retval = .regularPlayer
            }
        }
        return retval
    }


    fileprivate func stateFromPlayerPhase() -> ZPPlayerState {
        var result: ZPPlayerState = .undefined

        guard let playerViewController = playerViewController,
            let player = playerViewController.playerController.player else {
            return result
        }

        switch player.playbackState {
        case APMoviePlaybackStatePlaying,
             APMoviePlaybackStateSeekingManually,
             APMoviePlaybackStateSeekingForward,
             APMoviePlaybackStateSeekingBackward:
            result = .playing

        case APMoviePlaybackStateInterrupted:
            result = .interruption

        case APMoviePlaybackStatePaused:
            result = .paused

        case APMoviePlaybackStateStopped:
            result = .stopped
        default:
            break
        }

        return result
    }
}
