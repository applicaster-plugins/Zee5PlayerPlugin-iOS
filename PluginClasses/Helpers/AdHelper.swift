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

import GoogleMobileAds

fileprivate extension Notification.Name {
    static let companionAdsUpdated = Notification.Name("CompanionAds")
}

class AdBanner: UIView {
    fileprivate var observer: NSObjectProtocol?
    fileprivate let adHelper = AdHelper()
    fileprivate var googleAdLoaderDelegate: GoogleAdLoaderDelegate!
    fileprivate var adView: GADUnifiedNativeAdView?
    
    func setupAds(playable: ZPPlayable?) {
        if self.observer == nil {
            self.observer = NotificationCenter.default.addObserver(forName: .companionAdsUpdated, object: nil, queue: nil,using: handleCompanionAdsUpdated)
        }
        
        if self.googleAdLoaderDelegate == nil {
            self.googleAdLoaderDelegate = GoogleAdLoaderDelegate(parentView: self)
        }
        
        adHelper.setupAdsBanner(self, playable: playable)
    }
    
    func handleCompanionAdsUpdated(notification: Notification) {
        self.adHelper.updateAdBanner(self)
    }
    
    deinit {
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

fileprivate class GoogleAdLoaderDelegate: NSObject, GADUnifiedNativeAdLoaderDelegate {
    weak var parentView: AdBanner!
    
    init(parentView: AdBanner) {
        self.parentView = parentView
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        guard let parentView = self.parentView else {
            return
        }
        
        parentView.isHidden = false

        let bundle = Bundle(for: AdHelper.self)
        guard
            let xib = bundle.loadNibNamed("GoogleNativeAd", owner: nil, options: nil),
            let nativeAdView = xib.first as? GADUnifiedNativeAdView else {
                return
        }
            
        parentView.addSubview(nativeAdView)
        
        parentView.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.fillParent()
    
        parentView.adView = nativeAdView

        if  let callToAction = nativeAd.callToAction,
            let callToActionButton = nativeAdView.callToActionView as? UIButton {
            
            callToActionButton.setTitle(callToAction, for: .normal)
            callToActionButton.layer.borderColor = UIColor.white.cgColor

            callToActionButton.isHidden = false
        }
        else {
            nativeAdView.callToActionView?.isHidden = true
        }
                    
        if  let icon = nativeAd.icon,
            let iconView = nativeAdView.iconView as? UIImageView {
            
            iconView.image = icon.image
            iconView.isHidden = false
        }
        else {
            nativeAdView.iconView?.isHidden = true
        }

        if  let advertiser = nativeAd.advertiser,
            let advertiserView = nativeAdView.advertiserView as? UILabel {
            
            advertiserView.text = advertiser
            advertiserView.isHidden = false
        }
        else {
            nativeAdView.advertiserView?.isHidden = true
        }
        
        if  let headline = nativeAd.headline,
            let headlineView = nativeAdView.headlineView as? UILabel {
            
            headlineView.text = headline
            headlineView.isHidden = false
        }
        else {
            nativeAdView.headlineView?.isHidden = true
        }
                
        nativeAdView.nativeAd = nativeAd
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
    }
}

class AdHelper {
    fileprivate var adPresenter: ZPAdPresenterProtocol?
    fileprivate var playable: ZPPlayable!

    typealias JSON = [String: Any]
    
    fileprivate var adLoader: GADAdLoader!
    
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
        
        guard let playable = self.playable else {
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
        
        let videoOptions = GADVideoOptions()
        videoOptions.startMuted = true
        videoOptions.customControlsRequested = true
        
        self.adLoader = GADAdLoader(adUnitID: adConfig.adUnitId,
                                    rootViewController: nil,
                                    adTypes: [.unifiedNative],
                                    options: [videoOptions])
        
        self.adLoader.delegate = banner.googleAdLoaderDelegate
        
        let request = GADRequest()
        #if DEBUG
        request.testDevices = [ kGADSimulatorID ]
        #endif
        
        self.adLoader.load(request)
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
        
        if let targets = adData["ad_targeting"] as? [JSON], targets.count > 0 {
            for target in targets {
                guard
                    let targetKey = target["key"] as? String,
                    let targetParam = target["value"] else {
                        continue
                }
            

            }
        }
        
        let unitId = tag
        
        return ZPAdConfig(adUnitId: unitId, inlineBannerSize: "NATIVE_SMALL")
    }
}
