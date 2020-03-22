//
//  ZeeDownloadModel.swift
//  Zee5DownloadManager
//
//  Created by User on 20/06/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit

public enum ZeeTaskStatus: Int {
    case unknown, gettingInfo, downloading, paused, failed, cancelled, completed
    
    public func description() -> String {
        switch self {
        case .gettingInfo:
            return "GettingInfo"
        case .downloading:
            return "Downloading"
        case .paused:
            return "Paused"
        case .failed:
            return "Failed"
        case .cancelled:
            return "Cancelled"
        case .completed:
            return "Completed"
        default:
            return "Unknown"
        }
    }
}

open class ZeeDownloadModel: NSObject {
    
    open var itemId         : String!
    open var fileName       : String!
    open var fileURL        : String!
    open var status         : String = ZeeTaskStatus.gettingInfo.description()
    open var file           : (size: Float, unit: String)?
    open var downloadedFile : (size: Float, unit: String)?
    open var remainingTime  : (hours: Int, minutes: Int, seconds: Int)?
    open var speed          : (speed: Float, unit: String)?
    open var progress       : Float = 0
    open var tasks          : [URLSessionDownloadTask]!
    open var startTime      : Date?
    open var totalFileSize  : Int64?
    open var downloadedSize : Int64 = 0
    
    fileprivate(set) open var destinationPath: String = ""
    
    fileprivate convenience init(itemId: String, fileName: String, fileURL: String) {
        self.init()
        self.itemId = itemId
        self.fileName = fileName
        self.fileURL = fileURL
        self.tasks = []
    }
    
    convenience init(itemId: String, fileName: String, fileURL: String, destinationPath: String) {
        self.init(itemId: itemId, fileName: fileName, fileURL: fileURL)
        self.itemId = itemId
        self.destinationPath = destinationPath
        self.tasks = []
    }
    
    convenience init(itemId: String, fileName: String, fileURL: String, destinationPath: String, fileSize : Int64) {
        self.init(itemId: itemId, fileName: fileName, fileURL: fileURL)
        self.itemId = itemId
        self.destinationPath = destinationPath
        self.totalFileSize = fileSize
        self.tasks = []
    }
}

