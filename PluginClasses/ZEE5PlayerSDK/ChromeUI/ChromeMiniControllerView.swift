//
//  ChromeMiniControllerView.swift
//  ZEE5PlayerSDK
//
//  Created by apple on 07/12/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

import UIKit
import GoogleCast

let kCastControlBarsAnimationDuration: TimeInterval = 0.20

class ChromeMiniControllerView: UIView, GCKUIMiniMediaControlsViewControllerDelegate {
    
    static let identifier = "ChromeMiniControllerView"
    
    fileprivate var mediaNotificationsEnabled = false
    fileprivate var firstUserDefaultsSync = false
    
    var isCastControlBarsEnabled: Bool {
        get {
            let castContainerVC = (window?.rootViewController as? GCKUICastContainerViewController)
            return castContainerVC!.miniMediaControlsItemEnabled
        }
        set(notificationsEnabled) {
            var castContainerVC: GCKUICastContainerViewController?
            castContainerVC = (window?.rootViewController as? GCKUICastContainerViewController)
            castContainerVC?.miniMediaControlsItemEnabled = notificationsEnabled
        }
    }
    
    @IBOutlet private var _miniMediaControlsContainerView: UIView!
    @IBOutlet private var _miniMediaControlsHeightConstraint: NSLayoutConstraint!
    
    private var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    
    var miniMediaControlsViewEnabled = false {
        didSet {
            updateControlBarsVisibility()
        }
    }
    
    var miniMediaControlsItemEnabled = false
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        installViewController()
        NotificationCenter.default.addObserver(self, selector: #selector(self.syncWithUserDefaults), name: UserDefaults.didChangeNotification, object: nil)
        firstUserDefaultsSync = true
        syncWithUserDefaults()
        
    }
    
    @objc func syncWithUserDefaults() {
        let mediaNotificationsEnabled = UserDefaults.standard.bool(forKey: kPrefEnableMediaNotifications)
        if firstUserDefaultsSync || (self.mediaNotificationsEnabled != mediaNotificationsEnabled) {
            self.mediaNotificationsEnabled = mediaNotificationsEnabled
            self.miniMediaControlsViewEnabled = mediaNotificationsEnabled
        }
        firstUserDefaultsSync = false
    }
    
    func updateControlBarsVisibility() {
        if miniMediaControlsViewEnabled , miniMediaControlsViewController.active{
            _miniMediaControlsHeightConstraint.constant = miniMediaControlsViewController.minHeight
            UIApplication.shared.keyWindow?.bringSubviewToFront(_miniMediaControlsContainerView)
        } else {
            _miniMediaControlsHeightConstraint.constant = 0
        }
        UIView.animate(withDuration: kCastControlBarsAnimationDuration, animations: { () -> Void in
            self._miniMediaControlsContainerView.layoutIfNeeded()
        })
        _miniMediaControlsContainerView.setNeedsLayout()
    }
    
    func installViewController() {
        let castContext = GCKCastContext.sharedInstance()
        miniMediaControlsViewController = castContext.createMiniMediaControlsViewController()
        miniMediaControlsViewController.delegate = self
        updateControlBarsVisibility()
        
        miniMediaControlsViewController.view.frame = _miniMediaControlsContainerView.bounds
        
        _miniMediaControlsContainerView.addSubview(miniMediaControlsViewController.view)
        
    }
    
    // MARK:- GCKUIMiniMediaControlsViewControllerDelegate
    func miniMediaControlsViewController(_: GCKUIMiniMediaControlsViewController, shouldAppear _: Bool) {
        updateControlBarsVisibility()
    }
}
