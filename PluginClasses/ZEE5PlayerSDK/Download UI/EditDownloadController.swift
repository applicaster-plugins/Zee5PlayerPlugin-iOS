//
//  EditDownloadController.swift
//  Zee5DownloadSDK
//
//  Created by cepl on 25/09/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit


class EditDownloadController: UIViewController {
    
    static let identifier = "EditDownloadController"
    
    public var selectedIndex = 0
    public var selectedShow: String?  // Only for episode/show
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewEditMenu: UIView!
    @IBOutlet weak var btnSelectAll: UIButton!
    
    private var editItems = [DownloadItem]() {
        didSet {
            self.btnSelectAll.isEnabled = self.editItems.isEmpty ? false : true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.selectedIndex == 101 ? self.selectedShow : "Downloads"
        self.tableView.tableHeaderView = self.viewEditMenu
     
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        //
        self.setupEditContentData()
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        // Reset selected state
        for tmp in self.editItems { tmp.isSelected = false }
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func actionSelectAll(_ sender: Any) {
        if self.btnSelectAll.isSelected == true {
            let ab = self.editItems.filter({ $0.isSelected == true })
            self.deleteItems(with: ab)
        }
        else {
            for tmp in self.editItems { tmp.isSelected = true }
            self.tableView.reloadData()
            self.btnSelectAll.isSelected.toggle()
        }
    }
    
    func deleteItems(with items: [DownloadItem]) {
        for tmp in items {
            if let contentId = tmp.contentId {
                do {
                    try Zee5DownloadManager.shared.removeDownloadItem(id: contentId)
                    editItems.removeAll { ($0.isSelected == true) }
                    self.tableView.reloadData()
                }
                catch {
                    ZeeUtility.utility.console("Delete download Error: \(error.localizedDescription)")
                
                }
            }
        }
        self.btnSelectAll.isSelected.toggle()
        
        NotificationCenter.default.post(name: AppNotification.editDownload, object: nil)
        
        if self.editItems.isEmpty {
            if self.selectedIndex == 101 {
                for tmp in self.editItems { tmp.isSelected = false }
                for controller in self.navigationController?.viewControllers ?? [] {
                    if controller.isKind(of: DownloadRootController.self) {
                        self.navigationController?.popToViewController(controller, animated: true)
                        break
                    }
                }
            }
            else {
                self.actionBack(UIButton())
            }
        }
    }
}

extension EditDownloadController {
    
    func setupEditContentData() {
        if self.selectedIndex == 0 { // Show
            self.getEpisodes()
        }
        else if self.selectedIndex == 1 { // Movie
            self.getMovies()
        }
        else if self.selectedIndex == 2 { // Video
            self.getVideos()
        }
        else if self.selectedIndex == 101 { // Show-Detail
            self.getShows(for: self.selectedShow)
        }
    }
    
    func getEpisodes() {
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
            self.editItems = items
            self.tableView.reloadData()
        }
        catch {
            ZeeUtility.utility.console("error: getDownloadedItems: \(error.localizedDescription)")
        }
    }
    
    func getMovies() {
        do {
            guard let downloads = try Zee5DownloadManager.shared.getAllMovies() as? [ZeeDownloadItem] else { return }
            var items = [DownloadItem]()
            for item in downloads {
                let tmp = DownloadItem()
                tmp.contentId = item.contentId
                tmp.title = item.title
                tmp.showTitle = item.showOriginalTitle
                tmp.estimatedBytes = Int64(item.estimatedSize)
                tmp.status = item.state.asString()
                tmp.downloadState = item.state
                tmp.imgUrl = item.imageURL
                tmp.duration = item.duration
                tmp.assetType = item.assetType
                items.append(tmp)
            }
            self.editItems = items
            self.tableView.reloadData()
        }
        catch {
            ZeeUtility.utility.console("error: getDownloadedItems: \(error.localizedDescription)")
        }
    }
    
    func getVideos() {
        do {
            guard let downloads = try Zee5DownloadManager.shared.getAllVideos() as? [ZeeDownloadItem] else { return }
            var items = [DownloadItem]()
            for item in downloads {
                let tmp = DownloadItem()
                tmp.contentId = item.contentId
                tmp.title = item.title
                tmp.showTitle = item.showOriginalTitle
                tmp.estimatedBytes = Int64(item.estimatedSize)
                tmp.status = item.state.asString()
                tmp.downloadState = item.state
                tmp.imgUrl = item.imageURL
                tmp.duration = item.duration
                tmp.assetType = item.assetType
                items.append(tmp)
            }
            self.editItems = items
            self.tableView.reloadData()
        }
        catch {
            ZeeUtility.utility.console("error: getDownloadedItems: \(error.localizedDescription)")
        }
    }
    
    func getShows(for title: String?) {
        do {
            if let title = title {
                guard let downloads = try Zee5DownloadManager.shared.getEpisodesByShow(showTitle: title) else { return }
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
                    items.append(tmp)
                }
                self.editItems = items
                self.tableView.reloadData()
            }
        }
        catch {
            ZeeUtility.utility.console("Error: getAllEpisodes: \(error.localizedDescription)")
        }
    }
    
}

extension EditDownloadController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.editItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EditDownloadCell.identifier, for: indexPath) as? EditDownloadCell else { return UITableViewCell() }
        cell.currentItem = self.editItems[indexPath.row]
        
        cell.btnRadio.tag = indexPath.row
        cell.btnRadio.addTarget(self, action: #selector(self.actionRadio(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectTableRow(at: indexPath.row)
    }
    
    @objc func actionRadio(_ btn: UIButton) {
        self.didSelectTableRow(at: btn.tag)
    }
    
    private func didSelectTableRow(at index: Int) {
        let item = self.editItems[index]
        item.isSelected.toggle()
        self.tableView.reloadData()
        
        self.btnSelectAll.isSelected = self.editItems.contains { ($0.isSelected == true) }
    }
}
