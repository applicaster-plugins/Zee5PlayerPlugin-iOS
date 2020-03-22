//
//  VideoQualityCell.swift
//  Zee5DownloadSDK
//
//  Created by Abhishek on 08/01/20.
//  Copyright © 2020 Logituit. All rights reserved.
//

import UIKit

class VideoQualityCell: UITableViewCell {
    
    static let identifer = "VideoQualityCell"
    
    @IBOutlet weak var btnRadio: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!

    public var selectedOption: Z5Option? {
        didSet {
            self.lblTitle.text = selectedOption?.resolution
            self.lblSubtitle.text = "1 hour of video uses approx. \(selectedOption?.size ?? "0.0") GB of data/storage"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.btnRadio.isSelected = selected
    }
}
