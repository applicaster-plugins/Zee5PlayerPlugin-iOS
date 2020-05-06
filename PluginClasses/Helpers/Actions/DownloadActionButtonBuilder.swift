//
//  DownloadActionButtonBuilder.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 03.05.20.
//

import Foundation

class DownloadActionButtonBuilder: BaseActionButtonBuilder, ActionButtonBuilder {
    private var circularRing = UICircularProgressRing()
    @IBOutlet weak var viewProgress: UIView!
    @IBOutlet weak var viewPause: UIView!

    func build() -> ActionBarView.Button? {
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
                
        return ActionBarView.Button(
            image: image,
            selectedImage: nil,
            title: title,
            font: style.font,
            textColor: style.color,
            custom: nil,
            action: download
        )
    }
    
    func fetchInitialState() {
        //        let item = try? getDownloadedItem(id: self.currentPlayableItem?.identifier as! String)
        //        if item != nil {
        //            print("item check aaa ")
        //            self.viewPause.superview?.isHidden = false
        //            self.currentItem = item
        //            self.setupDownloadCircularBar(for: ZEE5PlayerManager.sharedInstance().currentItem.content_id)
        //        }
        //        else
        //        {
        //            self.viewProgress.isHidden = true
        //        }
    }
    
    fileprivate func download() {
        ZEE5PlayerManager.sharedInstance().startDownload()
    }
    
//    @objc func consumptionDownloadButtonAction(_ sender: CAButton) {
//        if self.currentItem != nil {
//            if self.currentItem?.downloadState != .completed {
//                startdownload()
//            }
//        } else {
//            startdownload()
//        }
//    }
    
    
//    func startdownload() {
//        ZEE5PlayerManager.sharedInstance().startDownload()
//        guard
//            let item = try? getDownloadedItem(id: ZEE5PlayerManager.sharedInstance().currentItem.content_id) else {
//                return
//
//        }
//        self.currentItem = item
//        self.setupDownloadCircularBar(for: item.contentId!)
//        self.currentItem?.downloadState = .inProgress
//    }
//
//    public func setupDownloadCircularBar(for contentId: String) {
//        self.circularRing.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
//        self.circularRing.center = CGPoint(x: self.viewProgress.frame.width / 2 - 3, y: self.viewProgress.frame.height / 2)
//        self.circularRing.accessibilityIdentifier = contentId
//
//        self.circularRing.startAngle = -90
//        self.circularRing.style = .bordered(width: 0, color: AppColor.progressGray)
//        self.circularRing.outerCapStyle = .round
//        self.circularRing.outerRingColor = AppColor.progressGray
//        self.circularRing.outerRingWidth = 2.5
//
//        self.circularRing.innerCapStyle = .round
//        self.circularRing.innerRingColor = AppColor.aquaGreen
//        self.circularRing.innerRingWidth = 2.5
//        self.circularRing.innerRingSpacing = 0
//
//        self.circularRing.shouldShowValueText = false
//        self.viewProgress.addSubview(self.circularRing)
//
//
//        // Progress button for events
//        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: self.viewProgress.frame.size.width, height: self.viewProgress.frame.size.height))
//        btn.addTarget(self, action: #selector(self.actionDownload(_:)), for: .touchUpInside)
//        self.viewProgress.addSubview(btn)
//
//        //
//        self.updateProgressView()
//    }
//    func updateProgressView() {
//
//        if let id = self.currentItem?.contentId, let downloadedByte = self.currentItem?.downloadedBytes, let estimatedByte = self.currentItem?.estimatedBytes {
//
//            let btnDownload = self.buttonsViewCollection?.first(where: { $0.tag ==  ItemTag.Button.downloadButton})
//            updateProgressMenu(contentId: id, progress: self.circularRing, buttonState: btnDownload!, viewPause: self.viewPause, downloadedByte: downloadedByte, estimatedByte: estimatedByte)
//        }
//    }
//    @objc private func actionDownload(_ btn: UIButton) {
//        if self.currentItem?.downloadState == .paused {
//            resumeDownloadItem(video: self.currentItem!)
//            //self.menuDownload.dataSource = arr
//        }else{
//            pauseDownloadItem(video: self.currentItem!)
//        }
//        //self.menuDownload.show()
//    }
    
//    var currentItem: DownloadItem? {
//        didSet {
//
//            // For show/episodes
//
//
//            let firstNegative = buttonsViewCollection?.first(where: { $0.tag ==  ItemTag.Button.downloadButton})
//            //
//            //            if self.currentItem?.downloadState == .inProgress {
//            ////                self.lblDownloading.text = "Downloading..."
//            //            }
//            //            else if self.currentItem?.downloadState == .paused {
//            //                self.lblDownloading.text = "Paused"
//            //            }
//            //            else if self.currentItem?.downloadState == .expired {
//            //                self.lblDownloading.text = "Download Expired"
//            //            }
//
//            // Checking download state image and progress bar
//            if self.currentItem?.downloadState == .inProgress {
//                self.viewProgress.isHidden = false
//                if let firstNegative = buttonsViewCollection?.first(where: { $0.tag ==  ItemTag.Button.downloadButton}){
//                    firstNegative.isHidden = false}
//
//                self.viewPause.isHidden = true
//            }
//            else {
//                if let firstNegative = buttonsViewCollection?.first(where: { $0.tag ==  ItemTag.Button.downloadButton}){
//                    firstNegative.isHidden = false}
//                self.viewProgress.isHidden = true
//                self.viewPause.isHidden = true
//
//                if self.currentItem?.downloadState == .completed {
//                    if #available(iOS 13.0, *) {
//                        let img = UIImage(named: "complete_download", in: bundle, with: nil)
//                        firstNegative!.setImage(img, for: .normal)
//                    } else {
//                        // Fallback on earlier versions
//                        let ab = UIImage(named: "complete_download", in: bundle, compatibleWith: nil)
//                        firstNegative!.setImage(ab, for: .normal)
//                    }
//                }
//                else if self.currentItem?.downloadState == .failed || self.currentItem?.downloadState == .interrupted || self.currentItem?.downloadState == .dbFailure || self.currentItem?.downloadState == .expired {
//                    if #available(iOS 13.0, *) {
//                        let img = UIImage(named: "error_download", in: bundle, with: nil)
//                        firstNegative!.setImage(img, for: .normal)
//                    } else {
//                        // Fallback on earlier versions
//                        let ab = UIImage(named: "error_download", in: bundle, compatibleWith: nil)
//                        firstNegative!.setImage(ab, for: .normal)
//                    }
//                }
//                else
//                    if self.currentItem?.downloadState == .paused {
//                        if let firstNegative = buttonsViewCollection?.first(where: { $0.tag ==  ItemTag.Button.downloadButton}){
//                            firstNegative.isHidden = false}
//                        self.viewProgress.isHidden = false
//                        self.viewPause.superview?.isHidden = false
//                        self.viewPause.isHidden = false
//                }
//            }
//
//            // Upadating progress bar
//            if let downloadedBytes = self.currentItem?.downloadedBytes, let estimatedBytes = self.currentItem?.estimatedBytes, estimatedBytes > 0 {
//                let percentage = CGFloat(downloadedBytes) / CGFloat(estimatedBytes) * CGFloat(100)
//
//                if self.currentItem?.downloadState == .completed {
//                    self.circularRing.value = 100
//                }
//                else if let size = self.currentItem?.estimatedBytes, size > 0 {
//                    self.circularRing.value = percentage
//                }
//                else {
//                    self.circularRing.value = 0
//                }
//            }
//        }
//    }
//

}

//extension DownloadActionButtonBuilder: DownloadOptionDelegate, OfflineVideoDurationDelegate {
//
//    // MARK:- DownloadOption Delegate Method
//
//    func updateProgressMenu(contentId: String, progress: UICircularProgressRing, buttonState: UIButton, viewPause: UIView, downloadedByte: Int64, estimatedByte: Int64) {
//
//        Zee5DownloadManager.shared.setupDownloadProgressBar(contentId: contentId, progressRing: progress, imageDownloadState: buttonState, viewPuaseProgress: viewPause, downloadedBytes: downloadedByte, estimatedBytes: estimatedByte)
//    }
//
//    func getDownloadedItem(id: String) throws -> DownloadItem{
//        do {
//            guard let movie = try Zee5DownloadManager.shared.getItemById(id: id) else {
//                let msg = "Items not found \(id)"
//                ZeeUtility.utility.console(msg)
//                throw ZeeError.withError(message: msg)
//
//            }
//            let item = DownloadItem()
//
//            item.contentId = movie.contentId
//            item.title = movie.title
//            item.showTitle = movie.showOriginalTitle
//            item.estimatedBytes = Int64(movie.estimatedSize)
//            item.downloadedBytes = Int64(movie.downloadedSize)
//            item.status = movie.state.asString()
//            item.downloadState = movie.state
//            item.imgUrl = movie.imageURL
//            item.duration = movie.duration
//            item.videoPlayedDuration = movie.offlinePlayingDuration
//            return item
//
//
//        }
//        catch {
//            ZeeUtility.utility.console("error: getDownloadedItems: \(error.localizedDescription)")
//
//            let msg = "Items not found"
//            ZeeUtility.utility.console(msg)
//            throw ZeeError.withError(message: msg)
//        }
//    }
//
//    func didSelectMenuOption(dataIndex: Int, downloadMenuOption: String) {
//        //
//        //            if downloadMenuOption.contains(DownloadStateMenu.play.description) {
//        //                self.playDownloadItem(at: dataIndex)
//        //            }
//        //            else if downloadMenuOption.contains(DownloadStateMenu.retry.description) {
//        //                self.retryDownloadItem(at: dataIndex)
//        //            }
//        //            else if downloadMenuOption.contains(DownloadStateMenu.pause.description) {
//        //                self.pauseDownloadItem(at: dataIndex)
//        //            }
//        //            else if downloadMenuOption.contains(DownloadStateMenu.resume.description) {
//        //                self.resumeDownloadItem(at: dataIndex)
//        //            }
//        //            else if downloadMenuOption.contains(DownloadStateMenu.deleteDownload.description) {
//        //                self.deleteDownloadItem(at: dataIndex)
//        //            }
//        //            else if downloadMenuOption.contains(DownloadStateMenu.cancelDownload.description) {
//        //                self.cancelDownloadItem(at: dataIndex)
//        //            }
//        //            else if downloadMenuOption.contains(DownloadStateMenu.restoreDownload.description) {
//        //                self.restoreDownloadItem(at: dataIndex)
//        //            }
//    }
//
//    //
//    //            func playDownloadItem(contentId: String) {
//    //           // let video = self.videoArr[index]
//    //            //if let contentId = video.contentId {
//    //                do {
//    //                    let url = try Zee5DownloadManager.shared.playbackUrl(id: contentId)
//    //                    //self.gotoVideoPlayer(with: url, video: video)
//    //                    //AnalyticEngine.shared.downloadClick(with: video)
//    //                }
//    //                catch {
//    //                    ZeeUtility.utility.console("Play video Error: \(error.localizedDescription)")
//    //
//    //                }
//    //            //}
//    //        }
//
//    func retryDownloadItem(video: DownloadItem) {
//        if let contentId = video.contentId {
//            do {
//                try Zee5DownloadManager.shared.resumeDownloadItem(id: contentId)
//                video.downloadState = .inProgress
//                //self.tableView.reloadData()
//            }
//            catch {
//                ZeeUtility.utility.console("Retry download Error: \(error.localizedDescription)")
//
//            }
//        }
//    }
//
//    func pauseDownloadItem(video: DownloadItem) {
//
//        if let contentId = video.contentId {
//            if video.downloadState == .inProgress {
//                do {
//                    try Zee5DownloadManager.shared.pauseDownloadItem(id: contentId)
//                    video.downloadState = .paused
//                    //self.tableView.reloadData()
//                }
//                catch {
//                    ZeeUtility.utility.console("Pause download Error: \(error.localizedDescription)")
//
//                }
//            }
//        }
//    }
//
//    func resumeDownloadItem(video: DownloadItem) {
//        if let contentId = video.contentId {
//            if video.downloadState == .paused {
//                do {
//                    try Zee5DownloadManager.shared.resumeDownloadItem(id: contentId)
//                    video.downloadState = .inProgress
//                    //self.tableView.reloadData()
//                }
//                catch {
//                    ZeeUtility.utility.console("Resume download Error: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//
//    //        func deleteDownloadItem(at index: Int) {
//    //            if let contentId = self.videoArr[index].contentId {
//    //                do {
//    //                    try Zee5DownloadManager.shared.removeDownloadItem(id: contentId)
//    //                    AnalyticEngine.shared.downloadDelete(with: self.videoArr[index])
//    //                    self.videoArr.remove(at: index)
//    //                    self.tableView.reloadData()
//    //                }
//    //                catch {
//    //                    ZeeUtility.utility.console("Delete download Error: \(error.localizedDescription)")
//    //
//    //                }
//    //            }
//    //        }
//
//    //        func cancelDownloadItem(video: DownloadItem) {
//    //            if let contentId = self.videoArr[index].contentId {
//    //                do {
//    //                    try Zee5DownloadManager.shared.removeDownloadItem(id: contentId)
//    //                    self.videoArr.remove(at: index)
//    //                    self.tableView.reloadData()
//    //                }
//    //                catch {
//    //                    ZeeUtility.utility.console("Cancel download Error: \(error.localizedDescription)")
//    //                }
//    //            }
//    //        }
//
//    func restoreDownloadItem(video: DownloadItem) {
//        if let contentId = video.contentId {
//            DownloadHelper.shared.restoreExpiredContent(id: contentId) { (isExpired, error) in
//                if error == nil {
//                    video.downloadState = .completed
//                    //self.tableView.reloadData()
//                }
//                else {
//                    ZeeUtility.utility.console("Restore download Error: \(String(describing: error))")
//                }
//            }
//        }
//    }
//
//    // MARK:- OfflineVideoDurationDelegate Method
//    func updateVideoDuration(item: DownloadItem?, duration: Int) {
//        //            guard let id = item?.contentId else { return }
//        //
//        //            let idx = self.videoArr.firstIndex { (data) -> Bool in
//        //                return data.contentId == id ? true : false
//        //            }
//        //
//        //            if let index = idx {
//        //                if let ab = item {
//        //                    ab.videoPlayedDuration = duration
//        //                    self.videoArr[index] = ab
//        //                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//        //                }
//    }
//
//
//
//
//}
