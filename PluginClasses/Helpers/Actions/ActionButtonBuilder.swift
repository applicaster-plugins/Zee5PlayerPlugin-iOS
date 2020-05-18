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
    func build() -> ActionBarView.ButtonData?
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
        return StylesHelper.style(for: key)
    }
}
