//
//  KalturaPlayerController+playerDisplayMode.swift
//  Zee5PlayerPlugin
//
//  Created by Miri on 23/03/2020.
//

import Foundation
import ApplicasterSDK

extension KalturaPlayerController {
    
    func changePlayer(displayMode: PlayerViewDisplayMode, completion: (() -> Void)? = nil) {
        if let currentDisplayMode = self.currentDisplayMode,
            displayMode == currentDisplayMode {
            APLoggerDebug("Trying to switch to same display mode as currently presented")
            return
        }
        
        switch displayMode {
        case .inline:
            if previousParentViewController != nil {
                self.currentDisplayMode = .inline
                self.dismiss(animated: false, completion: {
                    self.previousParentViewController?.addChildViewController(self, to: self.previousContainerView)
                    self.previousParentViewController = nil
                    self.previousContainerView = nil
                    completion?()
                })
            } else {
                APLoggerError("No previous parent view controller - can't move to inline");
                return;
            }
            break
        case .fullScreen:
            if self.currentDisplayMode == .inline {
                self.previousParentViewController = self.parent
                self.previousContainerView = self.view.superview
                self.removeViewFromParentViewController()
                self.currentDisplayMode = .fullScreen;
                self.modalPresentationStyle = .fullScreen

                ZAAppConnector.sharedInstance().navigationDelegate.topmostModal()?.present(self, animated: false, completion: {
                    completion?()
                    ZEE5PlayerManager.sharedInstance().play()
                })
            }
            break
            
        case .mini:
            self.currentDisplayMode = .mini;
            break
            
        default:
            break
        }
    }
    
}
