//
//  Zee5PluggablePlayer+HyBridViewControllerDelegate.swift
//  Zee5PlayerPlugin
//
//  Created by Miri on 27/12/2018.
//

import Foundation

extension Zee5PluggablePlayer {

    @objc public func openHyBridViewController() {
        self.hybridViewController?.playerViewController?.changePlayerDisplayMode(.inline)
    }

    public func hyBridPlayerControlsView() -> (UIView & APPlayerControls)? {
        var controlsView: (UIView & APPlayerControls)?

        if let playerControlsView = (Bundle(for: Zee5PluggablePlayer.self).loadNibNamed("HybridPlayerControlsView", owner: self, options: nil)?.first) {
            controlsView = playerControlsView as? UIView & APPlayerControls
        }
        return controlsView
    }

    public func hyBridPlayerContainerView() -> UIView? {
        return self.hybridViewController?.playerContainer
    }

    public func closeHyBridPlayer() {

    }
}
