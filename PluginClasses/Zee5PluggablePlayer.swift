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

public class Zee5PluggablePlayer: APPlugablePlayerBase, ZPAdapterProtocol {
    
    public var pluginStyles: [String : Any]?
    
    //MARK: Class Variables
    var hybridViewController: HybridViewController?
    var currentPlayableItem: ZPPlayable?
    var rootViewController: UIViewController?
    var shouldDissmis: Bool = true
    
    // MARK: -
    
    var kalturaPlayerController: KalturaPlayerController?
    private var pluginModel: ZPPluginModel?
    private var screenModel: ZLScreenModel?
    private var dataSourceModel: NSObject?
    
    // MARK: - Lifecycle
    
    public required init?(pluginModel: ZPPluginModel, screenModel: ZLScreenModel, dataSourceModel: NSObject?) {
        self.pluginModel = pluginModel
        self.screenModel = screenModel
        self.dataSourceModel = dataSourceModel
        
        super.init()
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
        
        let playerViewController = ViewControllerFactory.createPlayerViewController(videoItems: videos, errorViewConfig: errorViewConfig)
        
        let instance: Zee5PluggablePlayer
        
        // Hybrid presented
        if let lastActiveInstance = Zee5PluggablePlayer.lastActiveInstance() {
            instance = lastActiveInstance
        }
        else {
            instance = Zee5PluggablePlayer()
            instance.hybridViewController = HybridViewController(nibName: "HybridViewController", bundle: nil)
        }
        
        instance.configurationJSON = configurationJSON
        instance.currentPlayableItem = playable
        instance.hybridViewController?.kalturaPlayerController = playerViewController
        instance.hybridViewController?.configurationJSON = configurationJSON
        
        if let screenModel = ZAAppConnector.sharedInstance().layoutComponentsDelegate.componentsManagerGetScreenComponentforPluginID(pluginID: "zee_player"),
            screenModel.isPluginScreen(),
            let style = screenModel.style {
            instance.hybridViewController?.pluginStyles = style.object
            instance.pluginStyles = instance.hybridViewController?.pluginStyles
        }
        
        instance.kalturaPlayerController = playerViewController
        
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
            self .RefreshPlayerView()
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
    
    // MARK:- NotificationObserver
    
    func RefreshPlayerView() {
       
        NotificationCenter.default.removeObserver(
            self,
            name:NSNotification.Name(rawValue: "ReloadConsumption"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playContent),
            name: NSNotification.Name(rawValue: "ReloadConsumption"),
            object: nil)
    
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
        // No player present
        guard let lastActiveInstance = ZPPlayerManager.sharedInstance.lastActiveInstance as? Zee5PluggablePlayer else {
            return nil
        }
        
        guard let topModal = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal() else {
            return nil
        }
        // Mini Player Present and user click on another item
        guard topModal is HybridViewController else {
            let instance = Zee5PluggablePlayer()
            instance.hybridViewController = HybridViewController(nibName: "HybridViewController", bundle: nil)
            Zee5PluggablePlayer.clear(instans: lastActiveInstance)
            return instance
        }
        
        // Hybrid Player Present and user click on related content
        Zee5PluggablePlayer.clear(instans: lastActiveInstance)
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
    
    @objc func playContent() {
        func initContent(_ contentId: String) {
            guard
                let hybridViewController = self.hybridViewController,
                let kalturaPlayerController = self.kalturaPlayerController else {
                    return
            }
                        
            ZEE5PlayerSDK.initialize(withContentID: contentId, and: Zee5UserDefaultsManager.shared.getUserAccessToken())
            kalturaPlayerController.contentId = contentId
            
            ZEE5UserDefaults.setPlateFormToken(Zee5UserDefaultsManager.shared.getPlatformToken())
      
            SettingsHelper.shared.syncServerSettingsToLocalOnLogin()
            SubscriptionManager.shared.fetchSubscriptionsAPI {
            if let SubscribeData = Zee5UserDefaultsManager.shared.getSubscriptionPacksData() {
            let dataString = String(data: SubscribeData, encoding: String.Encoding.utf8)
                    ZEE5UserDefaults.setUserSubscribedPack(dataString ?? "")
              }
            }
            let _ = Zee5UserDefaultsManager.shared.saveUserTypeToLocalStorage()
            
            UserViewModel.shared.fetchLoggedInUserInfo { (response, error) in
            if let UserSetting = Zee5UserDefaultsManager.shared.getUsersSettings() {
                    let userSettingString = String(data: UserSetting, encoding: String.Encoding.utf8)
                    ZEE5UserDefaults.setUserSettingData(userSettingString ?? "")
                }
            }
        
            ZEE5UserDefaults.setUserType(User.shared.getType().rawValue)
            ZEE5UserDefaults.settranslationLanguage(Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage() ?? "en")
            
            let Country =  Zee5UserDefaultsManager.shared.getCountryDetailsFromCountryResponse()
            
            ZEE5UserDefaults.setCountry(Country.country, andState: Country.state)
            
            let Telco = User.shared.isTelcoUser()
            if Telco.0
            {
                guard let dict = Telco.1 else { return }
              setlocalize(param: dict)
            }
          
            if let UserSetting = Zee5UserDefaultsManager.shared.getUsersSettings() {
                let userSettingString = String(data: UserSetting, encoding: String.Encoding.utf8)
                ZEE5UserDefaults.setUserSettingData(userSettingString ?? "")
            }
            
            hybridViewController.currentPlayableItem = self.currentPlayableItem
            kalturaPlayerController.play()
        }
        
        guard let playable = self.currentPlayableItem else {
            return
        }
        
        if let contentId = playable.identifier as String?, playable.extensionsDictionary?[ExtensionsKey.relatedContent] != nil {
            initContent(contentId)
        }
        else {
            self.loadExtendedData() {
                guard let contentId = self.currentPlayableItem?.identifier as String? else {
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
    
    func loadExtendedData(completion: @escaping () -> Void) {
        guard let originalPlayable = self.currentPlayableItem, let dsUrl = originalPlayable.extensionsDictionary?["item_details_url"] as? String else {
            return
        }
        
        guard let atomFeed = APAtomFeed(url: dsUrl) else {
            return
        }
        
        func handleLoadedItem(_ extendedAtomFeed: APAtomFeed) {
            guard
                let entry = extendedAtomFeed.entries?.first as? APAtomFeed,
                let pipes = entry.pipesObject as? [String: Any] else {
                    return
            }
            
            atomFeed.pipesObject["type"] = ["value": "video"]
            let atomEntry = APAtomEntry(pipesObject: atomFeed.pipesObject)
            
            guard let loadedPlayable = atomEntry?.playable() else {
                return
            }
            
            self.currentPlayableItem = loadedPlayable
            
            guard
                var extensions = loadedPlayable.extensionsDictionary,
                let content = pipes["content"] as? [String: Any],
                let relatedContentUrl = content["src"] else {
                    return
            }
            
            extensions[ExtensionsKey.relatedContent] = relatedContentUrl
            loadedPlayable.extensionsDictionary = extensions
            
            completion()
        }
        
        APAtomFeedLoader.loadPipes(model: atomFeed) { (success, atomFeed) in
            guard let atomFeed = atomFeed else {
                return
            }
            
            handleLoadedItem(atomFeed)
        }
    }
}
