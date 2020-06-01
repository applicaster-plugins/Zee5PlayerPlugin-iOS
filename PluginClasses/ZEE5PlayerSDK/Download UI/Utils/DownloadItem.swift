//
//  DownloadItem.swift
//  DemoProject
//
//  Created by admin on 20/09/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import Foundation

public class DownloadItem {
    var contentId: String?
    var title: String?
    var showTitle: String?
    var imgUrl: String?
    var showimgUrl: String?
    var noOfEpisodes: String?
    var noOfBytes: String?
    var noOfDownloads: String?
    var duration: Int?
    var status: String?
    var lblInfo: String?
    var videoPlayedDuration: Int?
    
    var isSelected = false
    var downloadState: DownloadItemState = .new
    var estimatedBytes: Int64?
    var downloadedBytes: Int64?
    
    //new
    var episodeNumber: Int?
    var assetType: String?
    var originalTitle: String?
    var pendingDownloads: String?
    //var Agerating: String?
    
    init() {}
    
    init(itemId: String, title: String, imgUrl: String,showimgUrl: String, noOfEpisodes: String, noofBytes: String, noOfDownloads: String, duration: Int, status: String, lblInfo: String)
    {
        self.contentId = itemId
        self.showimgUrl = showimgUrl
        self.title = title
        self.imgUrl = imgUrl
        self.noOfEpisodes = noOfEpisodes
        self.noOfBytes = noofBytes
        self.noOfDownloads = noOfDownloads
        self.duration = duration
        self.status = status
        self.lblInfo = lblInfo
       // self.Agerating = Agerating
    }
}
