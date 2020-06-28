//
//  KalturaPlayerController+playerDisplayMode.swift
//  Zee5PlayerPlugin
//
//  Created by Miri on 23/03/2020.
//

import Foundation
import ApplicasterSDK

extension KalturaPlayerController {
    func changePlayer(displayMode: PlayerViewDisplayMode, parentViewController: UIViewController, viewContainer: UIView, completion: (() -> Void)? = nil) {
        guard self.currentDisplayMode != displayMode else {
            return
        }
        
        switch displayMode {
        case .inline:
            if self.currentDisplayMode == .fullScreen {
                parentViewController.dismiss(animated: false, completion: {
                    parentViewController.addChildViewController(self, to: viewContainer)
                    self.currentDisplayMode = .inline
                    completion?()
                })
            }
            else {
                parentViewController.addChildViewController(self, to: viewContainer)
                self.currentDisplayMode = .inline
                completion?()
            }
 
            break
        case .fullScreen:
            guard self.currentDisplayMode == .inline else {
                completion?()
                return
            }
            
            self.removeViewFromParentViewController()
            
            self.modalPresentationStyle = .fullScreen
            
            parentViewController.present(self, animated: false, completion: {
                self.currentDisplayMode = .fullScreen
                completion?()
            })
            break
            
        case .mini:
            self.currentDisplayMode = .mini;
            completion?()
            break
            
        default:
            completion?()
            break
        }
    }
}
