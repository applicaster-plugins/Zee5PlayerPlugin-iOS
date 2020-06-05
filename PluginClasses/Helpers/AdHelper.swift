//
//  AdHelper.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 10.04.20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

import ZappPlugins
import Zee5CoreSDK

fileprivate extension Notification.Name {
    static let companionAdsUpdated = Notification.Name("CompanionAds")
}

class AdBanner: UIView {
    @IBOutlet fileprivate var heightConstraint: NSLayoutConstraint!
    
    fileprivate var observer: NSObjectProtocol?
    fileprivate let adHelper = AdHelper()

    func setupAds(playable: ZPPlayable?) {
        self.observer = NotificationCenter.default.addObserver(forName: .companionAdsUpdated, object: nil, queue: nil,using: handleCompanionAdsUpdated)

        adHelper.setupAdsBanner(self, playable: playable)
    }
    
    func handleCompanionAdsUpdated(notification: Notification) {
        self.adHelper.updateAdBanner(self)
    }
}

extension AdBanner: ZPAdViewProtocol {
    func adLoaded(view: UIView?) {
        guard let view = view else {
            return
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.heightConstraint.constant = view.height
        self.backgroundColor = view.backgroundColor
        self.addSubview(view)
        
        view.fillParent()
        
        self.isHidden = false
    }
    
    func stateChanged(adViewState: ZPAdViewState) {
    }
    
    func adLoadFailed(error: Error) {
    }
}

class AdHelper {
    fileprivate var adPresenter: ZPAdPresenterProtocol?
    fileprivate var playable: ZPPlayable!

    typealias JSON = [String: Any]
    
    fileprivate func setupAdsBanner(_ banner: AdBanner, playable: ZPPlayable?) {
        banner.isHidden = true
        banner.removeAllSubviews()
        
        self.playable = playable
    }
    
    func updateAdBanner(_ banner: AdBanner) {
        let userType = User.shared.getType()
        guard userType != .premium else {
            return
        }
        
        guard
            let pluginModel = ZPPluginManager.pluginModelById("Zee5Ads"), let plugin = ZPPluginManager.adapter(pluginModel) as? ZPAdPluginProtocol,
            let playable = self.playable else {
            return
        }
        
        if let extensions = playable.extensionsDictionary as? [String: Any] {
            let subtype = extensions[ExtensionsKey.assetSubtype] as? String
            guard subtype != "trailer" else {
                return
            }
            
            guard ExtensionsHelper.isPlaybleFree(extensions) else {
                return
            }
        }
        
        guard
            let ads = ZEE5PlayerManager.sharedInstance().companionAds as? [JSON],
            let adConfig = self.parseResponse(ads, userType) else {
                return
        }
        
        let adPresenter = plugin.createAdPresenter(adView: banner, parentVC: banner.parentViewController())
        self.adPresenter = adPresenter
        
        adPresenter.load(adConfig: adConfig)
    }
    
    fileprivate func downloadAdConfig(_ contentId: String, userType: UserType, completion: @escaping (_ ad: ZPAdConfig?) -> Void) {
        let params = [
            "content_id": contentId,
            "platform_name": "apple_app",
            "user_type": ZEE5UserDefaults.getUserType(),
            "country": ZEE5UserDefaults.getCountry(),
            "state": ZEE5UserDefaults.getState(),
            "app_version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
            "audio_language": ZEE5UserDefaults.gettranslation()
        ]
                
        NetworkManager.sharedInstance().makeHttpGetRequest(BaseUrls.adConfig(), requestParam: params, requestHeaders: [:], withCompletionHandler: { (data) in
            guard
                let data = data as? [String: Any],
                let ads = data["companion_ads"] as? [JSON], ads.count > 0 else {
                    completion(nil)
                    return
            }
                        
            let result = self.parseResponse(ads, userType)
            completion(result)
        }) { (error) in
            completion(nil)
        }
    }
    
    fileprivate func parseResponse(_ ads: [JSON], _ userType: UserType) -> ZPAdConfig? {
        let companionAds = ads[0]
        let userAdsKey: String
                    
        switch userType {
        case .guest:
            userAdsKey = "guest"
        case .registered:
            userAdsKey = "register"
        default:
            return nil
        }
        
        guard
            let userAds = companionAds[userAdsKey] as? JSON,
            let isEnabled = userAds["ads_visibility"] as? Bool, isEnabled,
            let adsData = userAds["ad_data"] as? [JSON], adsData.count > 0 else {
                return nil
        }
        
        let adData = adsData[0]
        
        guard let tag = adData["ad_tag"] as? String else {
            return nil
        }

        var unitId = tag
        
        if let targets = adData["ad_targeting"] as? [JSON], targets.count > 0 {
            var queryItems = [URLQueryItem]()
            
            for target in targets {
                guard let targetKey = target["key"] as? String, let targetParam = target["value"] else {
                    continue
                }
                
                let queryItem = URLQueryItem(name: targetKey, value: String(describing: targetParam))
                queryItems.append(queryItem)
            }
            
            var urlComponents = URLComponents()
            urlComponents.queryItems = queryItems
            
            if let query = urlComponents.query {
                unitId = tag + "?" + query
            }
        }
        
        return ZPAdConfig(adUnitId: unitId, inlineBannerSize: "NATIVE_SMALL")
    }
}
