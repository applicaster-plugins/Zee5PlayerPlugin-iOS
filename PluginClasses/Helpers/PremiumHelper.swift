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
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var imageView: UIImageView!
    @IBOutlet fileprivate var heightConstraint: NSLayoutConstraint!

    fileprivate var observer: NSObjectProtocol?
    fileprivate let premiumHelper = PremiumHelper()
    
    fileprivate var originalHeightValue = CGFloat(0)
    
    func setupBanner(playable: ZPPlayable?) {
        self.originalHeightValue = self.heightConstraint.constant
        
        self.observer = NotificationCenter.default.addObserver(forName: .subscriptionFinished, object: nil, queue: nil,using: handleSubscription)

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(handleBannerAction))
        addGestureRecognizer(tapGesture)
        self.premiumHelper.setupPremiumBanner(self, playable: playable)
    }
    
    func handleSubscription(notification: Notification) {
        self.premiumHelper.updatePremiumBanner(self)
    }
    
    @objc fileprivate func handleBannerAction() {
        self.premiumHelper.openSubscriptionScreen()
    }
}

fileprivate class PremiumHelper {
    fileprivate var playable: ZPPlayable?

    func setupPremiumBanner(_ banner: PremiumBanner, playable: ZPPlayable?) {
        banner.heightConstraint.constant = 0
        
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

        if let bannerStyle = StylesHelper.style(for: "consumption_text_description") {
            banner.titleLabel?.textColor = bannerStyle.color
            banner.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        }
        
        banner.titleLabel?.text = "Subscribe to premium today! Starting At RS 49"
        
        banner.backgroundColor = UIColor(red: 0.14, green: 0.04, blue: 0.13, alpha: 1.0)
        
        banner.isHidden = false
        banner.heightConstraint.constant = banner.originalHeightValue

    }
    
    func updatePremiumBanner(_ banner: PremiumBanner) {
        if User.shared.getType() == .premium {
            banner.heightConstraint.constant = 0
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
