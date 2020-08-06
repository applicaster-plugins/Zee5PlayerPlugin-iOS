//
//  MovieDownloadController.swift
//  DemoProject
//
//  Created by Abbas's Mac Mini on 13/09/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit

import PlayKit

class MovieDownloadController: UIViewController {
    
    public weak var delegate: ChangeDownloadTabDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    static let identifier = "MovieDownloadController"
    
    private let bundle = Bundle(for: DownloadRootController.self)
    private var movieArr = [DownloadItem]() {
        didSet {
            if self.movieArr.isEmpty {
                self.delegate?.changeCurrentTab()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshDownloadData), name: AppNotification.editDownload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateDownloadState(_:)), name: AppNotification.stateUpdate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getDownloadedItems()
    }
    @objc func updateDownloadState(_ notification: Notification) {
        if let data = notification.object as? [String: Any] {
            if let contentId = data["contentId"] as? String,
                let state = data["state"] as? DownloadItemState {
                
                let idx = self.movieArr.firstIndex { (data) -> Bool in
                    return data.contentId == contentId ? true : false
                }
                if let index = idx {
                    let item = self.movieArr[index]
                    item.downloadState = state
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func refreshDownloadData() {
        self.getDownloadedItems()
    }
    
    func isAddSubcriptionView(_ isShow: Bool) {
        if isShow == true {
            guard let headerView = self.tableView.dequeueReusableCell(withIdentifier: SubscriptionRenewCell.identifier) as? SubscriptionRenewCell else { return }
            self.tableView.tableHeaderView = headerView
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.selectRemindLater), name: AppNotification.remindLater, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.selectRenewNow), name: AppNotification.renewNow, object: nil)
        }
        else {
            self.tableView.tableHeaderView = nil
        }
    }
    
    @objc func selectRemindLater() {
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
            self.isAddSubcriptionView(false)
        }, completion: nil)
    }
    
    @objc func selectRenewNow() {
        ZeeUtility.utility.console("Good to Go: Renew")
    }
    
    func getDownloadedItems() {
        do {
            guard let movies = try Zee5DownloadManager.shared.getAllMovies() as? [ZeeDownloadItem] else { return }
            let downloads = self.removeUnwantedItemFromDB(with: movies)
            
            var items = [DownloadItem]()
            for item in downloads {
                let tmp = DownloadItem()
                tmp.contentId = item.contentId
                tmp.title = item.title
                tmp.showTitle = item.showOriginalTitle
                tmp.estimatedBytes = Int64(item.estimatedSize)
                tmp.downloadedBytes = Int64(item.downloadedSize)
                tmp.status = item.state.asString()
                tmp.downloadState = item.state
                tmp.imgUrl = item.imageURL
                tmp.duration = item.duration
                tmp.videoPlayedDuration = item.offlinePlayingDuration
                tmp.Agerating = item.Agerating
                items.append(tmp)
            }
            self.movieArr = items
            self.checkVideoExpirationStatus(with: self.movieArr)
            self.tableView.reloadData()
        }
        catch {
            ZeeUtility.utility.console("error: getDownloadedItems: \(error.localizedDescription)")
        }
    }
    
    func removeUnwantedItemFromDB(with items: [ZeeDownloadItem]) -> [ZeeDownloadItem] {
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
                        tmp.downloadState = .expired
                        ZeeUtility.utility.console("Error Video expiration: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

extension MovieDownloadController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.movieArr.isEmpty {
            tableView.setEmptyStateView(over: self)
        }
        else {
            tableView.restore()
        }
        return self.movieArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DownloadOptionCell.identifier, for: indexPath) as? DownloadOptionCell else { return UITableViewCell() }
        let movie = self.movieArr[indexPath.row]
        cell.delegate = self
        cell.loadCellData(with: movie, at: indexPath.row)
        return cell
    }
}

extension MovieDownloadController: DownloadOptionDelegate, OfflineVideoDurationDelegate {
    
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
        let video = self.movieArr[index]
        if let contentId = video.contentId {
            do {
                let url = try Zee5DownloadManager.shared.playbackUrl(id: contentId)
                self.gotoVideoPlayer(with: url, video: video)
                AnalyticEngine.shared.downloadPlayClick(with: video)
            }
            catch {
                ZeeUtility.utility.console("Play video Error: \(error.localizedDescription)")
            
            }
        }
    }
    
    func retryDownloadItem(at index: Int) {
        let movie = self.movieArr[index]
        if let contentId = movie.contentId {
            do {
                try Zee5DownloadManager.shared.resumeDownloadItem(id: contentId)
                movie.downloadState = .inProgress
                self.tableView.reloadData()
            }
            catch {
                ZeeUtility.utility.console("Retry download Error: \(error.localizedDescription)")
               
            }
        }
    }
    
    func pauseDownloadItem(at index: Int) {
        let video = self.movieArr[index]
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
        let video = self.movieArr[index]
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
        if let contentId = self.movieArr[index].contentId {
            do {
                try Zee5DownloadManager.shared.removeDownloadItem(id: contentId)
                AnalyticEngine.shared.downloadDelete(with: self.movieArr[index])
                self.movieArr.remove(at: index)
                self.tableView.reloadData()
            }
            catch {
                ZeeUtility.utility.console("Delete download Error: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelDownloadItem(at index: Int) {
        if let contentId = self.movieArr[index].contentId {
            do {
                try Zee5DownloadManager.shared.removeDownloadItem(id: contentId)
                self.movieArr.remove(at: index)
                self.tableView.reloadData()
            }
            catch {
                ZeeUtility.utility.console("Cancel download Error: \(error.localizedDescription)")
               
            }
        }
    }
    
    func restoreDownloadItem(at index: Int) {
        let movie = self.movieArr[index]
        if let contentId = movie.contentId {
            DownloadHelper.shared.restoreExpiredContent(id: contentId) { (isExpired, error) in
                if error == nil {
                    movie.downloadState = .completed
                    self.tableView.reloadData()
                }
                else {
                    ZeeUtility.utility.console("Restore download Error: \(String(describing: error))")
                }
            }
        }
    }
    
    private func gotoVideoPlayer(with url: URL?, video: DownloadItem?) {
        let offlineVC = OfflinePlayerController(nibName: OfflinePlayerController.identifier, bundle: bundle)
        offlineVC.delegate = self
        offlineVC.selectedUrl = url
        offlineVC.selectedVideo = video
        offlineVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(offlineVC, animated: true, completion: {
            })
    }
    
    // MARK:- OfflineVideoDurationDelegate Method
    func updateVideoDuration(item: DownloadItem?, duration: Int) {
        guard let id = item?.contentId else { return }
        
        let idx = self.movieArr.firstIndex { (data) -> Bool in
            return data.contentId == id ? true : false
        }
        
        if let index = idx {
            if let ab = item {
                ab.videoPlayedDuration = duration
                self.movieArr[index] = ab
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
}

extension Double {
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = style
        guard let formattedString = formatter.string(from: self) else { return "" }
        return formattedString
    }
}
