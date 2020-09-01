//
//  TrailerActionButtonBuilder.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 03.05.20.
//

import Foundation

class TrailerActionButtonBuilder: BaseActionButtonBuilder, ActionButtonBuilder {
    fileprivate var trailerContentId: String!
    
    func build() -> ActionBarView.ButtonData? {
        guard
            let trailerContentId = self.playable.trailerContentId,
            let image = self.image(for: "consumption_play"),
            let title = self.localizedText(for: "MoviesConsumption_MovieDetails_WatchTrailer_Button"),
            let style = self.style(for: "consumption_button_text") else {
                return nil
        }
        
        self.trailerContentId = trailerContentId
                
        return ActionBarView.ButtonData(
            image: image,
            selectedImage: nil,
            title: title,
            font: style.font,
            textColor: style.color,
            isFiller: true,
            custom: nil,
            action: play
        )
    }
    
    func fetchInitialState() {
    }
    
    fileprivate func play() {
        guard let player = Zee5PluggablePlayer.lastActiveInstance() else {
            return
        }
        AnalyticEngine.shared.CTAs(with: "CTA", ctaname: "Watch Trailer")
        player.updateContent(self.trailerContentId)
    }
}
