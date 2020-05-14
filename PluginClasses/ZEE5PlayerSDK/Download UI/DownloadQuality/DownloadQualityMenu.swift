//
//  DragableView.swift
//  Zee5DownloadSDK
//
//  Created by Abhishek on 21/12/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit

public class DownloadQualityMenu: UIView {
    
    static let identifier = "DownloadQualityMenu"
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnDownload: UIButton!
   @objc @IBOutlet weak var Con_table_height: NSLayoutConstraint!
    
    private var downloadOption = [Z5Option]()
    private var currentDownloadItem: ZeeDownloadItem!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewBackground.roundCorners(corners: [.topLeft, .topRight], radius: 25.0)
        self.btnDownload.applyGradient(withColors: AppColor.gradient)
        
        let bundle = Bundle(for: DownloadRootController.self)
        self.tableView.register(UINib(nibName: VideoQualityCell.identifer, bundle: bundle), forCellReuseIdentifier: VideoQualityCell.identifer)
          rotated()

        
        self.setupDragable()
    }
    
    func setupVideoQuality(with config: Z5VideoConfig, data: ZeeDownloadItem) {
        self.currentDownloadItem = data
        self.downloadOption = config.download_options ?? []
        self.tableView.reloadData()
    }
    @objc func rotated(){
        
        if UIDevice.current.orientation.isLandscape{
            print("landscape");
             self.Con_table_height.constant = 190.0
        }
        if UIDevice.current.orientation.isPortrait{
            self.Con_table_height.constant = 295.0
        }
    }
    
    @IBAction func actionStartDownload(_ sender: Any) {
        if let idx = self.tableView.indexPathForSelectedRow {
            DownloadHelper.shared.removeDownloadOptionMenu()
            let option = self.downloadOption[idx.row]
            if let bitrate = option.bitrate {
                DownloadHelper.shared.selectedVideoResolution(videoBitrate: bitrate, data: self.currentDownloadItem)
                
                AnalyticEngine.shared.downloadStart(with: option.resolution!)
                
            }
        }
    }
    
    @IBAction func actionDismisss(_ sender: Any) {
        DownloadHelper.shared.removeDownloadOptionMenu()
        DownloadHelper.shared.removeContent(with: self.currentDownloadItem.contentId)
    }
}

extension DownloadQualityMenu: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.downloadOption.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoQualityCell.identifer) as? VideoQualityCell else { return UITableViewCell() }
        cell.selectedOption = self.downloadOption[indexPath.row]
        cell.setSelected(false, animated: true)
        return cell
    }
}

extension DownloadQualityMenu {
    
    func setupDragable() {
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrag(_:))))
    }
    
    @objc fileprivate func onDrag(_ sender: UIPanGestureRecognizer) {
        let percentThreshold: CGFloat = 0.3
        let translation = sender.translation(in: self)
        
        let newY = ensureRange(value: self.frame.minY + translation.y, minimum: 0, maximum: self.frame.maxY)
        let progress = progressAlongAxis(newY, self.bounds.height)
        
        self.frame.origin.y = newY
        
        if sender.state == .ended {
            let velocity = sender.velocity(in: self)
            if velocity.y >= 300 || progress > percentThreshold {
                DownloadHelper.shared.removeDownloadOptionMenu()
                DownloadHelper.shared.removeContent(with: self.currentDownloadItem.contentId)
            }
            else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.frame.origin.y = 0
                })
            }
        }
        sender.setTranslation(.zero, in: self)
    }

    fileprivate func progressAlongAxis(_ pointOnAxis: CGFloat, _ axisLength: CGFloat) -> CGFloat {
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
        let positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
        return CGFloat(positiveMovementOnAxisPercent)
    }

    fileprivate func ensureRange<T>(value: T, minimum: T, maximum: T) -> T where T : Comparable {
        return min(max(value, minimum), maximum)
    }
}
