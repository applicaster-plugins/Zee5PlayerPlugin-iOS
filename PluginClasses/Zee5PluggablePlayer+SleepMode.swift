//
//  Zee5PluggablePlayer+SleepMode.swift
//  Zee5PlayerPlugin
//
//  Created by Miri on 27/12/2018.
//

import Foundation

extension Zee5PluggablePlayer {

    func isSleepModeViewPresent() -> Bool {
        var retVal = false
        if let hybrid = self.hybridViewController,
            let sleepModeView = hybrid.sleepModeView {
            if sleepModeView.isDescendant(of: hybrid.view) {
                retVal = true
            }
            else if let playerVC = hybrid.playerViewController,
                sleepModeView.isDescendant(of: playerVC.view) {
                retVal = true
            }
        }
        return retVal
    }

    @objc func showSleepModeView() {
        if let hybrid = self.hybridViewController,
            hybrid.sleepModeView == nil {
            hybrid.sleepModeView = (Bundle(for: SleepModeView.self).loadNibNamed("SleepModeView", owner: self, options: nil)?.first) as? SleepModeView
        }

        if let hybrid = self.hybridViewController,
            let sleepModeView = hybrid.sleepModeView,
            self.isSleepModeViewPresent() == false {
            sleepModeView.size.width = hybrid.view.width
            sleepModeView.size.height = hybrid.view.height
            sleepModeView.top = hybrid.view.top
            sleepModeView.mainView.origin.y = hybrid.view.size.height
            sleepModeView.set(configuration: self.configurationJSON,pluginStyles: pluginStyles)
            sleepModeView.delegate = self

            if let playerVC = hybrid.playerViewController{
                if playerVC.currentDisplayMode == .fullScreen {
                    playerVC.view.addSubview(sleepModeView)
                    UIView.animate(withDuration: 0.3) {
                        sleepModeView.touchEventView.alpha = 0.5
                        sleepModeView.mainView.center.y -= sleepModeView.mainView.frame.height
                    }
                }
                else {
                    hybrid.view.addSubview(sleepModeView)
                    UIView.animate(withDuration: 0.3) {
                        sleepModeView.touchEventView.alpha = 0.5
                        sleepModeView.mainView.center.y -= sleepModeView.mainView.frame.height
                    }
                }
            }
        }
    }

    public func dismissSleepModeViewIfNeeded() {
        if self.isSleepModeViewPresent() == true,
            let hybrid = self.hybridViewController,
            let sleepModeView = hybrid.sleepModeView {
            UIView.animate(withDuration: 0.3, animations: {
                sleepModeView.touchEventView.alpha = 0.01
                sleepModeView.mainView.center.y += sleepModeView.frame.height
            }) { (success) in
                sleepModeView.removeFromSuperview()
            }
        }
    }

    @objc public func sleepModeConfiguration(minutes: Int) {
        self.hybridViewController?.playerViewController?.sleepModeConfiguration(minutes)
        if minutes == 0 {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
        else {
            self.sleepModeCountdown(value: NSNumber(value: minutes) )
        }
    }

    @objc func sleepModeCountdown(value: NSNumber) {
        print("value \(value)")
        self.sleepModeCountDown = value
        //        self.delegate.updateSleepModeCountDown(value: value) = value.intValue

        if value == 0 {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            if let hybrid = self.hybridViewController,
                let playerVC = hybrid.playerViewController,
                playerVC.currentDisplayMode == .fullScreen {
                hybrid.playerViewController?.dismiss(animated: true, completion: {
                    hybrid.playerViewController?.stop()
                })
            }
            else {
                self.hybridViewController?.playerViewController?.stop()
            }
        }
        else {
            self.hybridViewController?.playerViewController?.sleepModeCountDown(value)
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(self.sleepModeCountdown(value:)), with: value.intValue-1, afterDelay: 1.0)
        }
    }

    @objc func stopSleepMode() {
        self.sleepModeCountDown = 0
        self.sleepModeConfiguration(minutes: 0)
    }
}
