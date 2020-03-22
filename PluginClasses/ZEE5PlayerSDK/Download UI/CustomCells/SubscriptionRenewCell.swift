//
//  SubscriptionRenewCell.swift
//  DemoProject
//
//  Created by Abbas's Mac Mini on 17/09/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit

class SubscriptionRenewCell: UITableViewCell {

    static let identifier = "SubscriptionRenewCell"
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnRemindLater: UIButton!
    @IBOutlet weak var btnRenewNow: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.btnRemindLater.layer.applyGradientBorder(withColors: AppColor.gradient, radius: self.btnRemindLater.frame.size.height / 2)
        
        self.btnRenewNow.applyGradient(withColors: AppColor.gradient)
        
        let str = self.makeAttributedString(first: "Your Premium Subscription expires in ", second: "10 days")
        self.lblTitle.attributedText = str
    }
    
    @IBAction func actionRemindLater(_ sender: UIButton) {
        NotificationCenter.default.post(name: AppNotification.remindLater, object: nil)
    }
    
    @IBAction func actionRenewNow(_ sender: UIButton) {
        NotificationCenter.default.post(name: AppNotification.renewNow, object: nil)
    }
    
    func makeAttributedString(first: String, second: String) -> NSMutableAttributedString {
        
        let firstAttributes = [
            NSAttributedString.Key.foregroundColor: AppColor.lightGray,
            NSAttributedString.Key.font: AppFont.semibold(size: 15)
        ]
         
        let secondAttributes = [
            NSAttributedString.Key.foregroundColor: AppColor.pink,
            NSAttributedString.Key.font: AppFont.semibold(size: 15)
        ]
         
        let firstString = NSMutableAttributedString(string: first, attributes: firstAttributes)
        let secondString = NSMutableAttributedString(string: second, attributes: secondAttributes)
         
        let combination = NSMutableAttributedString()
         
        combination.append(firstString)
        combination.append(secondString)
     
        return combination
    }
}
