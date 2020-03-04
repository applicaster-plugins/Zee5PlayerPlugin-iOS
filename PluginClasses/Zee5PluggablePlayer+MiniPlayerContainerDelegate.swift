//
//  Zee5PluggablePlayer+MiniPlayerContainerDelegate.swift
//  Zee5PlayerPlugin
//
//  Created by Miri on 27/12/2018.
//

import Foundation

extension Zee5PluggablePlayer {

    public func showMiniPlayer() {
        self.hybridViewController?.playerViewController?.changePlayerDisplayMode(.mini)
    }

    public func miniPlayerContainerView() -> UIView? {
        var containerView: UIView?

        if self.miniPlayerView != nil {
            if let playerVC = self.self.hybridViewController?.playerViewController  {
                ZAAppConnector.sharedInstance().navigationDelegate.rootViewController()?.addChildViewController(playerVC , to: self.miniPlayerView?.playerView)
                self.miniPlayerView?.setStyles(playerViewController: playerVC,pluginStyles: pluginStyles)
            }
            return self.miniPlayerView
        }
        else if let miniPlayerView = (Bundle(for: MiniPlayerContainerView.self).loadNibNamed("MiniPlayerContainerView", owner: self, options: nil)?.first) as? MiniPlayerContainerView {
            miniPlayerView.delegate = self

            if let playerContainer = miniPlayerView.playerView,
                let playerVC = self.hybridViewController?.playerViewController {
                ZAAppConnector.sharedInstance().navigationDelegate.rootViewController()?.addChildViewController(playerVC , to: playerContainer)
                miniPlayerView.setStyles(playerViewController: playerVC, pluginStyles: pluginStyles)
            }

            self.miniPlayerView = miniPlayerView
            containerView = miniPlayerView
        }
        return containerView
    }

    public func miniPlayerControlsView() -> (UIView & APPlayerControls)? {
        var controlsView: (UIView & APPlayerControls)?

        if let playerControlsView = (Bundle(for: Zee5PluggablePlayer.self).loadNibNamed("MiniPlayerControlsView", owner: self, options: nil)?.first) {
            controlsView = playerControlsView as? UIView & APPlayerControls
        }
        return controlsView
    }

    public func closeMiniPlayer() {
        ZAAppConnector.sharedInstance().stickyViewDelegate.stickyViewRemove()
        self.miniPlayerView = nil
    }

    public func stopPlayer() {
        if let hybridViewController = self.hybridViewController,
            let playerViewController = hybridViewController.playerViewController {
            playerViewController.close(withCommercials: false, animated: true, shouldDismiss: true) {
                self.stop()
            }
        }
    }
}
