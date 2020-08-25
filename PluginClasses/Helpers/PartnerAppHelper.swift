//
//  PartnerAppHelper.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 18.08.20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

import ZappPlugins
import Zee5CoreSDK

class PartnerAppView: UIView {
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var heightConstraint: NSLayoutConstraint!
    
    @IBAction fileprivate func handleTap() {
        if let playerManager = ZPPlayerManager.sharedInstance.lastActiveInstance as? Zee5PluggablePlayer {
            playerManager.stopAndDismiss()
        }
        
        ZEE5PlayerDeeplinkManager.sharedMethod.NavigateToPartnerApp()
    }
    
    func reset() {
        self.isHidden = true
        self.heightConstraint.constant = 0
        self.titleLabel.text = nil
    }
}

class PartnerAppHelper {
    static func setup(_ partnerAppView: PartnerAppView) {
        let (isTelcoUser, telcoUserData) = User.shared.isTelcoUser()
     
        if isTelcoUser, let telcoUserData = telcoUserData {
            var message = NSAttributedString(string: "")
            
            if (telcoUserData["partner"] ?? "").lowercased().contains("vodafone") {
                message = NSAttributedString(string: "BIStrings_CTA_BackToVodafonePlay_Button".localized(hashMap: [:]))
            }
            else if (telcoUserData["partner"] ?? "").lowercased().contains("airtel") {
                message = NSAttributedString(string: "Consumption_PlayerStrip_BackToAirtelTv_Text".localized(hashMap: [:]))
            }
            else if (telcoUserData["partner"] ?? "").lowercased().contains("idea") {
                message = NSAttributedString(string: "Consumption_PlayerStrip_BackToIdeaMovies_Text".localized(hashMap: [:]))
            }
            
            ZEE5PlayerManager.sharedInstance().telcouser(true, param: message.string)
            
            partnerAppView.isHidden = false
            partnerAppView.heightConstraint.constant = 30
            partnerAppView.titleLabel.text = String(format: "<  %@", message.string)
        }
        else {
            ZEE5PlayerManager.sharedInstance().telcouser(false, param: "")
            
            partnerAppView.reset()
        }
    }
}
