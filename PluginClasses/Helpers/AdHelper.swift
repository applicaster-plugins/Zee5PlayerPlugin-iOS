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
import Zee5Advertisement

fileprivate extension Notification.Name {
    static let companionAdsUpdated = Notification.Name("CompanionAds")
}

class AdBanner: UIView {
    fileprivate var observer: NSObjectProtocol?
    fileprivate let adHelper = AdHelper()
    
    func setupAds(playable: ZPPlayable?) {
        if self.observer == nil {
            self.observer = NotificationCenter.default.addObserver(forName: .companionAdsUpdated, object: nil, queue: nil,using: handleCompanionAdsUpdated)
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



class AdHelper {
    fileprivate var playable: ZPPlayable!
    fileprivate var adLoader: CompanionAdBannerLoader!
    
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
        
        guard let adResponse = ZEE5PlayerManager.sharedInstance().companionAds as? AdResponse else {
            return
        }
     
        self.adLoader = CompanionAdBannerLoader(adResponse)
        self.adLoader.load() { adView in
            banner.addSubview(adView)
            
            banner.translatesAutoresizingMaskIntoConstraints = false
            adView.fillParent()
            
            banner.isHidden = false
        }
    }
    

}
