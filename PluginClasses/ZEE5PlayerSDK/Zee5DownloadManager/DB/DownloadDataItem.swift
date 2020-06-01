//
//  DownloadItem.swift
//  Zee5DownloadManager
//
//  Created by User on 20/06/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import Foundation
import PlayKit

public class ZeeDownloadItem: NSObject, DownloadDataItem {
    public var contentId                   = ""
    public var contentUrl                  = ""
    public var licenseUrl                  = ""
    public var title                       = ""
    public var imageURL                    = ""
    public var showimgUrl                  = ""
    public var Agerating                   = ""
    public var info                        = ""
    public var category                    = ""
    public var episode                     = ""
    public var base64encodedcertificate    = ""
    public var customData                  = ""
    public var estimatedSize: Int          = 0
    public var downloadedSize: Int         = 0
    public var state: DownloadItemState    = .new
    public var isDrmRegistered             = false
    public var isDrmProtected              = false
    public var destinationUrl              = ""
    public var localThumbnailUrl           = ""
    public var completedTime               = Date()
    public var expiryTime: Int64           = 0
    //
    public var assetType                   = ""
    public var assetSubType                = ""
    public var episodeNumber               = 0
    public var duration: Int               = 0
    public var showOriginalTitle           = ""
    public var offlinePlayingDuration: Int = 0
    
    //
    public var contentEntry: PKMediaEntry?
    public var contentMeadiaSorce: PKMediaSource!
    public var contentFairPlay: FormFairPlayLicenseProvider?
    
    public init(id: String, url: String, title: String, imageUrl: String,showimgUrl: String ,info: String, episodeNumber: Int, assetType: String, assetSubType: String, duration: Int, showOriginalTitle: String, licenseUrl: String, base64: String, customData: String,Age:String) {
     
        self.contentId = id
        self.contentUrl = url
        self.title = title
        self.imageURL = imageUrl
        self.info = info
        self.episodeNumber = episodeNumber
        self.assetType = assetType
        self.assetSubType = assetSubType
        self.duration = duration
        self.showOriginalTitle = showOriginalTitle
        self.Agerating = Age
        
        self.licenseUrl = licenseUrl
        self.base64encodedcertificate = base64
        self.customData = customData
        self.showimgUrl = showimgUrl
        
        let fairParam = FairPlayDRMParams(licenseUri: licenseUrl, base64EncodedCertificate: base64)
        self.contentMeadiaSorce = PKMediaSource(id, contentUrl: URL(string: url), mimeType: nil, drmData: [fairParam], mediaFormat: .hls)
        self.contentEntry = PKMediaEntry(id, sources: [self.contentMeadiaSorce], duration: 1000)
        self.contentFairPlay = FormFairPlayLicenseProvider()
        self.contentFairPlay?.customData = customData
    }
    
    public override init() {}
}

public struct FairPlayData {
    public let licenseUrl: String
    public let base64Certificate: String
    public let customData: String
}

/**
 # Downloadable Item #
 */
public protocol DownloadDataItem {
    
    // Item's unique id.
    var contentId: String { get }
    
    // Item's Age rating
    var Agerating: String { get }
    
    // Item's remote URL.
    var contentUrl: String { get }
    
    // Item's license URL.
    var licenseUrl: String { get }
    
    // Item's title.
    var title: String { get }
    
    // Item's image URL.
    var imageURL: String { get set }
    
    // Item's Show image URL.
    var showimgUrl: String { get set }
    
    // Item's description.
    var description: String { get }
    
    // Item's category.
    var category: String { get }
    
    // Item's episode.
    var episode: String { get }
    
    // Item's base64 certificate for downloading content
    var base64encodedcertificate: String { get }
    
    // Item's custom data for offline playback
    var customData: String { get }
    
    // Estimated size of item.
    var estimatedSize: Int { get }
    
    // Downloaded size in bytes.
    var downloadedSize: Int { get set }
    
    // Item's current state.
    var state: DownloadItemState { get set }
    
    // Item's registered for DRM or not
    var isDrmRegistered: Bool { get }
    
    // Item's protected to DRM or not
    var isDrmProtected: Bool { get }
    
    // Item's remote URL.
    var destinationUrl: String { get }
    
    // Item's remote URL.
    var localThumbnailUrl: String { get set }
    
    // Completed time of the item
    var completedTime: Date { get }
    
    // Expiry time
    var expiryTime: Int64 { get }
    
    /////
    var assetType: String { get set }
    
    var assetSubType: String { get set }
    
    var episodeNumber: Int { get set }
    
    var duration: Int { get set }
    
    var showOriginalTitle: String { get set }
    
    var offlinePlayingDuration: Int { get set }
    
    //
    var contentEntry: PKMediaEntry? { get set }
    var contentFairPlay: FormFairPlayLicenseProvider? { get set }
}

// Enum for Download item
 
@objc public enum DownloadItemState: Int {
    // Item was just added, no metadata is available except for the id and the URL.
    case new
    
    // Item added to download queue.
    case inQueue
    
    // Item download is in progress.
    case inProgress
    
    // Item is paused by the app/user/network failure.
    case paused
    
    // Item has finished downloading and processing.
    case completed
    
    // Item download has failed (fatal error cannot use this item again).
    case failed
    
    // Item download was interrupted
    case interrupted
    
    // Item is removed. This is only a temporary state, as the item is actually removed.
    case removed
    
    // No Network Available
    case noNetwork
    
    // Item is expired
    case expired
    
    // Db failure
    case dbFailure
    
    public init?(value: String) {
        switch value {
        case DownloadItemState.new.asString(): self = .new
        case DownloadItemState.inQueue.asString(): self = .inQueue
        case DownloadItemState.inProgress.asString(): self = .inProgress
        case DownloadItemState.paused.asString(): self = .paused
        case DownloadItemState.completed.asString(): self = .completed
        case DownloadItemState.failed.asString(): self = .failed
        case DownloadItemState.interrupted.asString(): self = .interrupted
        case DownloadItemState.removed.asString(): self = .removed
        case DownloadItemState.noNetwork.asString(): self = .noNetwork
        case DownloadItemState.expired.asString(): self = .expired
        case DownloadItemState.dbFailure.asString(): self = .dbFailure
        default: return nil
        }
    }

    public func asString() -> String {
        switch self {
        case .new: return "new"
        case .inQueue: return "inQueue"
        case .inProgress: return "inProgress"
        case .paused: return "paused"
        case .completed: return "completed"
        case .failed: return "failed"
        case .interrupted: return "interrupted"
        case .removed: return "removed"
        case .noNetwork: return "noNetwork"
        case .expired: return "expired"
        case .dbFailure: return "dbFailure"
        }
    }
}

// Enum that represents error codes
public enum ZeeError: LocalizedError {
    // Sent when item not found
    case itemNotFound(itemId: String)
    // Sent when item cannot be started (casued when item state is other than metadata loaded)
    case invalidState(itemId: String)
    // Insufficient disk space to start or continue the download
    case insufficientDiskSpace(freeSpaceInMegabytes: Int)
    // Sent when can not pause downloading content
    case unableToPause(itemId: String)
    // Sent when can not start or resume downloading content
    case unableToStart(itemId: String)
    // Sent when can not cancel or remove downloading content
    case unableToCancel(itemId: String)
    // Sent when failed to create tracks
    case unableToGetTracks
    // Sent when failed remove all dowloaded contents
    case unableToRemoveAll
    // No Network
    case noNetworkError
    
    // Custom Message
    case withError(message: String)
    
    public var errorDescription: String? {
        switch self {
        case .itemNotFound(let itemId):
            return "The item (id: \(itemId)) of the action was not found"
        case .invalidState(let itemId):
            return "try to make an action with an invalid state (item id: \(itemId))"
        case .insufficientDiskSpace(let freeSpaceInMegabytes):
            return "insufficient disk space to start or continue the download, only have \(freeSpaceInMegabytes)MB free..."
        case .unableToPause(let itemId):
            return "The item (id: \(itemId)) failed to pause"
        case .unableToStart(let itemId):
            return "The item (id: \(itemId)) failed to start"
        case .unableToCancel(let itemId):
            return "The item (id: \(itemId)) failed to remove"
        case .unableToGetTracks:
            return "Failed to get tracks"
        case .unableToRemoveAll:
            return "Unable to remove all downloaded contents"
        case .noNetworkError:
            return "Unable to connect to network"
        case .withError(let message):
            return message
        }
    }
}

