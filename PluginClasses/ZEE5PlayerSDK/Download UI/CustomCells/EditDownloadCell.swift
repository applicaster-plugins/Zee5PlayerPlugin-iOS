//
//  EditDownloadCell.swift
//  DemoProject
//
//  Created by cepl on 17/09/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit

class EditDownloadCell: UITableViewCell {
    
    static let identifier = "EditDownloadCell"
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var btnRadio: UIButton!
    
    public var currentItem: DownloadItem? {
        didSet {
            if let item = currentItem {
//                if item.assetType ?? "0" == "1" { // Episode
                if item.originalTitle != nil { // Episode
                    lblTitle.text = item.originalTitle
                    let totalSize = ByteCountFormatter.string(fromByteCount: Int64(item.noOfBytes ?? "0") ?? 0, countStyle: .file)
                    lblInfo.text = "\(item.noOfEpisodes ?? "") Episodes • \(totalSize)"
                }
                else { // Movie, Show-Detail
                    lblTitle.text = item.title
                    let totalSize = ByteCountFormatter.string(fromByteCount: item.estimatedBytes ?? 0, countStyle: .file)
                    
                    let duration = Double(item.duration ?? 0).asString(style: .abbreviated)
                    lblInfo.text = "\(duration) • \(totalSize)"
                }
                imgView.setImage(with: item.imgUrl)
                btnRadio.isSelected = item.isSelected
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
