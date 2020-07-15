//
//  EmptyView.swift
//  Zee5DownloadSDK
//
//  Created by Abhishek Gour on 24/10/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit

class EmptyView: UIView {
    
    static let identifier = "EmptyView"

    @IBOutlet weak var btnDownload: UIButton!
    
    public var currentView: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnDownload.layer.applyGradientBorder(withColors: AppColor.gradient, radius: self.btnDownload.frame.size.height / 2)
        self.btnDownload .setTitle(PlayerConstants.localizedKeys.Downloads_CTA_BrowseToDownload_Button.rawValue.localized(), for: UIControl.State.normal)
        self.btnDownload.titleLabel?.textColor = UIColor.init(hexColor: "FF0091")
    }
    
    @IBAction func actionBrowseDownload(_ sender: Any) {
        
        ZEE5PlayerDeeplinkManager.sharedMethod.NavigatetoHomeScreen()
    }
}
