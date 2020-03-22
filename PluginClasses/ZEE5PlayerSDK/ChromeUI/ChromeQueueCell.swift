//
//  ChromeQueueCell.swift
//  Zee5DownloadSDK
//
//  Created by Abhishek Gour on 06/11/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit
import DropDown

protocol QueueOptionDelegate:class {
    func didSelectMenuOption(dataIndex: Int, queueMenuOption: String)
    
    func showQueueMenu()
    func hideQueueMenu()
}

enum QueueOptionMenu {
    case addToMyWatchList
    case clearQueue
    case subTitles
    case languages
    case videoQuality
    
    var description:String {
        switch self {
        case .addToMyWatchList: return "Add To WatchList"
        case .clearQueue:       return "Clear Queue"
        case .subTitles:        return "Subtitles"
        case .languages:        return "Languages"
        case .videoQuality:     return "Video Quality"
        }
    }
}
class ChromeQueueCell: UITableViewCell {

    static let identifier = "ChromeQueueCell"
    
    public weak var delegate: QueueOptionDelegate?
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var btnArrange: UIButton!
    
    var menuDropDown = DropDown()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadCellData(with item :DownloadItem, at index : Int){
        self.btnArrange.tag = index
        self.btnArrange.addTarget(self, action: #selector(actionSetting(_btn:)), for: .touchUpInside)
        self.setUpQueueMenu(with: [.subTitles,.languages,.videoQuality], at: index)
    }
    
    @objc private func actionSetting(_btn :UIButton){
        let arr = [QueueOptionMenu.subTitles.description,QueueOptionMenu.languages.description,QueueOptionMenu.videoQuality.description]
        self.menuDropDown.dataSource = arr
        self.menuDropDown.show()
    }
    
    func setUpQueueMenu(with data: [QueueOptionMenu], at index: Int){
        let appearance = DropDown.appearance()
        appearance.backgroundColor = .white
        appearance.textColor = UIColor(hex: "333333")
        appearance.textFont = AppFont.regular(size: 16)
        appearance.cellHeight = 50
        appearance.selectionBackgroundColor = .clear
        appearance.selectedTextColor = UIColor(hex: "333333")
        appearance.layer.cornerRadius = 10
        
        self.menuDropDown.anchorView = self.btnArrange
        self.menuDropDown.direction = .any
        self.menuDropDown.bottomOffset = CGPoint(x: 0, y: self.btnArrange.bounds.height)
        
        self.menuDropDown.dataSource = data.map {($0.description)}
        let bundle = Bundle(for: ChromeCastManager.self)
        self.menuDropDown.cellNib = UINib(nibName: DownloadMenuCell.identifier, bundle: bundle)
        
        self.menuDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? DownloadMenuCell else { return }
            cell.optionLabel.text = item
        }
        self.menuDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            self?.delegate?.didSelectMenuOption(dataIndex: index, queueMenuOption: item)
        }
        
        self.menuDropDown.willShowAction = {
            self.delegate?.showQueueMenu()
        }
        
        self.menuDropDown.cancelAction = {
            self.delegate?.hideQueueMenu()
        }
    }
}
