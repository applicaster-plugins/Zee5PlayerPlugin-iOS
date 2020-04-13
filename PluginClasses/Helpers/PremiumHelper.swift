//
//  PremiumHelper.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 12.04.20.
//  Copyright © 2020 Miri. All rights reserved.
//

import Foundation

import ZappPlugins
import Zee5CoreSDK

fileprivate extension Notification.Name {
    static let subscriptionFinished = Notification.Name("sign_in_or_successfully")
}

class PremiumBanner: UIView {
    @IBOutlet fileprivate var button: UIButton?
    @IBOutlet fileprivate var imageView: UIImageView?
    
    fileprivate var observer: NSObjectProtocol?
    fileprivate let premiumHelper = PremiumHelper()
    
    func setupBanner(playable: ZPPlayable?) {
        self.observer = NotificationCenter.default.addObserver(forName: .subscriptionFinished, object: nil, queue: nil,using: handleSubscription)

        self.premiumHelper.setupPremiumBanner(self, playable: playable)
    }
    
    func handleSubscription(notification: Notification) {
        self.premiumHelper.updatePremiumBanner(self)
    }
    
    @IBAction fileprivate func handleButtonClick() {
        self.premiumHelper.openSubscriptionScreen()
    }
}

fileprivate class PremiumHelper {
    fileprivate var playable: ZPPlayable?

    func setupPremiumBanner(_ banner: PremiumBanner, playable: ZPPlayable?) {
        banner.isHidden = true
        
        guard let atom = playable, let extensions = atom.extensionsDictionary else {
            return
        }
        
        guard let isFree = extensions[ExtensionsKey.isFree] as? Bool, !isFree else {
            return
        }
        
        guard User.shared.getType() != .premium else {
            return
        }
        
        self.playable = playable
        
        banner.imageView?.image = UIImage.init(named: "item_locked_image_view")

                
        //        button.setTitleColor(premiumStyle.color, for: .normal)
        //        button.titleLabel?.font = premiumStyle.font
        
        banner.button?.setTitle("Subscribe to premium today! Starting At RS 49", for: .normal)
        
        banner.isHidden = false
    }
    
    func updatePremiumBanner(_ banner: PremiumBanner) {
        if User.shared.getType() == .premium {
            banner.isHidden = true
        }
    }
    
    func openSubscriptionScreen() {
        guard let atom = self.playable, let contentId = atom.identifier as String? else {
            return
        }
        
        let url = Zee5DeepLinkingManager.URLs.buySubscriptions(assetID: contentId, beforeTV: nil).url
        
        DispatchQueue.main.async {
            Zee5DeepLinkingManager.shared.openURL(withURL: url)
        }
    }
}
