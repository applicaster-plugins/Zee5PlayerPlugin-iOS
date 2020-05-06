//
//  ActionButtonBuilder.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 26.04.20.
//

import Foundation

import ZappPlugins

public protocol ActionButtonBuilder {
    init(_ playable: ZPAtomEntryPlayableProtocol, _ consumptionFeedType: ConsumptionFeedType)
    func build() -> ActionBarView.Button?
    func setActionBarUpdateHandler(_ handler: ActionBarUpdateHandler)
    func fetchInitialState()
}

public class BaseActionButtonBuilder {
    public let playable: ZPAtomEntryPlayableProtocol
    public let consumptionFeedType: ConsumptionFeedType
    public var actionBarUpdateHandler: ActionBarUpdateHandler!

    required public init(_ playable: ZPAtomEntryPlayableProtocol, _ consumptionFeedType: ConsumptionFeedType) {
        self.playable = playable
        self.consumptionFeedType = consumptionFeedType
    }
    
    public func setActionBarUpdateHandler(_ handler: ActionBarUpdateHandler) {
        self.actionBarUpdateHandler = handler
    }
    
    public func image(for key: String) -> UIImage? {
        return ZAAppConnector.sharedInstance().image(forAsset: key) 
    }
    
    public func localizedText(for key: String) -> String? {
        return key.localized(hashMap: [:])
    }
    
    public func style(for key: String) -> (font: UIFont, color: UIColor)? {
        guard let style = ZAAppConnector.sharedInstance().layoutsStylesDelegate.styleParams?(byStyleName: key),
            let font = style["font"] as? UIFont,
            let color = style["color"] as? UIColor else {
                return nil
        }
        
        return (font, color)
    }
}
