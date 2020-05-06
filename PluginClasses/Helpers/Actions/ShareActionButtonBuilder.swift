//
//  ShareActionButtonBuilder.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 26.04.20.
//

import Foundation

import ZappPlugins
import ApplicasterSDK

class ShareActionButtonBuilder: BaseActionButtonBuilder, ActionButtonBuilder {
    func build() -> ActionBarView.Button? {
        guard
            let image = self.image(for: "consumption_share"),
            let title = self.localizedText(for: "MoviesConsumption_MovieDetails_Share_Link"),
            let style = self.style(for: "consumption_button_text") else {
                return nil
        }
                
        return ActionBarView.Button(
            image: image,
            selectedImage: nil,
            title: title,
            font: style.font,
            textColor: style.color,
            custom: nil,
            action: self.share
        )
    }
    
    func fetchInitialState() {
    }
    
    fileprivate func share() {
        guard
            let extensions = playable.extensionsDictionary as? [String: Any],
            let shareLink = extensions[ExtensionsKey.shareLink] as? String else {
                return
        }
        
        guard
            let linkAtomEntry = APAtomEntry.linkEntry(withURLString: shareLink) else {
                return
        }
        
        guard let urlComponents = URLComponents(string: shareLink) else {
            return
        }
        
        linkAtomEntry.link = urlComponents.string
        linkAtomEntry.title = playable.playableName()
        linkAtomEntry.entryType = .link
        
        APSocialSharingManager.sharedInstance().shareWithDefaultText(withModel: linkAtomEntry, andSharingType: APSharingViaNativeType)
        
        // Send analytics:
        let parameters = [
            "sharingType" : "native",
            "location"    : "iOS Unknown"
        ]
        
        NotificationCenter.default.post(name: NSNotification.Name.caCellTappedShareButton, object: linkAtomEntry, userInfo: parameters as [AnyHashable : Any])
    }
}
