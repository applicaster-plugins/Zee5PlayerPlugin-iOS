//
//  Zee5iOSPlayerPlugin.swift
//  ZEE5PlayerSDK
//
//  Created by User on 25/09/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

import Foundation
import ZappPlugins
import ApplicasterSDK
import Zee5CoreSDK




public class Zee5iOSPlayerPlugin: NSObject, ZPPlayerProtocol, ZPPluggableScreenProtocol {
    
    // MARK: - Properties
    
    var kalturaPlayerController: KalturaPlayerController?
    
    @objc weak public var screenPluginDelegate: ZPPlugableScreenDelegate?
    private var pluginModel: ZPPluginModel?
    private var screenModel: ZLScreenModel?
    private var dataSourceModel: NSObject?
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
    }
    
    public required init?(pluginModel: ZPPluginModel, screenModel: ZLScreenModel, dataSourceModel: NSObject?) {
        self.pluginModel = pluginModel
        self.screenModel = screenModel
        self.dataSourceModel = dataSourceModel
        
        super.init()
    }
    
    // MARK: - ZPPlayerProtocol
    
    
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
        let instance = Zee5iOSPlayerPlugin()
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
    
    public func pluggablePlayerViewController() -> UIViewController?
    {
        return self.kalturaPlayerController
    }
    
    public func pluggablePlayerCurrentUrl() -> NSURL? {
        let item = self.kalturaPlayerController?.playerAdapter?.currentItem
        let urlString = item?.contentVideoURLPath() ?? ""
        return NSURL(string: urlString)
    }
    
    public func pluggablePlayerCurrentPlayableItem() -> ZPPlayable? {
        print("\n|*** pluggablePlayerCurrentPlayableItem : implementation ***| \n")
        return self.kalturaPlayerController?.playerAdapter?.currentItem
    }
    
    public func pluggablePlayerFirstPlayableItem() -> ZPPlayable? {
        print("\n|*** pluggablePlayerFirstPlayableItem : suggestion ***| \n")
        return self.kalturaPlayerController?.playerAdapter?.currentItem
    }
    
    // MARK: - Inline playback
    
    public func pluggablePlayerAddInline(_ rootViewController: UIViewController, container: UIView) {
        guard let kalturaPlayerController = self.kalturaPlayerController else {
            return
        }
        kalturaPlayerController.builder.mode = .inline
        rootViewController.addChildViewController(kalturaPlayerController, to: container)
        kalturaPlayerController.view.matchParent()
    }
    
    public func pluggablePlayerRemoveInline() {
        if let item = self.kalturaPlayerController?.playerAdapter?.currentItem,
            let progress = self.kalturaPlayerController?.playerAdapter?.playbackState {
            print("pluggablePlayerRemoveInline:: item: \(item) *** progress ** \(progress)")
        }
        let container = self.kalturaPlayerController?.view.superview
        container?.removeFromSuperview()
    }
    
    // MARK: - Fullscreen playback
    
    public func presentPlayerFullScreen(_ rootViewController:    UIViewController, configuration: ZPPlayerConfiguration?) {
        self.presentPlayerFullScreen(rootViewController, configuration: configuration) {
            self.kalturaPlayerController?.playerAdapter?.play()
        }
    }
    
    public func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?, completion: (() -> Void)?) {
        guard let kalturaPlayerController = self.kalturaPlayerController,
            let topmostViewController = rootViewController.topmostModal(),
            let currentItem = kalturaPlayerController.playerAdapter?.currentItem  else {
                return
        }
        print("Current Item From zapp\(currentItem)")
        let animated: Bool = configuration?.animated ?? true
        kalturaPlayerController.builder.mode = .fullscreen
        topmostViewController.present(kalturaPlayerController, animated: animated, completion: completion)
    }
    
    // MARK: - Playback controls
    
    public func pluggablePlayerPlay(_ configuration: ZPPlayerConfiguration?) {
        self.kalturaPlayerController?.playerAdapter?.play()
    }
    
    public func pluggablePlayerPause() {
        self.kalturaPlayerController?.playerAdapter?.pause()
    }
    
    public func pluggablePlayerStop() {
        self.kalturaPlayerController?.playerAdapter?.stop()
    }
    
    // MARK: - Playback state
    
    public func pluggablePlayerIsPlaying() -> Bool {
        return playerState() == .playing
    }
    
    public func playerState() -> ZPPlayerState {
        return self.kalturaPlayerController?.playerAdapter?.playerState ?? ZPPlayerState.onHold
    }
    
    // MARK: - Plugin type
    
    open func pluggablePlayerType() -> ZPPlayerType {
        return Zee5iOSPlayerPlugin.pluggablePlayerType()
    }
    
    public static func pluggablePlayerType() -> ZPPlayerType {
        return .undefined
    }
}
