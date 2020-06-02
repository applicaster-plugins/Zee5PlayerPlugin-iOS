//
// Zee5PluggablePlayer.swift
// Zee5PluggablePlayer
//
// Created by Miri on 19/12/2018.
//
import ApplicasterSDK
import ZappPlugins
import UIKit
import Zee5CoreSDK

fileprivate extension Notification.Name {
    static let contentIdUpdatedNotification = Notification.Name("ContentIdUpdatedNotification")
    static let refreshRequiredNotification = Notification.Name("ReloadConsumption")
}

public class Zee5PluggablePlayer: APPlugablePlayerBase, ZPAdapterProtocol {
    public var pluginStyles: [String : Any]?
    
    var hybridViewController: HybridViewController?
    var currentPlayableItem: ZPPlayable?
    var shouldDissmis: Bool = true
    
    var kalturaPlayerController: KalturaPlayerController?
    private var pluginModel: ZPPluginModel?
    private var screenModel: ZLScreenModel?
    private var dataSourceModel: NSObject?
    
    fileprivate var contentIdNotificationToken: Any?
    fileprivate var refreshRequiredNotificationToken: Any?

    fileprivate var contentId: String? = nil
    
    // MARK: - Lifecycle
    
    public required init?(pluginModel: ZPPluginModel, screenModel: ZLScreenModel, dataSourceModel: NSObject?) {
        self.pluginModel = pluginModel
        self.screenModel = screenModel
        self.dataSourceModel = dataSourceModel
        
        super.init()
    }
    
    deinit {
        if let contentIdNotificationToken = self.contentIdNotificationToken {
            NotificationCenter.default.removeObserver(contentIdNotificationToken)
        }
        
        if let refreshRequiredNotificationToken = self.refreshRequiredNotificationToken {
            NotificationCenter.default.removeObserver(refreshRequiredNotificationToken)
        }
    }
    
    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?, configurationJSON: NSDictionary?) -> ZPPlayerProtocol? {
        guard let videos = items, let playable = videos.first else {
            return nil
        }
        
        Zee5DownloadManager.shared.initializeDownloadManger()
        
        var errorViewConfig: ErrorViewConfiguration?
        if let configuration = configurationJSON {
            errorViewConfig = ErrorViewConfiguration(fromDictionary: configuration)
            
            //prepare ads envirnoment from the plugin configurations
            if let isProdAdsEnvirnoment = configurationJSON!["is_ads_production"] as? Int {
                ZEE5PlayerSDK.setAdsEnvirnoment(isProdAdsEnvirnoment == 1 ? prod : staging)
            }
        }
                
        let instance: Zee5PluggablePlayer
        
        // Hybrid presented
        if let lastActiveInstance = Zee5PluggablePlayer.lastActiveInstance() {
            instance = lastActiveInstance
        }
        else {
            instance = Zee5PluggablePlayer()
            instance.hybridViewController = HybridViewController(nibName: "HybridViewController", bundle: nil)
            
            let playerViewController = ViewControllerFactory.createPlayerViewController(videoItems: videos, errorViewConfig: errorViewConfig)
            instance.hybridViewController?.kalturaPlayerController = playerViewController
            
            instance.kalturaPlayerController = playerViewController
            
            instance.addPlayerObservers()
        }
        
        instance.configurationJSON = configurationJSON
        instance.currentPlayableItem = playable
        instance.hybridViewController?.configurationJSON = configurationJSON
        
        if let screenModel = ZAAppConnector.sharedInstance().layoutComponentsDelegate.componentsManagerGetScreenComponentforPluginID(pluginID: "zee_player"),
            screenModel.isPluginScreen(),
            let style = screenModel.style {
            instance.hybridViewController?.pluginStyles = style.object
            instance.pluginStyles = instance.hybridViewController?.pluginStyles
        }
        
        instance.contentId = playable.identifier as String?
        UserDefaults.standard.set(playable.identifier as String?, forKey: "originalContentId")
        
        return instance
    }
    
    public override func pluggablePlayerViewController() -> UIViewController? {
        return self.hybridViewController
    }
    
    public func pluggablePlayerCurrentPlayableItem() -> ZPPlayable? {
        return self.kalturaPlayerController?.playerAdapter?.currentItem
    }
    
    public override func pluggablePlayerFirstPlayableItem() -> ZPPlayable? {
        return self.kalturaPlayerController?.playerAdapter?.currentItem
    }
    
    public func pluggablePlayerCurrentUrl() -> NSURL? {
        let item = self.kalturaPlayerController?.playerAdapter?.currentItem
        let urlString = item?.contentVideoURLPath() ?? ""
        return NSURL(string: urlString)
    }
    
    
    // MARK: - Inline playback
    
    public override func pluggablePlayerAddInline(_ rootViewController: UIViewController, container: UIView) {
        guard let kalturaPlayerController = self.kalturaPlayerController else {
            return
        }
        kalturaPlayerController.builder.mode = .inline
        rootViewController.addChildViewController(kalturaPlayerController, to: container)
        kalturaPlayerController.view.matchParent()
    }
    
    public override func pluggablePlayerRemoveInline() {
        if let item = self.kalturaPlayerController?.playerAdapter?.currentItem,
            let progress = self.kalturaPlayerController?.playerAdapter?.playbackState {
            print("pluggablePlayerRemoveInline:: item: \(item) *** progress ** \(progress)")
        }
        let container = self.kalturaPlayerController?.view.superview
        container?.removeFromSuperview()
    }
    
    
    // MARK: - Fullscreen playback
    
    public override func presentPlayerFullScreen(_ rootViewController:    UIViewController, configuration: ZPPlayerConfiguration?) {
        self.presentPlayerFullScreen(rootViewController, configuration: configuration) {
            self.playContent()
        }
    }
    
    public override func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?, completion: (() -> Void)?) {
        guard let kalturaPlayerController = self.kalturaPlayerController,
            let topmostViewController = rootViewController.topmostModal(),
            let currentItem = kalturaPlayerController.playerAdapter?.currentItem  else {
                return
        }

        let animated: Bool = configuration?.animated ?? true
        kalturaPlayerController.builder.mode = .fullscreen

        if let playerVC = self.pluggablePlayerViewController() as? HybridViewController{
            if topmostViewController is HybridViewController {
                playerVC.updatePlayerConfiguration()
                self.playContent()
            } else {
                playerVC.modalPresentationStyle = .fullScreen
                topmostViewController.present(playerVC, animated:animated, completion: completion)

            }
        } else {
            APLoggerError("Failed creating player view controller for Kaltura player")
        }
    }
    
    open override func pluggablePlayerType() -> ZPPlayerType {
        return Zee5PluggablePlayer.pluggablePlayerType()
    }
    
    public static func pluggablePlayerType() -> ZPPlayerType {
        return .undefined
    }
    
    // MARK: - ZPAdapterProtocol
    
    public required override init() { }
    
    public required init(configurationJSON: NSDictionary?) { }
    
    @objc public func handleUrlScheme(_ params: NSDictionary) {
        guard let dsUrl = params["data_source"] as? String else {
            return
        }
        
        let link = APAtomEntryPlayable()
        link.extensionsDictionary = [AnyHashable: String]()
        link.extensionsDictionary["item_details_url"] = dsUrl
        link.play()
    }
    
    // MARK: - private
    
    static func lastActiveInstance() -> Zee5PluggablePlayer? {
        guard let lastActiveInstance = ZPPlayerManager.sharedInstance.lastActiveInstance as? Zee5PluggablePlayer else {
            return nil
        }
        
        return lastActiveInstance
    }
    
    static func clear(instans: Zee5PluggablePlayer) {
        instans.shouldDissmis = false
        instans.hybridViewController?.currentPlayableItem = nil
        instans.currentPlayableItem = nil
    }
    
    @objc func stop() {
        if self.shouldDissmis == true,
            let playerVC = self.pluggablePlayerViewController() {
            playerVC.dismiss(animated: true, completion: nil)
            self.currentPlayableItem = nil
            self.hybridViewController = nil
        }
    }
    
    func playContent() {
        func play() {
            guard let kalturaPlayerController = self.kalturaPlayerController else {
                return
            }
            kalturaPlayerController.play()
        }
        
        func continueAfterUserInfoResponse() {
            ZEE5UserDefaults.setUserType(User.shared.getType().rawValue)
            ZEE5UserDefaults.settranslationLanguage(Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage() ?? "en")
            
            let location =  Zee5UserDefaultsManager.shared.getCountryDetailsFromCountryResponse()
            ZEE5UserDefaults.setCountry(location.country, andState: location.state)
            
            let (isTelcoUser, telcoUserData) = User.shared.isTelcoUser()
            if isTelcoUser, let telcoUserData = telcoUserData {
                setlocalize(param: telcoUserData)
            }
            
            if let userSetting = Zee5UserDefaultsManager.shared.getUsersSettings() {
                let userSettingString = String(data: userSetting, encoding: String.Encoding.utf8)
                ZEE5UserDefaults.setUserSettingData(userSettingString ?? "")
            }
            
            play()
        }
        
        func continueAfterSubscriptionResponse() {
            let _ = Zee5UserDefaultsManager.shared.saveUserTypeToLocalStorage()
            
            UserViewModel.shared.fetchLoggedInUserInfo { (response, error) in
                continueAfterUserInfoResponse()
            }
        }
        
        func prepareUserData() {
            ZEE5UserDefaults.setPlateFormToken(Zee5UserDefaultsManager.shared.getPlatformToken())
            
            SettingsHelper.shared.syncServerSettingsToLocalOnLogin() { updated in
                SubscriptionManager.shared.fetchSubscriptionsAPI {
                    if let subscriptionData = Zee5UserDefaultsManager.shared.getSubscriptionPacksData() {
                        let dataString = String(data: subscriptionData, encoding: String.Encoding.utf8)
                        ZEE5UserDefaults.setUserSubscribedPack(dataString ?? "")
                    }
                    
                    continueAfterSubscriptionResponse()
                }
            }
        }
        
        func initContent(_ contentId: String) {
            guard
                let hybridViewController = self.hybridViewController,
                let kalturaPlayerController = self.kalturaPlayerController else {
                    return
            }
                        
            ZEE5PlayerSDK.initialize(withContentID: contentId, and:User.shared.getUserId() )
            kalturaPlayerController.contentId = contentId
            
            hybridViewController.currentPlayableItem = self.currentPlayableItem
            
            prepareUserData()
        }
        
        guard
            let playable = self.currentPlayableItem else {
            return
        }
        
        let playbleId = playable.identifier as String?
        
        if let contentId = self.contentId, playbleId == contentId, playable.extensionsDictionary?[ExtensionsKey.relatedContent] != nil {
            initContent(contentId)
        }
        else {
            self.loadExtendedData() {
                guard let contentId = self.contentId else {
                    self.shouldDissmis = true
                    self.stop()
                    return
                }
                
                initContent(contentId)
            }
        }
    }
    
    
    func setlocalize(param:[String: String])  {
        
        var message = NSAttributedString(string: "")
        
        if (param["partner"] ?? "").lowercased().contains("vodafone")
        {
            
        message = NSAttributedString(string: "BIStrings_Body_LaunchThroughVodafone_Text".localized(hashMap: [:]))
            
        }
        else if (param["partner"] ?? "").lowercased().contains("airtel")
        {
          message = NSAttributedString(string: "BIStrings_Body_LaunchThroughAirtel_Text".localized(hashMap: [:]))
        }
        else if (param["partner"] ?? "").lowercased().contains("idea")
        {
         message = NSAttributedString(string: "BIStrings_Body_LaunchThroughIdea_Text".localized(hashMap: [:]))
        }
        print(message);
        let Message = message.string as String
        ZEE5PlayerManager.sharedInstance().telcouser(true, param: Message)
    
    }
    
    func addPlayerObservers() {
        self.contentIdNotificationToken = NotificationCenter.default.addObserver(forName: .contentIdUpdatedNotification, object: nil, queue: nil) { [weak self] (notification) in
            guard let self = self else {
                return
            }
            
            let newContentId = ZEE5PlayerManager.sharedInstance().currentItem.content_id
            if self.contentId != newContentId {
                self.contentId = newContentId
                self.playContent()
            }
        }
        
        self.refreshRequiredNotificationToken = NotificationCenter.default.addObserver(forName: .refreshRequiredNotification, object: nil, queue: nil) { (notification) in
            self.contentId! = UserDefaults.standard .value(forKey: "originalContentId") as! String
            self.playContent()
        }
    }
    
    func loadExtendedData(completion: @escaping () -> Void) {
        guard
            let dsUrl = self.dsUrlForExtentedData(),
            let atomFeed = APAtomFeed(url: dsUrl) else {
                completion()
                return
        }
        
        func handleLoadedItem(_ extendedAtomFeed: APAtomFeed) {
            guard
                let entry = extendedAtomFeed.entries?.first as? APAtomFeed,
                let pipes = entry.pipesObject as? [String: Any] else {
                    completion()
                    return
            }
          
            atomFeed.pipesObject["type"] = ["value": "video"]
            let atomEntry = APAtomEntry(pipesObject: atomFeed.pipesObject)
            
            guard let loadedPlayable = atomEntry?.playable() else {
                completion()
                return
            }
                      
            self.currentPlayableItem = loadedPlayable
            self.contentId = loadedPlayable.identifier
            
            guard
                var extensions = loadedPlayable.extensionsDictionary,
                let content = pipes["content"] as? [String: Any],
                let relatedContentUrl = content["src"] else {
                    completion()
                    return
            }
            
            extensions[ExtensionsKey.relatedContent] = relatedContentUrl
            loadedPlayable.extensionsDictionary = extensions
            
            completion()
        }
        
        APAtomFeedLoader.loadPipes(model: atomFeed) { (success, atomFeed) in
            guard let atomFeed = atomFeed else {
                completion()
                return
            }
            
            handleLoadedItem(atomFeed)
        }
    }
    
    func dsUrlForExtentedData() -> String? {
        var result: String? = nil
        
        if let contentId = self.contentId {
            var queryItems = [
                URLQueryItem(name: "type", value: "ItemDetails"),
                URLQueryItem(name: "id", value: contentId)
            ]
            
            if let contentType = ConsumptionFeedType(type:  ZEE5PlayerSDK.getConsumpruionType()) {
                queryItems.append(URLQueryItem(name: "feed_type", value: String(describing: contentType)))
            }
            
            var urlComponents = URLComponents()
            urlComponents.scheme = "zee5"
            urlComponents.host = "fetchData"
            urlComponents.queryItems = queryItems
            
            result = urlComponents.url?.absoluteString
        }
        else if let playable = self.currentPlayableItem {
           result = playable.extensionsDictionary?["item_details_url"] as? String
        }
        
        return result
    }
}
