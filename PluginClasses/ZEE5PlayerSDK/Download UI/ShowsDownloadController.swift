//
//  ShowDownloadController.swift
//  DemoProject
//
//  Created by Abbas's Mac Mini on 13/09/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit

protocol ChangeDownloadTabDelegate: class {
    func changeCurrentTab()
}

class ShowsDownloadController: UIViewController {
    
    static let identifier = "ShowsDownloadController"
    
    public weak var delegate: ChangeDownloadTabDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    private let bundle = Bundle(identifier: "org.cocoapods.Zee5PlayerPlugin")
    private var showArr = [DownloadItem]() {
        didSet {
            if self.showArr.isEmpty {
                self.delegate?.changeCurrentTab()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getDownloadedItems()
        //
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshDownloadData), name: AppNotification.editDownload, object: nil)
    }
    
    @objc func refreshDownloadData() {
        self.getDownloadedItems()
    }
    
    func isAddNewEpisodeView(_ isShow: Bool) {
        if isShow == true {
            guard let headerView = self.tableView.dequeueReusableCell(withIdentifier: NewEpisodeCell.identifier) as? NewEpisodeCell else { return }
            self.tableView.tableHeaderView = headerView
        }
        else {
            self.tableView.tableHeaderView = nil
        }
    }
    
    func getDownloadedItems() {
        do {
            guard let downloads = try Zee5DownloadManager.shared.getAllShows() else { return }
            var items = [DownloadItem]()
            for item in downloads {
                let tmp = DownloadItem()
                tmp.contentId = item.contentId
                tmp.title = item.title
                tmp.downloadedBytes = Int64(item.downloadedSize)
                tmp.estimatedBytes = Int64(item.estimatedSize)
                tmp.downloadState = item.state
                tmp.imgUrl = item.imageURL
                tmp.assetType = item.assetType
                tmp.originalTitle = item.showOriginalTitle
                tmp.noOfEpisodes = item.episode
                tmp.noOfBytes = String(item.downloadedSize)
                items.append(tmp)
            }
            self.showArr = items
            self.tableView.reloadData()
            if self.showArr.isEmpty == false {
                self.getDownloadedShowCount()
            }
        }
        catch {
            ZeeUtility.utility.console("error: getDownloadedItems: \(error.localizedDescription)")
        }
    }
    
    func getDownloadedShowCount() {
        do {
            if let dict = try Zee5DownloadManager.shared.getDownloadsCount() {
                for item in self.showArr {
                    if let titleKey = item.originalTitle {
                        item.pendingDownloads = dict[titleKey]
                    }
                }
                self.tableView.reloadData()
            }
        }
        catch {
            ZeeUtility.utility.console("error: unable to fetch the download count: \(error.localizedDescription)")
        }
    }
}

extension ShowsDownloadController: UITableViewDataSource, UITableViewDelegate, ShowControllerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showArr.isEmpty {
            tableView.setEmptyStateView(over: self)
        }
        else {
            tableView.restore()
        }
        return self.showArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DownloadTableCell.identifier, for: indexPath) as? DownloadTableCell else { return UITableViewCell() }
        cell.currentShow = self.showArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Download", bundle: bundle)
        guard let showDetail = storyboard.instantiateViewController(withIdentifier: ShowDetailController.identifer) as? ShowDetailController else { return }
        showDetail.delegate = self
        showDetail.selectedShow = self.showArr[indexPath.row]
        self.navigationController?.pushViewController(showDetail, animated: true)
    }
    
    func refreshShowsData() {
        self.getDownloadedItems()
    }
}
