//
//  NewEpisodeDownloadCell.swift
//  DemoProject
//
//  Created by Abbas's Mac Mini on 16/09/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit

class NewEpisodeDownloadCell: UITableViewCell {
    
    static let identifier = "NewEpisodeDownloadCell"
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblNewEpisode: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblNewEpisode.roundCorners(corners: [.bottomLeft], radius: 8.0)
    }
    
    @IBAction func actionCancel(_ sender: UIButton) {
        NotificationCenter.default.post(name: AppNotification.cancelNewEpisode, object: nil)
    }
    
    @IBAction func actionStartDownload(_ sender: UIButton) {
        NotificationCenter.default.post(name: AppNotification.downloadNewEpisode, object: nil)
    }
}
