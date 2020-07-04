//
//  DownloadActionButtonBuilder.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 03.05.20.
//

import Foundation

import ZappPlugins

class DownloadActionButtonBuilder: BaseActionButtonBuilder, ActionButtonBuilder {

    func build() -> ActionBarView.ButtonData? {
        let titleKey: String
        switch self.consumptionFeedType {
        case .movie:
            titleKey = "MoviesConsumption_MovieDetails_Download_Button"
        case .show:
            titleKey = "ShowsConsumption_ShowDetails_Download_Button"
        case .music:
            titleKey = "MusicVideosConsumption_VideoDetails_Download_Button"
        default:
            titleKey = "VideosConsumption_VideoDetails_Download_Button"
        }
        
        guard
            let image = self.image(for: "consumption_download"),
            let title = self.localizedText(for: titleKey),
            let style = self.style(for: "consumption_button_text") else {
                return nil
        }
                
        return ActionBarView.ButtonData(
            image: image,
            selectedImage: nil,
            title: title,
            font: style.font,
            textColor: style.color,
            isFiller: false,
            custom: nil,
            action: download
        )
    }
    
    func fetchInitialState() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkDownloadInProgress), name: AppNotification.downloadedItemState, object: nil)
        self.checkDownloadInProgress()
     }
    
    fileprivate func currentContentId() -> String? {
        return self.playable.contentId
    }
    
    fileprivate func download() {
        if  let itemId = self.currentContentId(),
            let downloadItem = self.downloadedItem(for: itemId),
            downloadItem.downloadState == .new {

            try? Zee5DownloadManager.shared.removeDownloadItem(id: itemId)
        }

        ZEE5PlayerManager.sharedInstance().startDownload()
    }
    
    @objc fileprivate func checkDownloadInProgress() {
        guard
            let itemId = self.currentContentId(),
            let downloadItem = self.downloadedItem(for: itemId),
            downloadItem.downloadState != .new else {
                self.actionBarUpdateHandler.setInProgress(nil)
                return
        }
        
        let downloadProgressView = DownloadProgressView(downloadItem)
        self.actionBarUpdateHandler.setInProgress(downloadProgressView)
        return
    }
    
    fileprivate func downloadedItem(for id: String) -> DownloadItem? {
        guard let item = try? Zee5DownloadManager.shared.getItemById(id: id) else {
            return nil
        }
        
        let result = DownloadItem()
        
        result.contentId = item.contentId
        result.title = item.title
        result.showTitle = item.showOriginalTitle
        result.estimatedBytes = Int64(item.estimatedSize)
        result.downloadedBytes = Int64(item.downloadedSize)
        result.status = item.state.asString()
        result.downloadState = item.state
        result.imgUrl = item.imageURL
        result.duration = item.duration
        result.videoPlayedDuration = item.offlinePlayingDuration
        result.Agerating = item.Agerating
    
        return result
    }
}

fileprivate class DownloadProgressView: UIView {
    private let circularRing = UICircularProgressRing()
    private let toggleImageView = UIImageView()
    private let statusImageView = UIImageView()
    private let toggleButton = UIButton(type: .custom)

    private let downloadedItem: DownloadItem!

    public init(_ downloadItem: DownloadItem) {
        self.downloadedItem = downloadItem
        
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false

        self.updateProgress()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCircularValue), name: AppNotification.downloadedItemProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateState), name: AppNotification.downloadedItemState, object: nil)
    }
    
    required init?(coder: NSCoder) {
        self.downloadedItem = DownloadItem()

        super.init(coder: coder)
    }
    
    fileprivate func addStatusImageView(imageKey: String) {
        if self.statusImageView.superview == nil {
            self.addSubview(statusImageView)
            
            self.statusImageView.anchorCenteredToTop(size: CGSize(width: 20, height: 16), inset: 13)
            
            self.statusImageView.contentMode = .scaleAspectFit
        }
        
        self.statusImageView.image = Zee5ResourceHelper.imageNamed(imageKey)
    }
    
    fileprivate func addCircularBar(imageKey: String) {
        if self.circularRing.superview == nil {
            func addToggleImageView() {
                if self.toggleImageView.superview == nil {
                    self.circularRing.addSubview(self.toggleImageView)
                    
                    self.toggleImageView.centerInParent(size: CGSize(width: 20, height: 20))
                    
                    self.toggleImageView.contentMode = .scaleAspectFit
                }
                
                self.toggleImageView.image = Zee5ResourceHelper.imageNamed(imageKey)
            }
            
            self.addSubview(self.circularRing)
            
            self.circularRing.anchorCenteredToTop(size: CGSize(width: 27, height: 27), inset: 13)

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
            
            self.circularRing.minValue = 0
            self.circularRing.maxValue = 1

            self.circularRing.value = 0.0
            
            addToggleImageView()
        }
    }
    
    fileprivate func addToggleButton() {
        if self.toggleButton.superview == nil {
            self.addSubview(self.toggleButton)
            
            self.toggleButton.fillParent()
            
            self.toggleButton.addTarget(self, action: #selector(self.toggleDownload), for: .touchUpInside)
        }
    }
    
    @objc fileprivate func toggleDownload() {
        guard let itemId = self.downloadedItem.contentId else {
            return
        }
        
        if self.downloadedItem.downloadState == .paused {
            self.resumeDownloadItem(video: self.downloadedItem)
        }
        else {
            try? Zee5DownloadManager.shared.pauseDownloadItem(id: itemId)
        }
    }

    @objc fileprivate func updateState(notification: Notification? = nil) {
        if let data = notification?.userInfo, let updatedState = data[DownloadedItemKeys.state] as? DownloadItemState {
            self.downloadedItem.downloadState = updatedState
        }
        
        switch downloadedItem.downloadState {
        case .inProgress:
            self.statusImageView.removeFromSuperview()
            self.addCircularBar(imageKey: "downloading")
            self.addToggleButton()
          
        case .paused:
            self.statusImageView.removeFromSuperview()
            self.addCircularBar(imageKey: "paused_download")
            self.addToggleButton()

        case .completed:
            self.toggleImageView.removeFromSuperview()
            self.toggleButton.removeFromSuperview()
            self.circularRing.removeFromSuperview()
            self.addStatusImageView(imageKey: "complete_download")
            
        case .failed, .interrupted, .dbFailure, .expired:
            self.toggleImageView.removeFromSuperview()
            self.circularRing.removeFromSuperview()
            self.addStatusImageView(imageKey: "error_download")
            self.addToggleButton()
            
        default:
            break
        }
    }
    
    @objc fileprivate func updateCircularValue(notification: Notification? = nil) {
        if let data = notification?.userInfo {
            self.downloadedItem.downloadedBytes = data[DownloadedItemKeys.downloadedBytes] as? Int64
            self.downloadedItem.estimatedBytes = data[DownloadedItemKeys.estimatedBytes] as? Int64
        }
        
        guard
            let downloadedBytes = self.downloadedItem.downloadedBytes,
            let estimatedBytes = self.downloadedItem.estimatedBytes, estimatedBytes > 0 else {
                return
        }
                
        let percentage = CGFloat(downloadedBytes) / CGFloat(estimatedBytes)

        if self.downloadedItem.downloadState == .completed {
            self.circularRing.value = 100
             AnalyticEngine.shared.downloadCompleteOrFail(with: downloadedItem)
        }
        else if estimatedBytes == 0 {
            self.circularRing.value = 0
        }
        else {
            self.circularRing.value = percentage
        }
    }
    
    fileprivate func updateProgress() {
        self.updateState()
        self.updateCircularValue()
    }
}

extension DownloadProgressView {
    func retryDownloadItem(video: DownloadItem) {
        if let contentId = video.contentId {
            do {
                try Zee5DownloadManager.shared.resumeDownloadItem(id: contentId)
                video.downloadState = .inProgress
                //self.tableView.reloadData()
            }
            catch {
                ZeeUtility.utility.console("Retry download Error: \(error.localizedDescription)")

            }
        }
    }

    func resumeDownloadItem(video: DownloadItem) {
        if let contentId = video.contentId {
            if video.downloadState == .paused {
                do {
                    try Zee5DownloadManager.shared.resumeDownloadItem(id: contentId)
                    video.downloadState = .inProgress
                    //self.tableView.reloadData()
                }
                catch {
                    ZeeUtility.utility.console("Resume download Error: \(error.localizedDescription)")
                }
            }
        }
    }

    func restoreDownloadItem(video: DownloadItem) {
        if let contentId = video.contentId {
            DownloadHelper.shared.restoreExpiredContent(id: contentId) { (isExpired, error) in
                if error == nil {
                    video.downloadState = .completed
                    //self.tableView.reloadData()
                }
                else {
                    ZeeUtility.utility.console("Restore download Error: \(String(describing: error))")
                }
            }
        }
    }
}
