//
//  DownloadOptionCell.swift
//  Zee5DownloadSDK
//
//  Created by User on 27/09/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit
import DropDown
import DownloadToGo

protocol DownloadOptionDelegate: class {
    func didSelectMenuOption(dataIndex: Int, downloadMenuOption: String)

    func updateProgressMenu(contentId: String, progress: UICircularProgressRing, buttonState: UIButton, viewPause: UIView, downloadedByte: Int64, estimatedByte: Int64)
}

enum DownloadStateMenu {
    case play
    case retry
    case pause
    case resume
    case deleteDownload
    case cancelDownload
    case restoreDownload
    
    var description: String {
        switch self {
    case .play:
        return PlayerConstants.localizedKeys.Downloads_ListItemOverflowMenu_Play_MenuItem.rawValue.localized()
            
    case .retry:
        return PlayerConstants.localizedKeys.Downloads_ListItemOverflowMenu_RetryDownload_MenuItem.rawValue.localized()
    case .pause:
        return PlayerConstants.localizedKeys.Downloads_OverflowMenu_Pause_Button.rawValue.localized()
            
    case .resume:
            return PlayerConstants.localizedKeys.Downloads_OverflowMenu_Resume_Button.rawValue.localized()
            
    case .deleteDownload:
        return PlayerConstants.localizedKeys.Downloads_ListItemOverflowMenu_DeleteDownload_MenuItem.rawValue.localized()
            
    case .cancelDownload:
        return PlayerConstants.localizedKeys.Downloads_ListItemOverflowMenu_CancelDownload_MenuItem.rawValue.localized()
            
    case .restoreDownload:
        return PlayerConstants.localizedKeys.Downloads_ListItemDetails_RestoreDownload_Link.rawValue.localized()
        }
    }
}

class DownloadOptionCell: UITableViewCell {

    static let identifier = "DownloadOptionCell"
    
    public weak var delegate: DownloadOptionDelegate?
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblDownloading: UILabel!
    
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var viewProgress: UIView!
    @IBOutlet weak var viewPause: UIView!
    @IBOutlet weak var progressVideo: UIProgressView!
    
    private var menuDownload = DropDown()
    private var circularRing = UICircularProgressRing()
    private let bundle = Bundle(for: DownloadRootController.self)
    
    private var currentItem: DownloadItem? {
        didSet {
            
            // For show/episodes
            if currentItem?.assetType == "1" {
                self.lblTitle.text = "\(self.currentItem?.episodeNumber ?? 0) - \(self.currentItem?.title ?? "")"
            }
            else {
                self.lblTitle.text = self.currentItem?.title
            }
            self.imgView.setImage(with: self.currentItem?.imgUrl)
            
            let totalSize = ByteCountFormatter.string(fromByteCount: self.currentItem?.estimatedBytes ?? 0, countStyle: .file)
            
            let duration = Double(self.currentItem?.duration ?? 0).asString(style: .abbreviated)
            self.lblInfo.text = "\(duration) • \(totalSize)"
            
            if self.currentItem?.downloadState == .inProgress {
//                self.lblDownloading.text = "\(PlayerConstants.localizedKeys.Downloads_ListItemDetails_Downloading_Text.rawValue.localized()...)"
                self.lblDownloading.text = "Downloading..."
            }
            else if self.currentItem?.downloadState == .paused {
                self.lblDownloading.text = PlayerConstants.localizedKeys.Downloads_ListItemDetails_Paused_Text.rawValue.localized()
            }
            else if self.currentItem?.downloadState == .expired {
                self.lblDownloading.text = PlayerConstants.localizedKeys.Downloads_ListItemDetails_DownloadExpired_Text.rawValue.localized()
            }
            self.lblDownloading.isHidden = self.currentItem?.downloadState == .completed ? true : false
            self.lblDownloading.textColor = self.currentItem?.downloadState == .expired ? .red : AppColor.aquaGreen
            
            // Checking download state image and progress bar
            if self.currentItem?.downloadState == .inProgress {
                self.viewProgress.isHidden = false
                self.btnDownload.isHidden = true
                
                self.viewPause.isHidden = true
            }
            else {
                self.btnDownload.isHidden = false
                self.viewProgress.isHidden = true
                self.viewPause.isHidden = true
                
                if self.currentItem?.downloadState == .completed {
                    if #available(iOS 13.0, *) {
                        let img = UIImage(named: "complete_download", in: bundle, with: nil)
                        self.btnDownload.setImage(img, for: .normal)
                    } else {
                        // Fallback on earlier versions
                        let ab = UIImage(named: "complete_download", in: bundle, compatibleWith: nil)
                        self.btnDownload.setImage(ab, for: .normal)
                    }
                }
                else if self.currentItem?.downloadState == .failed || self.currentItem?.downloadState == .interrupted || self.currentItem?.downloadState == .dbFailure || self.currentItem?.downloadState == .expired {
                    if #available(iOS 13.0, *) {
                        let img = UIImage(named: "error_download", in: bundle, with: nil)
                        self.btnDownload.setImage(img, for: .normal)
                    } else {
                        // Fallback on earlier versions
                        let ab = UIImage(named: "error_download", in: bundle, compatibleWith: nil)
                        self.btnDownload.setImage(ab, for: .normal)
                    }
                }
                else if self.currentItem?.downloadState == .paused {
                    self.btnDownload.isHidden = true
                    self.viewProgress.isHidden = false
                    self.viewPause.isHidden = false
                }
            }

            // Upadating progress bar
            if let downloadedBytes = self.currentItem?.downloadedBytes, let estimatedBytes = self.currentItem?.estimatedBytes, estimatedBytes > 0 {
                let percentage = CGFloat(downloadedBytes) / CGFloat(estimatedBytes) * CGFloat(100)
                
                if self.currentItem?.downloadState == .completed {
                    self.circularRing.value = 100
                }
                else if let size = self.currentItem?.estimatedBytes, size > 0 {
                    self.circularRing.value = percentage
                }
                else {
                    self.circularRing.value = 0
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgView.contentMode = .scaleAspectFill
    }
    
    func loadCellData(with item: DownloadItem, at index: Int) {
        self.currentItem = item
        
        self.btnDownload.tag = index
        self.btnDownload.addTarget(self, action: #selector(self.actionDownload(_:)), for: .touchUpInside)
        
        if item.downloadState == .inProgress {
            self.setupDownloadCircularBar(at: index, for: item.contentId ?? "")
        }
        else if item.downloadState == .completed {
            self.setupDownloadMenu(with: [.play, .deleteDownload], at: index)
        }
        else if item.downloadState == .failed || item.downloadState == .interrupted || item.downloadState == .dbFailure {
            self.setupDownloadMenu(with: [.retry, .cancelDownload], at: index)
        }
        else if item.downloadState == .expired {
            self.setupDownloadMenu(with: [.restoreDownload, .deleteDownload], at: index)
        }
        
        if let played = item.videoPlayedDuration, let total = item.duration {
            let value = Float(played)/Float(total)
            self.progressVideo.setProgress(value, animated: true)
            self.progressVideo.isHidden = played > 0 ? false : true
        }
    }

    @objc private func actionDownload(_ btn: UIButton) {
        if self.currentItem?.downloadState == .paused {
            let arr = [DownloadStateMenu.resume.description, DownloadStateMenu.cancelDownload.description]
            self.menuDownload.dataSource = arr
        }
        self.menuDownload.show()
    }
    
    private func setupDownloadCircularBar(at index: Int, for contentId: String) {
        self.circularRing.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        self.circularRing.center = CGPoint(x: self.viewProgress.frame.width / 2 - 3, y: self.viewProgress.frame.height / 2)
        self.circularRing.tag = index
        self.circularRing.accessibilityIdentifier = contentId
        
        self.circularRing.startAngle = -90
        self.circularRing.style = .bordered(width: 0, color: AppColor.progressGray)
        self.circularRing.outerCapStyle = .round
        self.circularRing.outerRingColor = AppColor.progressGray
        self.circularRing.outerRingWidth = 2.5
        
        self.circularRing.innerCapStyle = .round
        self.circularRing.innerRingColor = AppColor.aquaGreen
        self.circularRing.innerRingWidth = 2.5
        self.circularRing.innerRingSpacing = 0
        
        self.circularRing.shouldShowValueText = false
        self.viewProgress.addSubview(self.circularRing)
        
        self.setupDownloadMenu(with: [.pause, .cancelDownload], at: index)
        
        // Progress button for events
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: self.viewProgress.frame.size.width, height: self.viewProgress.frame.size.height))
        btn.tag = index
        btn.addTarget(self, action: #selector(self.actionDownload(_:)), for: .touchUpInside)
        self.viewProgress.addSubview(btn)
        
        //
        self.updateProgressView()
    }
    
    private func setupDownloadMenu(with data: [DownloadStateMenu], at idx: Int) {
        let appearance = DropDown.appearance()
        appearance.backgroundColor = .white
        appearance.textColor = UIColor(hex: "333333")
        appearance.textFont = AppFont.regular(size: 16)
        appearance.cellHeight = 50
        appearance.selectionBackgroundColor = .clear
        appearance.selectedTextColor = UIColor(hex: "333333")
        appearance.layer.cornerRadius = 6
        
        self.menuDownload.anchorView = self.btnDownload
        self.menuDownload.direction = .any
        self.menuDownload.bottomOffset = CGPoint(x: 0, y: self.btnDownload.bounds.height)
        
        self.menuDownload.dataSource = data.map {($0.description)}
        self.menuDownload.cellNib = UINib(nibName: DownloadMenuCell.identifier, bundle: bundle)
        
        self.menuDownload.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? DownloadMenuCell else { return }
            cell.optionLabel.text = item
        }
        self.menuDownload.selectionAction = { [weak self] (index: Int, item: String) in
            self?.delegate?.didSelectMenuOption(dataIndex: idx, downloadMenuOption: item)
        }
    }
    
    //
    func updateProgressView() {
        
        if let id = self.currentItem?.contentId, let downloadedByte = self.currentItem?.downloadedBytes, let estimatedByte = self.currentItem?.estimatedBytes {

            self.delegate?.updateProgressMenu(contentId: id, progress: self.circularRing, buttonState: self.btnDownload, viewPause: self.viewPause, downloadedByte: downloadedByte, estimatedByte: estimatedByte)
        }
    }
}
