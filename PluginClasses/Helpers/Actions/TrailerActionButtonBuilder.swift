//
//  TrailerActionButtonBuilder.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 03.05.20.
//

import Foundation

class TrailerActionButtonBuilder: BaseActionButtonBuilder, ActionButtonBuilder {
    fileprivate var trailerUrl: URL!
    
    func build() -> ActionBarView.Button? {
        guard
            let extensions = self.playable.extensionsDictionary,
            let trailerLink = extensions[ExtensionsKey.trailerDeeplink] as? String,
            let trailerUrl = URL(string: trailerLink) else {
                return nil
        }
        
        self.trailerUrl = trailerUrl
        
        guard
            let image = self.image(for: "consumption_play"),
            let title = self.localizedText(for: "MoviesConsumption_MovieDetails_WatchTrailer_Button"),
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
            action: play
        )
    }
    
    func fetchInitialState() {
    }
    
    fileprivate func play() {
        UIApplication.shared.open(self.trailerUrl, options: [:], completionHandler: nil)
    }
}
