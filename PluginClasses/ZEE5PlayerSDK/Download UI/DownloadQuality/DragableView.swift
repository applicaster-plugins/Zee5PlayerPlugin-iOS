//
//  DragableViewHelper.swift
//  Zee5PlayerPlugin
//
//  Created by Abhishek on 28/01/20.
//

import UIKit

public extension UIView {
    
    @objc func makeDragable() {
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDragView(_:))))
    }
    
    @objc fileprivate func onDragView(_ sender: UIPanGestureRecognizer) {
        let percentThreshold: CGFloat = 0.3
        let translation = sender.translation(in: self)
        
        let newY = ensureRange(value: self.frame.minY + translation.y, minimum: 0, maximum: self.frame.maxY)
        let progress = progressAlongAxis(newY, self.bounds.height)
        
        self.frame.origin.y = newY
        
        if sender.state == .ended {
            let velocity = sender.velocity(in: self)
            if velocity.y >= 300 || progress > percentThreshold {
                DownloadHelper.shared.removeDownloadOptionMenu()
                ZEE5PlayerManager .sharedInstance() .removeSubview()
                
                
            }
            else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.frame.origin.y = 0
                })
            }
        }
        sender.setTranslation(.zero, in: self)
    }

    fileprivate func progressAlongAxis(_ pointOnAxis: CGFloat, _ axisLength: CGFloat) -> CGFloat {
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
        let positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
        return CGFloat(positiveMovementOnAxisPercent)
    }

    fileprivate func ensureRange<T>(value: T, minimum: T, maximum: T) -> T where T : Comparable {
        return min(max(value, minimum), maximum)
    }
}
