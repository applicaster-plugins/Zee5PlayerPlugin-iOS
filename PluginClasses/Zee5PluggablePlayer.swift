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
    
    
    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?, configurationJSON: NSDictionary?) -> ZPPlayerProtocol?
    {
        print("pluggablePlayerRemoveInline:: item: \(String(describing: items))")
        guard let videos = items else
        {
            return nil
        }
        

        print("pluggablePlayerRemoveInline::Videos : \(videos)")
        //  print("Zpplayble Object : \)")
        
        Zee5DownloadManager.shared.initializeDownloadManger()
   
        
        
        
        var errorViewConfig: ErrorViewConfiguration?
        if let configuration = configurationJSON
            
        {
            errorViewConfig = ErrorViewConfiguration(fromDictionary: configuration)
        }
        
        let playerViewController = ViewControllerFactory.createPlayerViewController(videoItems: videos, errorViewConfig: errorViewConfig)
        
        let instance: Zee5PluggablePlayer
        
        // Hybrid presented
        if let lastActiveInstance = Zee5PluggablePlayer.lastActiveInstance() {
            instance = lastActiveInstance
        }
            // No Player Presented
        else {
            instance = Zee5PluggablePlayer()
            instance.hybridViewController = HybridViewController(nibName: "HybridViewController", bundle: nil)
        }
        
        
        // Configuration
        instance.configurationJSON = configurationJSON
        instance.currentPlayableItem = items?.first
        instance.hybridViewController?.kalturaPlayerController = playerViewController
        instance.hybridViewController?.currentPlayableItem = items?.first
        instance.hybridViewController?.configurationJSON = configurationJSON
        
        if let screenModel = ZAAppConnector.sharedInstance().layoutComponentsDelegate.componentsManagerGetScreenComponentforPluginID(pluginID: "zee_player"),
            screenModel.isPluginScreen(),
            let style = screenModel.style {
            instance.hybridViewController?.pluginStyles = style.object
            instance.pluginStyles = instance.hybridViewController?.pluginStyles
        }
        
        instance.kalturaPlayerController = playerViewController
        
        let Dict = items!.first!.extensionsDictionary
        print(Dict!)
        
        if items != nil, items!.count > 0,let contentId = items!.first!.identifier as String?
        {
            ZEE5PlayerSDK.initialize(withContentID: contentId, and: Zee5UserDefaultsManager.shared.getUserAccessToken())
            
            instance.kalturaPlayerController?.contentId = contentId

            
            ZEE5UserDefaults .setPlateFormToken(Zee5UserDefaultsManager.shared.getPlatformToken())
            
            ZEE5UserDefaults.setUserType(User.shared.getType().rawValue)
            ZEE5UserDefaults .settranslationLanguage(Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage() ?? "en")
            
            let Country =  Zee5UserDefaultsManager.shared.getCountryDetailsFromCountryResponse()
            
            ZEE5UserDefaults.setCountry(Country.country, andState: Country.state)
            
            
            if let SubscribeData = Zee5UserDefaultsManager.shared.getSubscriptionPacksData()
            {
                let dataString = String(data: SubscribeData, encoding: String.Encoding.utf8)
                print("dataString == \(String(describing: dataString))")
                ZEE5UserDefaults.setUserSubscribedPack(dataString ?? "")
            }
            ///// ****GET User Seting Data******
            
            if let UserSetting = Zee5UserDefaultsManager.shared.getUsersSettings()
            {
                let userSettingString = String(data: UserSetting, encoding: String.Encoding.utf8)
                print("dataString == \(String(describing: userSettingString))")
                ZEE5UserDefaults.setUserSettingData(userSettingString ?? "")
            }
            
        }
        
        return instance
    }
    
    public override func pluggablePlayerViewController() -> UIViewController? {
        return self.hybridViewController
    }
    
    public func pluggablePlayerCurrentPlayableItem() -> ZPPlayable? {
        print("\n|*** pluggablePlayerCurrentPlayableItem : implementation ***| \n")
        return self.kalturaPlayerController?.playerAdapter?.currentItem
    }
    
    public override func pluggablePlayerFirstPlayableItem() -> ZPPlayable? {
        print("\n|*** pluggablePlayerFirstPlayableItem : suggestion ***| \n")
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
            self.kalturaPlayerController?.playerAdapter?.play()
        }
    }
    
    public override func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?, completion: (() -> Void)?) {
        guard let kalturaPlayerController = self.kalturaPlayerController,
            let topmostViewController = rootViewController.topmostModal(),
            let currentItem = kalturaPlayerController.playerAdapter?.currentItem  else {
                return
        }
        print("Current Item From zapp\(currentItem)")
        let animated: Bool = configuration?.animated ?? true
        kalturaPlayerController.builder.mode = .fullscreen

        if let playerVC = self.pluggablePlayerViewController() as? HybridViewController{
            if topmostViewController is HybridViewController {
                playerVC.updatePlayerConfiguration()
                self.kalturaPlayerController?.playerAdapter?.play()
                
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
        print("params \(params)")
        if let stringURL = params["ds"] as? String {
            if let atomFeed = APAtomFeed.init(url: stringURL) {
                APAtomFeedLoader.loadPipes(model: atomFeed) { [weak self] (success, atomFeed) in
                    if success,
                        let atomFeed = atomFeed {
                        if let entries = atomFeed.entries,
                            entries.count > 0 {
                            if let itemId = params["id"] as? String {
                                for entry in entries {
                                    if let atomEntry = entry as? APAtomEntry,
                                        atomEntry.identifier == itemId {
                                        if let playable = atomEntry.playable() {
                                            if let p = atomEntry.parentFeed,
                                                let pipesObject = p.pipesObject {
                                                playable.pipesObject = pipesObject as NSDictionary
                                            }
                                            playable.play()
                                        }
                                    }
                                }
                            }
                                // present the first item
                            else if let atomEntry = entries.first as? APAtomEntry,
                                let playable = atomEntry.playable() {
                                if let p = atomEntry.parentFeed,
                                    let pipesObject = p.pipesObject {
                                    playable.pipesObject = pipesObject as NSDictionary
                                }
                                playable.play()
                            }
                            print("entries \(entries)")
                        }
                    }
                }
            }
        }
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
        //        instans.hybridViewController?.playerViewController?.delegate = nil
        //        instans.hybridViewController?.playerViewController?.stop()
        //        instans.hybridViewController?.playerViewController = nil
        instans.hybridViewController?.currentPlayableItem = nil
        instans.currentPlayableItem = nil
    }
    
    @objc func stop() {
        if self.shouldDissmis == true,
            let playerVC = self.pluggablePlayerViewController() {
            //            Zee5AnalyticsManager.shared.playerExit()
            playerVC.dismiss(animated: true, completion: nil)
            self.currentPlayableItem = nil
            //            self.hybridViewController?.playerViewController = nil
            self.hybridViewController = nil
        }
    }
}
