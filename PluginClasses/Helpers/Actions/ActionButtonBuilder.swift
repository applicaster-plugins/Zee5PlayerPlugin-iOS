//
//  ActionButtonBuilder.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 26.04.20.
//

import Foundation

import ZappPlugins

protocol ActionButtonBuilder {
    init(_ playable: ZeePlayable)
    func build() -> ActionBarView.ButtonData?
    func setActionBarUpdateHandler(_ handler: ActionBarUpdateHandler)
    func fetchInitialState()
}

class BaseActionButtonBuilder {
    public let playable: ZeePlayable
    public let consumptionFeedType: ConsumptionFeedType
    public var actionBarUpdateHandler: ActionBarUpdateHandler!

    required public init(_ playable: ZeePlayable) {
        self.playable = playable
        self.consumptionFeedType = playable.consumptionType
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
