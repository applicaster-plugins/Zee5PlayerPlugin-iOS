//
//  DownloadTableCell.swift
//  DemoProject
//
//  Created by Abbas's Mac Mini on 13/09/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit

class DownloadTableCell: UITableViewCell {
    
    static let identifier = "DownloadTableCell"
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblDownloading: UILabel!
    
    public var currentShow: DownloadItem? {
        didSet {
            if let show = currentShow {
                lblTitle.text = show.originalTitle
                let totalSize = ByteCountFormatter.string(fromByteCount: Int64(show.noOfBytes ?? "0") ?? 0, countStyle: .file)
                lblInfo.text = "\(show.noOfEpisodes ?? "") Episodes • \(totalSize)"
                lblDownloading.text = "Downloading \(show.pendingDownloads ?? "") of \(show.noOfEpisodes ?? "")"
                lblDownloading.isHidden = show.downloadState == .inProgress ? false : true
                imgView.setImage(with: show.showimgUrl)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
