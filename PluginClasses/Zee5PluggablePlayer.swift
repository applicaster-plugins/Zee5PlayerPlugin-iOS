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
    static let setInitialContentIdNotification = Notification.Name("ReloadCurrentContentIdNotification")
    static let subscriptionEnabledNotification = Notification.Name(Zee5CoreSDKPluginConstants.BUY_SUBSCRIPTION_COMPLETE)
}

public class Zee5PluggablePlayer: APPlugablePlayerBase, ZPAdapterProtocol {
    public var pluginStyles: [String : Any]?
    
    var hybridViewController: HybridViewController?
    var initialPlayableItem: ZPPlayable?
    
    private var pluginModel: ZPPluginModel?
    private var screenModel: ZLScreenModel?
    private var dataSourceModel: NSObject?
    private var playerAdapter = ZeePlayerAdapter()
    
    fileprivate var contentIdNotificationToken: Any?
    fileprivate var setInitialContentIdNotificationToken: Any?
    fileprivate var subscriptionEnabledNotificationToken: Any?

    // for debug only, set a value here to always use this content id
    fileprivate var debugOverrideContentId: String? = ""
    
    // MARK: - Lifecycle
    
    public required init?(pluginModel: ZPPluginModel, screenModel: ZLScreenModel, dataSourceModel: NSObject?) {
        self.pluginModel = pluginModel
        self.screenModel = screenModel
        self.dataSourceModel = dataSourceModel
                
        super.init()
        
        self.playerAdapter.delegate = self
    }
    
    deinit {
        if let contentIdNotificationToken = self.contentIdNotificationToken {
            NotificationCenter.default.removeObserver(contentIdNotificationToken)
        }
        
        if let setInitialContentIdNotificationToken = self.setInitialContentIdNotificationToken {
            NotificationCenter.default.removeObserver(setInitialContentIdNotificationToken)
        }
        
        if let subscriptionEnabledNotificationToken = self.subscriptionEnabledNotificationToken {
            NotificationCenter.default.removeObserver(subscriptionEnabledNotificationToken)
        }
    }
    
    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?, configurationJSON: NSDictionary?) -> ZPPlayerProtocol? {
        guard let videos = items, let playable = videos.first else {
            return nil
        }
        
        Zee5DownloadManager.shared.initializeDownloadManger()
        
        if let configuration = configurationJSON {
//            let errorViewConfig = ErrorViewConfiguration(fromDictionary: configuration)
            
            let isProdAdsEnvirnoment = Zee5Utility().getConfigIntValue(configJSON: configuration, configKey:"is_ads_production", defaultValue: 0)
            ZEE5PlayerSDK.setAdsEnvirnoment(isProdAdsEnvirnoment == 1 ? prod : staging)
            
            
            let isConvivaEnvirnoment = Zee5Utility().getConfigIntValue(configJSON: configuration, configKey:"is_conviva_production", defaultValue: 0)
            ZEE5PlayerSDK.setConvivaEnvirnoment(isConvivaEnvirnoment == 1 ? Production : Staging)
            
            if let overrideChromecastAppId = configuration["chromecast_app_id"] as? String, overrideChromecastAppId.count > 0 {
                ChromeCastManager.shared.appId = overrideChromecastAppId
            }
        }
                
        
        let instance: Zee5PluggablePlayer
        
        if let lastActiveInstance = Zee5PluggablePlayer.lastActiveInstance() {
            instance = lastActiveInstance
        }
        else {
            instance = Zee5PluggablePlayer()
            instance.playerAdapter.delegate = instance
            
            instance.hybridViewController = HybridViewController(nibName: "HybridViewController", bundle: nil)
            instance.addPlayerObservers()
        }
        
        instance.configurationJSON = configurationJSON
        instance.initialPlayableItem = playable
        instance.hybridViewController?.configurationJSON = configurationJSON
        
        if let screenModel = ZAAppConnector.sharedInstance().layoutComponentsDelegate.componentsManagerGetScreenComponentforPluginID(pluginID: "zee_player"),
            screenModel.isPluginScreen(),
            let style = screenModel.style {
            instance.hybridViewController?.pluginStyles = style.object
            instance.pluginStyles = instance.hybridViewController?.pluginStyles
        }
        
        return instance
    }
    
    public override func pluggablePlayerViewController() -> UIViewController? {
        return self.hybridViewController
    }
    
    public func pluggablePlayerCurrentPlayableItem() -> ZPPlayable? {
        return self.initialPlayableItem
    }
    
    public override func pluggablePlayerFirstPlayableItem() -> ZPPlayable? {
        return self.initialPlayableItem
    }
    
    public func pluggablePlayerCurrentUrl() -> NSURL? {
        let item = self.initialPlayableItem
        let urlString = item?.contentVideoURLPath() ?? ""
        return NSURL(string: urlString)
    }
    
    // MARK: - Inline playback
    
    public override func pluggablePlayerAddInline(_ rootViewController: UIViewController, container: UIView) {
    }
    
    public override func pluggablePlayerRemoveInline() {
    }
    
    // MARK: - Fullscreen playback
    
    public override func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?) {
        self.presentPlayerFullScreen(rootViewController, configuration: configuration, completion: nil)
    }
    
    public override func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?, completion: (() -> Void)?) {
        guard
            let hybridViewController = self.hybridViewController,
            let initialPlayableItem = self.initialPlayableItem,
            let contentId = initialPlayableItem.identifier as String?,
            let topmostViewController = rootViewController.topmostModal() else {
                return
        }
        
        AnalyticEngine.shared.screenViewEvent()

        let animated = configuration?.animated ?? true
        
        if topmostViewController is HybridViewController {
            self.updateContent(contentId, force: true)
            
            completion?()
        }
        else {
            hybridViewController.modalPresentationStyle = .fullScreen
            
            topmostViewController.present(hybridViewController, animated:animated) {
                self.updateContent(contentId, force: true)
                
                completion?()
            }
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
        guard
            let dsUrlValue = params["data_source"] as? String,
            let dsUrl = URL(string: dsUrlValue),
            let components = URLComponents(url: dsUrl, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else {
                return
        }
        
        var _contentId = queryItems.first(where: {$0.name == "id"})?.value
        if _contentId == nil {
            guard
                let subUrlParam = queryItems.first(where: {$0.name == "url"})?.value,
                let subUrlData = Data(base64Encoded: subUrlParam),
                let subUrlValue = String(data: subUrlData, encoding: .utf8),
                let subUrl = URL(string: subUrlValue),
                let subComponents = URLComponents(url: subUrl, resolvingAgainstBaseURL: false),
                let subQueryItems = subComponents.queryItems,
                let idParam = subQueryItems.first(where: {$0.name == "id"})?.value else {
                    return
            }
            
            _contentId = idParam
        }
        
        guard let contentId = _contentId else {
            return
        }
        
        let link = APAtomEntryPlayable()
        link.identifier = contentId
        link.extensionsDictionary = [AnyHashable: String]()
        link.extensionsDictionary["item_details_url"] = dsUrlValue
        link.play()
    }
    
    public func stopAndDismiss() {
        self.playerAdapter.endSession()
        
        func resetContent() {
            self.initialPlayableItem = nil
        }
        
        if let hybridViewController = self.hybridViewController {
            resetContent()

            hybridViewController.dismiss(animated: true) {
                hybridViewController.playable = nil
            }
        }
        else {
            resetContent()
        }
    }
    
    // MARK: - private
    
    static func lastActiveInstance() -> Zee5PluggablePlayer? {
        guard
            let lastActiveInstance = ZPPlayerManager.sharedInstance.lastActiveInstance as? Zee5PluggablePlayer,
            lastActiveInstance.hybridViewController != nil else {
                return nil
        }
        
        return lastActiveInstance
    }
    
    func clearInstance() {
        self.stopAndDismiss()
        
        self.hybridViewController = nil
    }
    
    func updateContent(_ contentId: String, force: Bool = false) {
        var contentId = contentId

        // for debug only
        if let overrideContentId = self.debugOverrideContentId, overrideContentId.count > 0 {
            contentId = overrideContentId
            ZEE5PlayerManager.sharedInstance().showToastMessage("Override content id: " + contentId)
        }
        
        guard force || !self.playerAdapter.sessionHasEqual(contentId: contentId) else {
            return
        }
        
        self.playerAdapter.endSession()
        self.hybridViewController?.playable = nil
        
        func play() {
            guard
                self.initialPlayableItem != nil else {
                    return
            }
            
            self.playerAdapter.startSession(contentId)
        }
        
        func continueAfterUserInfoResponse() {
            ZEE5UserDefaults.setUserType(User.shared.getType().rawValue)
            ZEE5UserDefaults.settranslationLanguage(Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage() ?? "en")
            
            var oneTrustData: Dictionary<String, Any>? = nil
            if Zee5UserDefaultsManager.shared.isEuropeanCountry() {
                let oneTrust = Zee5UserDefaultsManager.shared.getOneTrustMapValues()
                
                if oneTrust.count > 0, let dictionary = try? convertToDictionary(from: oneTrust) {
                    oneTrustData = dictionary
                }
            }
            
            ZEE5PlayerManager.sharedInstance().setOneTrustValue(oneTrustData)
                
            let location =  Zee5UserDefaultsManager.shared.getCountryDetailsFromCountryResponse()
            ZEE5UserDefaults.setCountry(location.country, andState: location.state)
            
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
        
        prepareUserData()
    }

    
    func convertToDictionary(from text: String) throws -> [String: String] {
        guard let data = text.data(using: .utf8) else { return [:] }
        let anyResult: Any = try JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: String] ?? [:]
    }
    
    func addPlayerObservers() {
        let setInitialContentId = { [weak self] (notification: Notification) -> () in
            guard
                let self = self,
                let initialContentId = self.initialPlayableItem?.identifier as String? else {
                return
            }
            
            self.updateContent(initialContentId, force: true)
        }
        
        
        self.contentIdNotificationToken = NotificationCenter.default.addObserver(forName: .contentIdUpdatedNotification, object: nil, queue: nil) { [weak self] (notification) in
            guard let contentId = notification.userInfo?["contentId"] as? String else {
                return
            }
            
            self?.updateContent(contentId)
        }
        
        self.setInitialContentIdNotificationToken = NotificationCenter.default.addObserver(forName: .setInitialContentIdNotification, object: nil, queue: nil, using: setInitialContentId)
        self.subscriptionEnabledNotificationToken = NotificationCenter.default.addObserver(forName: .subscriptionEnabledNotification, object: nil, queue: nil, using: setInitialContentId)
    }
}

extension Zee5PluggablePlayer: ZeePlayerAdapterDelegate {
    func playerAdapterDidLoadPlayable(_ playable: ZeePlayable) {
        guard
            let hybridViewController = self.hybridViewController else {
                return
        }
        
        hybridViewController.playable = playable
    }
}
