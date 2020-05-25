//
//  ChrmoeMediaController.swift
//  Zee5DownloadSDK
//
//  Created by Abhishek Gour on 06/11/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit
import DropDown
import GoogleCast

class ChrmoeMediaController: UIViewController, GCKRemoteMediaClientListener, GCKSessionManagerListener, GCKRequestDelegate {
    
    @IBOutlet weak var tableView: HPReorderTableView!
    @IBOutlet weak var currentItemImageView: UIImageView!
    @IBOutlet weak var currentItemTitleLbl: UILabel!
    @IBOutlet weak var currentItemPlayPauseBtn: UIButton!
    @IBOutlet weak var currentItemDuration: UILabel!
    
    var moreMenuOption: UIBarButtonItem!
    var menuOption = DropDown()
    var delegate: QueueOptionDelegate?
    var mediaClient: GCKRemoteMediaClient!
    var sessionManager: GCKSessionManager!
    var queueRequest: GCKRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.moreMenuOption = UIBarButtonItem(image:UIImage(named:"moreIcon"), style:.plain, target:self, action:#selector(self.moreSetting(_:)))
        self.moreMenuOption.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = self.moreMenuOption
        
        if GCKCastContext.sharedInstance().sessionManager.hasConnectedCastSession() {
            self.sessionManager = GCKCastContext.sharedInstance().sessionManager
            self.sessionManager.add(self)
            self.attach(to: self.sessionManager.currentCastSession!)
            self.showCurrentItem(sessionManager: self.sessionManager)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if self.sessionManager?.hasConnectedCastSession() ?? false {
            self.detachFromCastSession()
        }
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func currentItemPlayPauseBtn(_ sender: Any) {
        if self.sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.currentQueueItem != nil {
            if self.sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.playerState.rawValue == 2 {
                self.sessionManager.currentCastSession?.remoteMediaClient?.pause()
                self.currentItemPlayPauseBtn.setImage(UIImage(named: "playIcon"), for: .normal)
            }
            else if self.sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.playerState.rawValue == 3 {
                self.sessionManager.currentCastSession?.remoteMediaClient?.play()
                self.currentItemPlayPauseBtn.setImage(UIImage(named: "pauseIcon"), for: .normal)
            }
        }
    }
    
    func loadMenu() {
    }
    
    func showCurrentItem(sessionManager: GCKSessionManager) {
        let item = sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.currentQueueItem
        currentItemTitleLbl.text = item?.mediaInformation.metadata?.string(forKey: kGCKMetadataKeyTitle)
        if let currentImage = item?.mediaInformation.metadata?.images()[0] as? GCKImage {
            GCKCastContext.sharedInstance().imageCache?.fetchImage(for: (currentImage.url), completion: { (image) in
                self.currentItemImageView.image = image
            })
        }
        if sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.queueHasCurrentItem ?? false{
            let mediaInfo = sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.currentQueueItem?.mediaInformation
            guard let duration = mediaInfo?.metadata?.integer(forKey: "contentLength") else {return}
            self.currentItemDuration.text = totalDuration(duration: duration)
        }
    }
    
    @objc private func moreSetting(_ btn: UIButton) {
        let arr = [QueueOptionMenu.addToMyWatchList.description, QueueOptionMenu.clearQueue.description]
        self.menuOption.dataSource = arr
        self.setUpQueueMenu(with: [QueueOptionMenu.addToMyWatchList, QueueOptionMenu.clearQueue])
        self.menuOption.show()
    }
    
    func totalDuration(duration: Int) -> String {
        let seconds = duration % 60
        let minutes = (duration/60) % 60
        let hours = duration / 3600
        return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds) as String
    }
    
    private func setUpQueueMenu(with data: [QueueOptionMenu]) {
        let appearance = DropDown.appearance()
        appearance.backgroundColor = .white
        appearance.textColor = UIColor(hex: "333333")
        appearance.textFont = AppFont.regular(size: 16)
        appearance.cellHeight = 50
        appearance.selectionBackgroundColor = .clear
        appearance.selectedTextColor = UIColor(hex: "333333")
        appearance.layer.cornerRadius = 10
        
        self.menuOption.anchorView = self.moreMenuOption
        self.menuOption.direction = .any
        self.menuOption.dataSource = data.map {($0.description)}
        let bundle = Bundle(for: ChromeCastManager.self)
        self.menuOption.cellNib = UINib(nibName: DownloadMenuCell.identifier, bundle: bundle)
        
        self.menuOption.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? DownloadMenuCell else { return }
            cell.optionLabel.text = item
        }
        
        self.menuOption.selectionAction = { [weak self] (index: Int, item: String) in
            self?.delegate?.didSelectMenuOption(dataIndex: index, queueMenuOption: item)
        }
        
        self.menuOption.willShowAction = {
            self.delegate?.showQueueMenu()
        }
        
        self.menuOption.cancelAction = {
            self.delegate?.hideQueueMenu()
        }
    }
    
    func attach(to castSession: GCKCastSession) {
        self.mediaClient = castSession.remoteMediaClient
        self.mediaClient.add(self)
        self.tableView.reloadData()
    }
    
    func detachFromCastSession() {
        self.mediaClient.remove(self)
        self.mediaClient = nil
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        self.mediaClient = sessionManager.currentCastSession?.remoteMediaClient
    }
}


extension ChrmoeMediaController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.mediaClient != nil{
            if let count = self.mediaClient.mediaStatus?.queueItemCount {
                return Int(count)
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChromeQueueCell.identifier, for: indexPath) as? ChromeQueueCell else { return UITableViewCell() }
        if let item = self.mediaClient.mediaStatus?.queueItem(at: UInt(bitPattern: indexPath.row)) {
            cell.lblTitle.text = item.mediaInformation.metadata?.string(forKey: kGCKMetadataKeyTitle)
            if let images = item.mediaInformation.metadata?.images(), images.count > 0 {
                let image = images[0] as? GCKImage
                GCKCastContext.sharedInstance().imageCache?.fetchImage(for: (image?.url)!,
                                                                       completion: { (_ image: UIImage?) -> Void in
                                                                        cell.imgView?.image = image
                })
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var destItemID = kGCKMediaQueueInvalidItemID
        if sourceIndexPath.row == destinationIndexPath.row { return }
        
        guard let currenItem = self.mediaClient.mediaStatus?.queueItem(at: UInt(sourceIndexPath.row)) else { return }
        let currentItemID = currenItem.itemID
        guard let itemCount = self.mediaClient.mediaStatus?.queueItemCount else { return }
        if destinationIndexPath.row < itemCount - 1{
            guard let destionationItem = self.mediaClient.mediaStatus?.queueItem(at: UInt(destinationIndexPath.row)) else {return}
            destItemID = destionationItem.itemID
        }
        self.start(mediaClient.queueMoveItem(withID: currentItemID, beforeItemWithID: destItemID))
    }
    
    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = self.mediaClient.mediaStatus?.queueItem(at: UInt(indexPath.row))
            if item != nil {
                self.start(self.mediaClient.queueRemoveItem(withID: (item?.itemID)!))
            }
        }
    }
    
    func start(_ request: GCKRequest) {
        self.queueRequest = request
        self.queueRequest.delegate = self
        self.mediaClient?.play()
    }
}
