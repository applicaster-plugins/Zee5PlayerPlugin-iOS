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
    func build() -> ActionBarView.ButtonData? {
        guard
            let image = self.image(for: "consumption_share"),
            let title = self.localizedText(for: "MoviesConsumption_MovieDetails_Share_Link"),
            let style = self.style(for: "consumption_button_text") else {
                return nil
        }
                
        return ActionBarView.ButtonData(
            image: image,
            selectedImage: nil,
            title: title,
            font: style.font,
            textColor: style.color,
            isFiller: false,
            custom: nil,
            action: self.share
        )
    }
    
    func fetchInitialState() {
    }
    
    fileprivate func share() {
        ZEE5PlayerManager.sharedInstance().tapOnShareButton()
    }
}
