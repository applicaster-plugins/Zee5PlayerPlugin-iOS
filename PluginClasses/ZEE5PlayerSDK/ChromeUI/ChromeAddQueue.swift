//
//  ChromeAddQueue.swift
//  ZEE5PlayerSDK
//
//  Created by Abhishek on 25/11/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

import UIKit

public enum ChromQueueMenu {
    case play
    case queue
    case cancel
}

protocol ChromeQueueMenuDelegate: class {
    func didSelectMenu(for option: ChromQueueMenu)
}

class ChromeAddQueue: UIView {

    static let identifier = "ChromeAddQueue"
    
    weak var delegate: ChromeQueueMenuDelegate?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func actionPlay(_ sender: Any) {
        self.delegate?.didSelectMenu(for: .play)
    }
    
    @IBAction func actionAddToQueue(_ sender: Any) {
        self.delegate?.didSelectMenu(for: .queue)
    }
    
    @IBAction func actionRemoveMenu(_ sender: Any) {
        self.delegate?.didSelectMenu(for: .cancel)
    }
}
