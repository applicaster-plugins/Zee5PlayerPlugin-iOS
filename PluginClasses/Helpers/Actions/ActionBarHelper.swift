//
//  ActionBarHelper.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 26.04.20.
//

import Foundation

import ZappPlugins

class ActionBarHelper {
    static func setup(playable: ZeePlayable, actionBarView: ActionBarView) {
        actionBarView.resetButtons()
        
        let consumptionFeedType = playable.consumptionType
        let buisnessType = playable.businessType
        
        var builders: [ActionButtonBuilder.Type] = []
        
        builders.append(ShareActionButtonBuilder.self)

        if !ExtensionsHelper.isLive(consumptionFeedType) {
            builders.append(WatchListActionButtonBuilder.self)
        }
        
        builders.append(CastActionButtonBuilder.self)

        if ExtensionsHelper.isDownloadable(consumptionFeedType, buisnessType) {
            builders.append(DownloadActionButtonBuilder.self)
        }
        
        if consumptionFeedType == .movie || consumptionFeedType == .episode || consumptionFeedType == .show || consumptionFeedType == .original {
            builders.append(TrailerActionButtonBuilder.self)
        }
        
        for builder in builders {
            let instance = builder.init(playable)
            
            guard let button = instance.build() else {
                continue
            }
            
            let handler = actionBarView.addButton(button)
            instance.setActionBarUpdateHandler(handler)
            instance.fetchInitialState()
        }
    }
}
