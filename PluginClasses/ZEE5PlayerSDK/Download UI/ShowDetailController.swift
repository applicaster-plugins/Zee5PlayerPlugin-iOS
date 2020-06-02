//
//  ShowDetailController.swift
//  DemoProject
//
//  Created by Abbas's Mac Mini on 16/09/19.
//  Copyright © 2019 Logituit. All rights reserved.  97552 54213
//

import UIKit

protocol ShowControllerDelegate: class {
    func refreshShowsData()
}

class ShowDetailController: UIViewController {
    
    static let identifer = "ShowDetailController"
    
    public weak var delegate: ShowControllerDelegate?
    public var selectedShow: DownloadItem?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnEdit: UIButton!
    
    private var episodeArr = [DownloadItem]()

    private let bundle = Bundle(for: DownloadRootController.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.selectedShow?.originalTitle
        
        var img = UIImage()
        if #available(iOS 13.0, *) {
            img = UIImage(named: "Back", in: bundle, with: nil) ?? UIImage()
        } else {
            // Fallback on earlier versions
            img = UIImage(named: "Back", in: bundle, compatibleWith: nil) ?? UIImage()
        }
        let backBtn = UIBarButtonItem(image: img.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.actionBack))
        self.navigationItem.leftBarButtonItem = backBtn
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.btnEdit)
        
        //
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshDownloadData), name: AppNotification.editDownload, object: nil)
        
        //
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateDownloadState(_:)), name: AppNotification.stateUpdate, object: nil)
        
        //
        self.isAddNewEpisodeView(false)
        
        self.getAllEpisodes(for: self.selectedShow)
    }
    
    @objc func updateDownloadState(_ notification: Notification) {
        if let data = notification.object as? [String: Any] {
            if let contentId = data["contentId"] as? String,
                let state = data["state"] as? DownloadItemState {
                
                let idx = self.episodeArr.firstIndex { (data) -> Bool in
                    return data.contentId == contentId ? true : false
                }
                if let index = idx {
                    let item = self.episodeArr[index]
                    item.downloadState = state
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func refreshDownloadData() {
        self.getAllEpisodes(for: self.selectedShow)
        self.delegate?.refreshShowsData()
    }
    
    func getAllEpisodes(for show: DownloadItem?) {
        do {
            if let title = show?.originalTitle {
                guard let shows = try Zee5DownloadManager.shared.getEpisodesByShow(showTitle: title) else { return }
                let downloads = self.removeUnwantedItemFromDB(with: shows)
                
                var items = [DownloadItem]()
                for item in downloads {
                    let tmp = DownloadItem()
                    tmp.contentId = item.contentId
                    tmp.title = item.title
                    tmp.downloadedBytes = Int64(item.downloadedSize)
                    tmp.estimatedBytes = Int64(item.estimatedSize)
                    tmp.downloadState = item.state
                    tmp.imgUrl = item.imageURL
                    tmp.duration = item.duration
                    tmp.assetType = item.assetType
                    tmp.episodeNumber = item.episodeNumber
                    tmp.videoPlayedDuration = item.offlinePlayingDuration
                    tmp.Agerating = item.Agerating
                    items.append(tmp)
                }
                self.episodeArr = items
                self.checkVideoExpirationStatus(with: self.episodeArr)
                self.tableView.reloadData()
            }
        }
        catch {
            ZeeUtility.utility.console("Error: getAllEpisodes: \(error.localizedDescription)")
        }
    }
    
    func removeUnwantedItemFromDB(with items: [DownloadDataItem]) -> [DownloadDataItem] {
        var downloadItems = items
        for idx in 0..<downloadItems.count {
            let item = downloadItems[idx]
            if item.state == .new {
                do {
                    try Zee5DownloadManager.shared.removeDownloadItem(id: item.contentId)
                    downloadItems.remove(at: idx)
                }
                catch {
                    ZeeUtility.utility.console("Delete download Error: \(error.localizedDescription)")
                }
            }
        }
        return downloadItems
    }
    
    func checkVideoExpirationStatus(with items: [DownloadItem]) {
        for tmp in items {
            if tmp.downloadState == .completed {
                if let contentId = tmp.contentId {
                    do {
                        let isExpired = try Zee5DownloadManager.shared.isVideoExpired(id: contentId)
                        if isExpired == true {
                            tmp.downloadState = .expired
                        }
                    }
                    catch {
                        ZeeUtility.utility.console("Error Video expiration: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    @objc func actionBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionEdit(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Download", bundle: bundle)
        guard let editVC = storyboard.instantiateViewController(withIdentifier: EditDownloadController.identifier) as? EditDownloadController else { return }
        editVC.selectedIndex = 101
        editVC.selectedShow = self.selectedShow?.originalTitle
        self.navigationController?.pushViewController(editVC, animated: false)
    }
    
    func isAddNewEpisodeView(_ isShow: Bool) {
        if isShow == true {
            guard let headerView = self.tableView.dequeueReusableCell(withIdentifier: NewEpisodeDownloadCell.identifier) as? NewEpisodeDownloadCell else { return }
            self.tableView.tableHeaderView = headerView
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.selectCancelEpisode), name: AppNotification.cancelNewEpisode, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.selectDownloadEpisode), name: AppNotification.downloadNewEpisode, object: nil)
        }
        else {
            self.tableView.tableHeaderView = nil
        }
    }
    
    @objc func selectCancelEpisode() {
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
            self.isAddNewEpisodeView(false)
        }, completion: nil)
    }
    
    @objc func selectDownloadEpisode() {
        ZeeUtility.utility.console("Good to Go:: Download")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func gotoVideoPlayer(with url: URL?, video: DownloadItem?) {
        let offlineVC = OfflinePlayerController(nibName: OfflinePlayerController.identifier, bundle: bundle)
        offlineVC.delegate = self
        offlineVC.selectedUrl = url
        offlineVC.selectedVideo = video
        offlineVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(offlineVC, animated: true, completion: {
//            print("Present Video view");
       })
    }
}

extension ShowDetailController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.episodeArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DownloadOptionCell.identifier, for: indexPath) as? DownloadOptionCell else { return UITableViewCell() }
        let show = self.episodeArr[indexPath.row]
        cell.delegate = self
        cell.loadCellData(with: show, at: indexPath.row)
        return cell
    }
}

extension ShowDetailController: DownloadOptionDelegate, OfflineVideoDurationDelegate {
    
    // MARK:- DownloadOption Delegate Method
    
    func updateProgressMenu(contentId: String, progress: UICircularProgressRing, buttonState: UIButton, viewPause: UIView, downloadedByte: Int64, estimatedByte: Int64) {
        
        Zee5DownloadManager.shared.setupDownloadProgressBar(contentId: contentId, progressRing: progress, imageDownloadState: buttonState, viewPuaseProgress: viewPause, downloadedBytes: downloadedByte, estimatedBytes: estimatedByte)
    }
    
    func didSelectMenuOption(dataIndex: Int, downloadMenuOption: String) {
        
        if downloadMenuOption.contains(DownloadStateMenu.play.description) {
            self.playDownloadItem(at: dataIndex)
        }
        else if downloadMenuOption.contains(DownloadStateMenu.retry.description) {
            self.retryDownloadItem(at: dataIndex)
        }
        else if downloadMenuOption.contains(DownloadStateMenu.pause.description) {
            self.pauseDownloadItem(at: dataIndex)
        }
        else if downloadMenuOption.contains(DownloadStateMenu.resume.description) {
            self.resumeDownloadItem(at: dataIndex)
        }
        else if downloadMenuOption.contains(DownloadStateMenu.deleteDownload.description) {
            self.deleteDownloadItem(at: dataIndex)
        }
        else if downloadMenuOption.contains(DownloadStateMenu.cancelDownload.description) {
            self.cancelDownloadItem(at: dataIndex)
        }
        else if downloadMenuOption.contains(DownloadStateMenu.restoreDownload.description) {
            self.restoreDownloadItem(at: dataIndex)
        }
    }
    
    //
    func playDownloadItem(at index: Int) {
        let video = self.episodeArr[index]
        if let contentId = video.contentId {
            do {
                let url = try Zee5DownloadManager.shared.playbackUrl(id: contentId)
                self.gotoVideoPlayer(with: url, video: video)
                AnalyticEngine.shared.downloadClick(with: video)
            }
            catch {
                ZeeUtility.utility.console("Play video Error: \(error.localizedDescription)")
               
            }
        }
    }
    
    func retryDownloadItem(at index: Int) {
        let episode = self.episodeArr[index]
        if let contentId = episode.contentId {
            do {
                try Zee5DownloadManager.shared.resumeDownloadItem(id: contentId)
                episode.downloadState = .inProgress
                self.tableView.reloadData()
            }
            catch {
                ZeeUtility.utility.console("Retry download Error: \(error.localizedDescription)")
                
            }
        }
    }
    
    func pauseDownloadItem(at index: Int) {
        let video = self.episodeArr[index]
        if let contentId = video.contentId {
            if video.downloadState == .inProgress {
                do {
                    try Zee5DownloadManager.shared.pauseDownloadItem(id: contentId)
                    video.downloadState = .paused
                    self.tableView.reloadData()
                }
                catch {
                    ZeeUtility.utility.console("Pause download Error: \(error.localizedDescription)")
               
                }
            }
        }
    }
    
    func resumeDownloadItem(at index: Int) {
        let video = self.episodeArr[index]
        if let contentId = video.contentId {
            if video.downloadState == .paused {
                do {
                    try Zee5DownloadManager.shared.resumeDownloadItem(id: contentId)
                    video.downloadState = .inProgress
                    self.tableView.reloadData()
                }
                catch {
                    ZeeUtility.utility.console("Resume download Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteDownloadItem(at index: Int) {
        if let contentId = self.episodeArr[index].contentId {
            do {
                try Zee5DownloadManager.shared.removeDownloadItem(id: contentId)
                AnalyticEngine.shared.downloadDelete(with: self.episodeArr[index])
                self.episodeArr.remove(at: index)
                self.tableView.reloadData()
                
                if self.episodeArr.isEmpty {
                    self.delegate?.refreshShowsData()
                    self.navigationController?.popViewController(animated: true)
                }
            }
            catch {
                ZeeUtility.utility.console("Delete download Error: \(error.localizedDescription)")
               
            }
        }
    }
    
    func cancelDownloadItem(at index: Int) {
        if let contentId = self.episodeArr[index].contentId {
            do {
                try Zee5DownloadManager.shared.removeDownloadItem(id: contentId)
                self.episodeArr.remove(at: index)
                self.tableView.reloadData()
                
                if self.episodeArr.isEmpty {
                    self.delegate?.refreshShowsData()
                    self.navigationController?.popViewController(animated: true)
                }
            }
            catch {
                ZeeUtility.utility.console("Cancel download Error: \(error.localizedDescription)")
            }
        }
    }
    
    func restoreDownloadItem(at index: Int) {
        let episode = self.episodeArr[index]
        if let contentId = episode.contentId {
            DownloadHelper.shared.restoreExpiredContent(id: contentId) { (isExpired, error) in
                if error == nil {
                    episode.downloadState = .completed
                    self.tableView.reloadData()
                }
                else {
                    ZeeUtility.utility.console("Restore download Error: \(String(describing: error))")
                }
            }
        }
    }
    
    // MARK:- OfflineVideoDurationDelegate Method
    func updateVideoDuration(item: DownloadItem?, duration: Int) {
        guard let id = item?.contentId else { return }
        
        let idx = self.episodeArr.firstIndex { (data) -> Bool in
            return data.contentId == id ? true : false
        }
        
        if let index = idx {
            if let ab = item {
                ab.videoPlayedDuration = duration
                self.episodeArr[index] = ab
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
}

