//
//  CastActionButtonBuilder.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 30.04.20.
//

import Foundation

import ZappPlugins
import GoogleCast

class CastActionButtonBuilder: BaseActionButtonBuilder, ActionButtonBuilder {
    func build() -> ActionBarView.Button? {
        guard
            let image = self.image(for: "consumption_cast"),
            let title = self.localizedText(for: "MoviesConsumption_MovieDetails_Cast_Link"),
            let style = self.style(for: "consumption_button_text") else {
                return nil
        }
        
        var selectedImage: UIImage? = nil
        if let selectedStyle = self.style(for: "consumption_text_indicator") {
            selectedImage = image.imageColoredIn(with: selectedStyle.color)
        }
        
        return ActionBarView.Button(
            image: image,
            selectedImage: selectedImage,
            title: title,
            font: style.font,
            textColor: style.color,
            custom: nil,
            action: cast
        )
    }
    
    func fetchInitialState() {
    }
    
    fileprivate func cast() {
        let cc = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        cc.sendActions(for: .touchUpInside)
    }
}
