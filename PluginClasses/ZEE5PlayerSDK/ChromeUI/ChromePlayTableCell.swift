//
//  ChromePlayTableCell.swift
//  Zee5DownloadSDK
//
//  Created by Abhishek Gour on 06/11/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit

class ChromePlayTableCell: UITableViewCell {

    static let identifier = "ChromePlayTableCell"
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
