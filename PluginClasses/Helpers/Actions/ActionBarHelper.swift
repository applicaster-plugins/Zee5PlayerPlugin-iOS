//
//  ActionBarHelper.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 26.04.20.
//

import Foundation

import ZappPlugins

public class ActionBarHelper {
    public static func setup(playable: ZPAtomEntryPlayableProtocol, consumptionFeedType: ConsumptionFeedType, actionBarView: ActionBarView) {
        actionBarView.resetButtons()
                
        var builders: [ActionButtonBuilder.Type] = []
        
        builders.append(ShareActionButtonBuilder.self)

        if consumptionFeedType != .live && consumptionFeedType != .channel {
            builders.append(WatchListActionButtonBuilder.self)
        }
        
        builders.append(CastActionButtonBuilder.self)

        if consumptionFeedType != .live && consumptionFeedType != .channel && consumptionFeedType != .show && consumptionFeedType != .original {
            builders.append(DownloadActionButtonBuilder.self)
        }
        
        if consumptionFeedType == .movie || consumptionFeedType == .episode || consumptionFeedType == .show || consumptionFeedType == .original {
            builders.append(TrailerActionButtonBuilder.self)
        }
        
        for builder in builders {
            let instance = builder.init(playable, consumptionFeedType)
            
            guard let button = instance.build() else {
                continue
            }
            
            let handler = actionBarView.addButton(button)
            instance.setActionBarUpdateHandler(handler)
            instance.fetchInitialState()
        }
    }
}
