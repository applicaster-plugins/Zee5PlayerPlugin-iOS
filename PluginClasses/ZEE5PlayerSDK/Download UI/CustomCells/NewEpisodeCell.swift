//
//  NewEpisodeCell.swift
//  Zee5DownloadSDK
//
//  Created by User on 27/09/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit

class NewEpisodeCell: UITableViewCell {

    static let identifier = "NewEpisodeCell"
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func actionSelectContent(_ sender: UIButton) {
        ZeeUtility.utility.console("CONTENT: actionSelectContent ***")
    }
}
