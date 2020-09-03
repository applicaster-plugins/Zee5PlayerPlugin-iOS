//
//  Zee5DownloadManager.swift
//  Zee5DownloadManager
//
//  Created by User on 10/06/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import Foundation
import DownloadToGo
import PlayKit
import Alamofire
import Zee5CoreSDK

// Network preferences enum
enum DeviceNetwork {
    case wifi
    case mobile
    
    var description: String {
        switch self {
        case .wifi: return "WiFi"
        case .mobile: return "Mobile"
        }
    }
}

// Downoading tasks events callback
public protocol Zee5DownloaderDelegate: class {
    func downloadItemWithData(id: String, didDownloadData totalBytesDownloaded: Int64, totalBytesEstimated: Int64?)
    func downloadItemWithState(id: String, didChangeToState newState: DownloadItemState, error: Error?)
}

// Zee5 Download Manger class
public class Zee5DownloadManager {
    
    public static let shared = Zee5DownloadManager()
    
    // MARK:- Variables
    public var delegate: Zee5DownloaderDelegate?
    private var cm: DTGContentManager?
    private var zeDB: ZeeDB?
    private let minimumDiskSpaceInBytes: Int64 = 200000000
    
    // Variables:- Network reachability helpers
    private let reachability = NetworkReachabilityManager()
    private var networkConnection: DeviceNetwork = .wifi
    private var isWifiOnly = false
    
    //
    private var circularRings = [UICircularProgressRing]()
    private var buttonDownlodState = [UIButton]()
    private var viewPause = [UIView]()
    
    //
    public var mediaEntry: PKMediaEntry?
    public var localAsset = LocalAssetsManager.managerWithDefaultDataStore()
    
    // MARK:- Initializer
    public init() {
    }
    
    // Initialize Zee5 download manager
    public func initializeDownloadManger() {
        // setup content manager and delegate
        self.cm = ContentManager.shared
        self.cm?.delegate = self
        
        // setup db
        do {
            try self.cm?.setup()
            ZeeUtility.utility.console("Home dir: \(NSHomeDirectory())")
            
            // setup db
            try self.setupDataBase()
            
            try self.cm?.start() {
                ZeeUtility.utility.console("server started")
            }
            
    NotificationCenter.default.addObserver(self,selector:#selector(self.logoutDone),name: NSNotification.Name.ZPLoginProviderLoggedOut,
            object: nil)
            
            // Check network connection
            self.setupNetworkReachablity()
            
        }
        catch {
            // handle error here
            ZeeUtility.utility.console("Initialisation Error: \(error.localizedDescription)")
        }
    }
    
    // MARK:- Methods
    // Database initialization
    fileprivate func setupDataBase() throws {
        self.zeDB = ZeeDB()
        _ = try getZeeDB()
        self.zeDB?.createTable()
    }
    
    @objc private func logoutDone(){
        _ = try? self.removeAll()
    }
    
    // Checking current network connection state
    fileprivate func setupNetworkReachablity() {
        // When connected to the internet
        self.reachability?.startListening()
        self.reachability?.listener = { _ in
            if let isNetworkReachable = self.reachability?.isReachable,
                isNetworkReachable == true {
                if self.reachability?.isReachableOnEthernetOrWiFi ?? false {
                    ZeeUtility.utility.console("Reachable via WiFi")
                    self.networkConnection = .wifi
                }
                else if self.reachability?.isReachableOnWWAN ?? false {
                    ZeeUtility.utility.console("Reachable via WiFi")
                    self.networkConnection = .wifi
                }
                else {
                    ZeeUtility.utility.console("Reachable via Mobile Data")
                    self.networkConnection = .mobile
                }
            }
            else { // Internet Not Available"
                ZeeUtility.utility.console("No Connection")
            }
        }
    }
    
    /**
     Setup FairPlay LicenseProvider
     
     - Parameters:
        - fairPlay: Fair play license along with custom data.
        - entry: PKMedia entery object that holds FairPlay DRM object.
     */
    public func setFairPlayLicense(fairPlay: FairPlayLicenseProvider?, entry: PKMediaEntry?) {
        self.mediaEntry = entry
        self.localAsset.fairPlayLicenseProvider = fairPlay
    }
    
    /**
     Add item to download
     
     - Parameters:
        - item: Configure `ZeeDownloadItem` from content detail.
     
     - Throws: `ZeeError.withError`
                If unable to add item for downloading.
     */
    public func addItem(item: ZeeDownloadItem) throws {

        if let mEntry = item.contentEntry,
            let mSource = self.localAsset.getPreferredDownloadableMediaSource(for: mEntry) {
            
            do {
                var myItem: DTGItem?
                myItem = try cm?.itemById(item.contentId)
                if myItem == nil {
	                    myItem = try cm?.addItem(id: mEntry.id, url: mSource.contentUrl!)
                    if myItem != nil {
                        try zeDB?.add(item: item)
                    }
                }
            } catch {
                let msg = "Unable to add item. Please try again: \(error.localizedDescription)"
                ZeeUtility.utility.console(msg)
                throw ZeeError.withError(message: msg)
            }
        }
    }
    
    /**
     Load item for downloading the content with check network preferences
     
     - Parameters:
        - id: Content id of the downloading item.
        - bitrate: Select bitrate of the downloading item.
     
     - Throws: `ZeeError.withError`
                If unable to add item for downloading.
     */
    
    public func startDownload(id: String, bitrate: Int, videoDetail: ZeeDownloadItem?) throws {
        do {
            // load metadata
            try self.cm?.loadItemMetadata(id: id, preferredVideoBitrate: bitrate)
            
            // First check Need to check network download preference before start the downloading
            if self.networkConnection == .mobile && self.isWifiOnly == true {
                let msg = "Please connect device with WiFi connection or change the downloading preference in the app settings"
                ZeeUtility.utility.console(msg)
                throw ZeeError.withError(message: msg)
            }
            else { // Good to go
                try self.downloadingContent(id: id, videoItem: videoDetail)
              
            }
        }
        catch {
            let msg = "start Download: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    /**
     Start downloading the content
     
     - Parameters:
        - id: Content id of the downloading item.
     
     - Throws: `ZeeError.withError`
                If unable to start downloading the content.
     */
    fileprivate func downloadingContent(id: String, videoItem: ZeeDownloadItem?) throws {
        do {
            let item = try self.getItemInfo(id: id)
            // Make sure we have enough space and a we have more that the minimum we allow
            if let freeDiskSpace = self.getFreeDiskSpaceInBytes() {
                if let estimatedSize = item?.estimatedSize {
                    if (freeDiskSpace <= (estimatedSize + self.minimumDiskSpaceInBytes)) {
                        throw DTGError.insufficientDiskSpace(freeSpaceInMegabytes: Int(freeDiskSpace/1000000))
                    }
                    else { // Downloading the content
                        try self.initiateDownload(contentId: id, videoItem: videoItem)
                    }
                }
                else { // Downloading the content
                    try self.initiateDownload(contentId: id, videoItem: videoItem)
                }
            }
            else { // Downloading the content
                try self.initiateDownload(contentId: id, videoItem: videoItem)
            }
        }
        catch {
            let msg = "Unable to start downloading the content: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    fileprivate func initiateDownload(contentId: String, videoItem: ZeeDownloadItem?) throws {
        do {
            try self.cm?.startItem(id: contentId)
            if let item = videoItem {
                try self.zeDB?.update(item: item)
            }
        }
        catch {
            let msg = "Unable to start downloading the content: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    /**
     Playing the downloaded content
     
     - Parameters:
        - id: Content id of the downloading item.
     
     - Throws: `ZeeError.withError`
                If unable to get playblack url of the content.
     
     - Returns: The local url of the downloaded item `URL`.
     
     */
    public func playbackUrl(id: String) throws -> URL? {
        do {
            return try cm?.itemPlaybackUrl(id: id)
        } catch {
            let msg = "Playback url is not found: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    /**
     Get downloaded item detail
     
     - Parameters:
        - id: Content id of the downloading item.
     
     - Throws: `ZeeError.withError`
                If unable to get details of the downloaded content.
     
     - Returns: The downloaded item `DTGItem`.
     */
    fileprivate func getItemInfo(id: String) throws -> DTGItem? {
        do {
            return try cm?.itemById(id)
        } catch {
            let msg = "Playback url is not found: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    /**
     Get item by downloading state
     
     - Parameters:
        - state: DTGItemState of downloading and downloaded items.
     
     - Throws: `ZeeError.withError`
                If unable to get item by particular downloaded state.
     
     - Returns: The array of downloaded items `[DTGItem]`.
     */
    public func getItemsByState(_ state: DTGItemState) throws -> [DTGItem]? {
        do {
            return try cm?.itemsByState(state)
        } catch {
            let msg = "Items not found: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    public func getItemById(id: String) throws -> ZeeDownloadItem? {
        do {
            let item = try zeDB?.item(byId: id)
            return item
        } catch {
            let msg = "Items not found: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    /**
     Resume the download if it is paused state
     
     - Parameters:
        - id: Content id of the downloading item.
     
     - Throws: `ZeeError.withError`
                If unable to resume the download.
     */
    public func resumeDownloadItem(id: String) throws {
        do {
            try cm?.startItem(id: id)
        } catch {
            let msg = "Unable to resume the content: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: "Unable to resume the content")
        }
    }
    
    
    /**
     Pause the download if it is resume state
     
     - Parameters:
        - id: Content id of the downloading item.
     
     - Throws: `ZeeError.withError`
                If unable to pause the download.
     */
    public func pauseDownloadItem(id: String) throws {
        do {
            try cm?.pauseItem(id: id)
        } catch {
            let msg = "Unable to pause the content: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    /**
     Delete or Remove the downloaded item
     
     - Parameters:
        - id: Content id of the downloading item.
     
     - Throws: `ZeeError.withError`
                If unable to delete or remove the content.
     */
    public func removeDownloadItem(id: String) throws {
        do {
            // Remove content
            try cm?.removeItem(id: id)
            
            try self.zeDB?.removeItem(byId: id)
            
        } catch {
            let msg = "Unable to delete or remove the content: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    /**
     Register or Renew the item to make it available for offline playback
     
     - Parameters:
        - id: Content id of the downloading item.
     
     - Throws: `ZeeError.withError`
                If unable to register or renew the content.
     */
    public func renewItem(id: String) throws {
        do {
            guard let url = try self.cm?.itemPlaybackUrl(id: id) else {
                ZeeUtility.utility.console("Can't get local url")
                return
            }
            
            let ab = try self.zeDB?.item(byId: id)
            if let lUrl = ab?.licenseUrl, let base64 = ab?.base64encodedcertificate, let cData = ab?.customData, let videoUrl = ab?.contentUrl {
            
                let fairParam = FairPlayDRMParams(licenseUri: lUrl, base64EncodedCertificate: base64)
                let source = PKMediaSource(id, contentUrl: URL(string: videoUrl), mimeType: nil, drmData: [fairParam], mediaFormat: .hls)
                let entry = PKMediaEntry(id, sources: [source], duration: 1000)
                let fairPlay = FormFairPlayLicenseProvider()
                fairPlay.customData = cData
                
                guard let localSource = self.localAsset.getPreferredDownloadableMediaSource(for: entry) else {
                    ZeeUtility.utility.console("No valid source")
                    return
                }
                self.localAsset.renewDownloadedAsset(location: url, mediaSource: localSource) { (error) in
                    let msg = error == nil ? "Renew Complete" : "Renew Error: \(error?.localizedDescription ?? "")"
                    ZeeUtility.utility.console("Error msg: \(msg)")
                    ZeeUtility.utility.console("Error: \(String(describing: error))")
                }
            }
        }
        catch {
            ZeeUtility.utility.console(error.localizedDescription)
        }
    }
    
    /**
     Renew expired content for extending availablility for offline playback
     
     - Parameters:
     - id: Content id of the downloading item.
     
     - Throws: `ZeeError.withError`
     If unable to register or renew the content.
     */
    public func renewExpiredContent(with item: ZeeDownloadItem) throws {
        do {
            guard let url = try self.cm?.itemPlaybackUrl(id: item.contentId) else {
                ZeeUtility.utility.console("Can't get local url")
                return
            }
            if let mEntry = item.contentEntry{
            let fairParam = FairPlayDRMParams(licenseUri: item.licenseUrl, base64EncodedCertificate: item.base64encodedcertificate)
            let source = PKMediaSource(item.contentId, contentUrl: URL(string: item.contentUrl), mimeType: nil, drmData: [fairParam], mediaFormat: .hls)
            let entry = PKMediaEntry(item.contentId, sources: [source], duration: 1000)
            let fairPlay = FormFairPlayLicenseProvider()
            fairPlay.customData = item.customData
                
            guard let mSource = self.localAsset.getPreferredDownloadableMediaSource(for: entry) else {
                ZeeUtility.utility.console("No valid source")
                 return
                     }
            self.localAsset.renewDownloadedAsset(location: url, mediaSource: mSource) { (error) in
                    let msg = error == nil ? "Renew Updated" : "Renew Update Error: \(error?.localizedDescription ?? "")"
                    ZeeUtility.utility.console("Error msg: \(msg)")
                    ZeeUtility.utility.console("Error: \(String(describing: error))")
                }
            }
        }
        catch {
            ZeeUtility.utility.console(error.localizedDescription)
        }
    }
    
    /**
     Unregister the content to make unavailable for offline playback
     
     - Parameters:
        - id: Content id of the downloading item.
     
     - Throws: `ZeeError.withError`
                If unable to unregister the content.
     */
    public func unregisterItem(id: String) throws {
        do {
            guard let url = try self.cm?.itemPlaybackUrl(id: id) else {
                ZeeUtility.utility.console("Can't get local url")
                return
            }
            self.localAsset.unregisterDownloadedAsset(location: url) { (error) in
                if error == nil {
                    ZeeUtility.utility.console("Unregistered the content")
                }
            }
        }
        catch {
            let msg = "Unable to unregister the content: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    /**
     Check license expiry date of downloaded item
     
     - Parameters:
        - id: Content id of the downloading item.
     
     - Throws: `ZeeError.withError`
                If unable to get license status of the content.
     
     - Returns: The license expiry date of th e content `Date`.
     */
    public func isVideoExpired(id: String) throws -> Bool? {  // (Date?, Bool?) {
        do {
            guard let url = try self.cm?.itemPlaybackUrl(id: id) else {
                ZeeUtility.utility.console("Can't get local url")
                throw ZeeError.itemNotFound(itemId: id)
            }
            
            guard let exp = self.localAsset.getLicenseExpirationInfo(location: url) else {
                ZeeUtility.utility.console("Check status: Unknown")
                throw ZeeError.itemNotFound(itemId: id)
            }
            
            let expString = DateFormatter.localizedString(from: exp.expirationDate, dateStyle: .long, timeStyle: .long)
            
            if exp.expirationDate < Date() {
                ZeeUtility.utility.console("EXPIRED at \(expString)")
                return true // (exp.expirationDate, true)
            }
            else {
                ZeeUtility.utility.console("VALID until \(expString)")
                return false // (exp.expirationDate, false)
            }
        }
        catch {
            let msg = "Unable to get license status: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    /**
     Remove all the downloaded content
     
     - Throws: `ZeeError.withError`
                If unable to get all removed items.
     
     - Returns: The array of all removed items `[DTGItem]`.
     */
    public func removeAll() throws -> [DTGItem]? {
        
       var AllremovedItems: [DTGItem] = []
    for State in DTGItemState.allCases {
            
        if let allDownloads = try cm?.itemsByState(State) {
                if allDownloads.count > 0 {
                    for item in allDownloads {
                        let id = item.id
                        do {
                            try self.removeDownloadItem(id: id)
                            AllremovedItems.append(item)
                        }
                        catch {
                            continue
                        }
                    }
                }
                else {
                    let msg = "No Items Found In this State"
                    ZeeUtility.utility.console(msg)
                    //throw ZeeError.withError(message: msg)
                }
            }
       }
        if AllremovedItems.count>0 {
            return AllremovedItems
        }
        return nil
    }
    
    /**
     Get all downloaded items
     
     - Throws: `ZeeError.withError`
                If unable to get all downloaded items.
     
     - Returns: The array of all removed items `[DownloadItem]`.
     */
    public func getAllDownloads() throws -> [DownloadDataItem]? {
        do {
            return try self.zeDB?.allItems()
        }
        catch {
            let msg = "Unable to get all downloaded items: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
     /* New Function */
    public func getAllShows() throws -> [DownloadDataItem]? {
        do {
            return try zeDB?.getAllShows()
        }
        catch {
            let msg = "Unable to get all show items: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
     /* New Function */
    public func getAllMovies() throws -> [DownloadDataItem]? {
        do {
            return try zeDB?.getAllMovies()
        }
        catch {
            let msg = "Unable to get all show items: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
     /* New Function */
    public func getAllVideos() throws -> [DownloadDataItem]? {
        do {
            return try zeDB?.getAllVideos()
        }
        catch {
            let msg = "Unable to get all show items: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
     /* New Function */
    public func getEpisodesByShow(showTitle:String) throws -> [DownloadDataItem]? {
        do {
            return try zeDB?.getEpisodes(title: showTitle)
        }
        catch {
            let msg = "Unable to get all show items: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
     /* New Function */
    public func getDownloadsCount() throws -> [String: String]? {
        do {
            return  try zeDB?.getDownloadsCount()
        }
        catch  {
            let msg = "Unable to get Downding count: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    /**
     Get availble video resolution
     
     - Parameters:
        - id: Content id of the downloading item.
     
     - Returns: The video configuration item `Z5VideoConfig`.
     */
    public func getVideoBitrates(contentId: String, contentUrl: String, completion: @escaping (Z5VideoConfig?) -> Void) {
        let url = "https://contentbitrates.zee5.com/v1/workflow"
        guard let serverUrl = URL(string: url) else { return }
        let paramDict = [
            "manifestUrl": contentUrl,
            "content_id": contentId,
            "translation": "en"
        ]
        var request = URLRequest(url: serverUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: paramDict, options: []) else { return }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            ZeeUtility.utility.console("Video-Bitrate- Error: \(String(describing: error?.localizedDescription))")
            guard let data = data else { return }
            do {
                let video = try JSONDecoder().decode(Z5VideoConfig.self, from: data)
                
                if video.download_options != nil {
                    completion(video)
                }
                else {
                    completion(nil)
                }
            } catch let err {
                ZeeUtility.utility.console("getVideoResolution Err: \(err)")
                completion(nil)
            }
            }.resume()
    }
    
    /**
     Setting downloading preference for the content
     
     - Parameters:
        - isWifiOnly: To provide the content to download only in WiFi network.
     */
    public func setNetworkSelection(isWifiOnly: Bool) {
        self.isWifiOnly = isWifiOnly
    }
    
    /**
     Get estimated size of download item
     
     - Parameters:
        - id: Content id of the downloading item.
     
     - Throws: `ZeeError.withError`
                If unable to get estimated size of downloaded item.
     
     - Returns: The estimated size of download item `Int64`.
     */
    public func getDownloadedItemEstiamtedSize(id: String) throws -> Int64? {
        do {
            let item = try self.zeDB?.item(byId: id)
            return Int64(item?.estimatedSize ?? 1)
        }
        catch {
            let msg = "Unable to get estimated size of downloaded item: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    /**
     Get estimated size of download item
     
     - Throws: `ZeeError.withError`
                If unable to get estimated size of all downloaded items.
     
     - Returns: The estimated size of all download items `Int64`.
     */
    public func getAllDownloadedItemsEstimatedSize() throws -> Int64 {
        do {
            let items = try self.zeDB?.allItems()
            
            var itemSize: Int64 = 0
            for item in items ?? [] {
                itemSize = itemSize + Int64(item.estimatedSize)
            }
            return itemSize
        }
        catch {
            let msg = "Unable to get estimated size of all downloaded items: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    /**
    Update offine video played duration
    
    - Throws: `ZeeError.withError`
               If unable to get estimated size of all downloaded items.
    
    - Returns: The estimated size of all download items `Int64`.
    */
    public func updateOfflinePlayingDuration(contentId: String, seconds: Int) throws {
        do {
            try self.zeDB?.updateOfflineVideoDurationInDB(for: contentId, seconds: seconds)
        }
        catch {
            let msg = "Update offline video duration Error: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    public func getVideoPlayedDuration(contentId: String) throws -> Int? {
        do {
            return try self.zeDB?.getOfflineVideoPlayedDuration(for: contentId)
        }
        catch {
            let msg = "Get offline video duration Error: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            throw ZeeError.withError(message: msg)
        }
    }
    
    public func isItemAlreadyDownloaded(contentId: String) throws -> Bool? {
        do {
            let item = try self.zeDB?.item(byId: contentId)
            return item?.contentId == contentId ? true : false
        }
        catch {
            let msg = "Get Item from DB Error: \(error.localizedDescription)"
            ZeeUtility.utility.console(msg)
            return false
        }
    }
}

// MARK:- ContentManager Delegate Method

extension Zee5DownloadManager: ContentManagerDelegate {
    
    // Callback method of current downloading item by data
    public func item(id: String, didDownloadData totalBytesDownloaded: Int64, totalBytesEstimated: Int64?) {
        
        // Send callback to our controller
        self.delegate?.downloadItemWithData(id: id, didDownloadData: totalBytesDownloaded, totalBytesEstimated: totalBytesEstimated)
        
        //
        do {
            try self.zeDB?.updateDownloadSizeInDB(for: id, totalBytes: Int(totalBytesEstimated ?? 0), downloadedBytes: Int(totalBytesDownloaded))
        }
        catch {
            ZeeUtility.utility.console("Update DB Item Error: \(error.localizedDescription)")
        }
        
        //
        DispatchQueue.main.async {
            let data: [String : Any] = [
                DownloadedItemKeys.id: id,
                DownloadedItemKeys.downloadedBytes: totalBytesDownloaded,
                DownloadedItemKeys.estimatedBytes: totalBytesEstimated ?? 0
            ]
            
            NotificationCenter.default.post(name: AppNotification.downloadedItemProgress, object: nil, userInfo: data)
            self.updateProgressBar(contentId: id, downloadedBytes: totalBytesDownloaded, estimatedBytes: totalBytesEstimated)
        }
    }
    
    // Callback method of current downloading item by state
    public func item(id: String, didChangeToState newState: DTGItemState, error: Error?) {
        
        var zeeState: DownloadItemState = .new
        
        switch newState {
        case .new:
            zeeState = .new
        case .metadataLoaded:
            zeeState = .inQueue
        case .inProgress:
            zeeState = .inProgress
        case .paused:
            zeeState = .paused
        case .completed:
            zeeState = .completed

            do {
                try self.renewItem(id: id)
            }
            catch {
                ZeeUtility.utility.console("Renew err: \(error.localizedDescription)")
            }
            
        case .failed:
            zeeState = .failed
            
        case .interrupted:
            zeeState = .interrupted
            
        case .removed:
            zeeState = .removed
            
        case .dbFailure:
            zeeState = .dbFailure
        }
        
        // Send callback to our controller
        self.delegate?.downloadItemWithState(id: id, didChangeToState: zeeState, error: error)
        
        // Db
        do {
            try self.zeDB?.update(itemState: zeeState, byId: id)
        }
        catch {
            ZeeUtility.utility.console("Update Item: \(error.localizedDescription)")
        }
        
        //
        DispatchQueue.main.async {
            let data: [String : Any] = [
                DownloadedItemKeys.id: id,
                DownloadedItemKeys.state: zeeState
            ]
            
            NotificationCenter.default.post(name: AppNotification.downloadedItemState, object: nil, userInfo: data)
        }
        self.updateDownloadStateImage(contentId: id, state: zeeState)
    }
    
    //
    fileprivate func updateDownloadStateImage(contentId: String, state: DownloadItemState) {
        let idx = self.buttonDownlodState.firstIndex { (state) -> Bool in
            return state.accessibilityIdentifier == contentId ? true : false
        }
        if let index = idx {
            let btn = self.buttonDownlodState[index]
            let progress = self.circularRings[index]
            let pause = self.viewPause[index]
            btn.isHidden = true
            progress.isHidden = true
            progress.superview?.isHidden = true
            
            if state == .inProgress {
                progress.isHidden = false
                progress.superview?.isHidden = false
                btn.isHidden = true
                pause.isHidden = true
            }
            else {
                progress.isHidden = true
                progress.superview?.isHidden = true
                btn.isHidden = false
                pause.isHidden = true
                
                let bundle = Bundle(for: DownloadRootController.self)
                if state == .completed {
                    if #available(iOS 13.0, *) {
                        let img = UIImage(named: "complete_download", in: bundle, with: nil)
                        btn.setImage(img, for: .normal)
                    } else {
                        // Fallback on earlier versions
                        let ab = UIImage(named: "complete_download", in: bundle, compatibleWith: nil)
                        btn.setImage(ab, for: .normal)
                    }
                    
                    let dict: [String: Any] = ["contentId": contentId, "state": state]
                    
                    NotificationCenter.default.post(name: AppNotification.stateUpdate, object: dict, userInfo: nil)
                }
                else if state == .failed || state == .interrupted || state == .dbFailure {
                    if #available(iOS 13.0, *) {
                        let img = UIImage(named: "error_download", in: bundle, with: nil)
                        btn.setImage(img, for: .normal)
                    } else {
                        // Fallback on earlier versions
                        let ab = UIImage(named: "error_download", in: bundle, compatibleWith: nil)
                        btn.setImage(ab, for: .normal)
                    }
                }
                else if state == .paused {
                    btn.isHidden = true
                    progress.isHidden = false
                    pause.isHidden = false
                    pause.superview?.isHidden = false
                }
            }
        }
    }
    

    fileprivate func updateProgressBar(contentId: String, downloadedBytes: Int64, estimatedBytes: Int64?) {
    
        let idx = self.circularRings.firstIndex { (ring) -> Bool in
            return ring.accessibilityIdentifier == contentId ? true : false
        }
        if let index = idx {
            let progressRing = self.circularRings[index]
        
            if let estBytes = estimatedBytes {
                if estBytes > downloadedBytes {
                    DispatchQueue.main.async {
                        progressRing.value = (CGFloat(downloadedBytes) / CGFloat(estBytes)) * 100
                    }
                }
                else if downloadedBytes >= estBytes && estBytes > 0 {
                    DispatchQueue.main.async {
                        progressRing.value = 100
                    }
                }
            }
        }
    }
    
    public func setupDownloadProgressBar(contentId: String, progressRing: UICircularProgressRing, imageDownloadState: UIButton, viewPuaseProgress: UIView, downloadedBytes: Int64, estimatedBytes: Int64?) {
     
        progressRing.accessibilityIdentifier = contentId
        self.circularRings.append(progressRing)
        imageDownloadState.accessibilityIdentifier = contentId
        self.buttonDownlodState.append(imageDownloadState)
        viewPuaseProgress.accessibilityIdentifier = contentId
        self.viewPause.append(viewPuaseProgress)
        
        if let estBytes = estimatedBytes {
            if estBytes > downloadedBytes {
                progressRing.value = (CGFloat(downloadedBytes) / CGFloat(estBytes)) * 100
            }
            else if downloadedBytes >= estBytes && estBytes > 0 {
                progressRing.value = 100
            }
        }
    }
}

// MARK:- Helper method for download manager

extension Zee5DownloadManager {
    
    // Helper method to get available space in a device
    fileprivate func getFreeDiskSpaceInBytes() -> Int64? {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            return (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
        }
        catch {
            return 0
        }
    }
}


// MARK:- Helper method for DB operations

extension Zee5DownloadManager {
    
    fileprivate func autoStartContent() {
        do {
            try self.cm?.startItems(inStates: .interrupted)
        }
        catch {
            ZeeUtility.utility.console("autoStartContent Error: \(error.localizedDescription)")
        }
    }
    
    public func addDownloadedItemIntoDB(item: ZeeDownloadItem?) throws {
        if let item = item {
            do {
                try self.zeDB?.add(item: item)
            }
            catch {
                ZeeUtility.utility.console("addDownlodedItem DB Error: \(error.localizedDescription)")
            }
        }
    }
}

extension CGFloat {
    func roundOf() -> CGFloat {
        let divisor = pow(10.0, CGFloat(2))
        return (self * divisor).rounded() / divisor
    }
}

public enum StateDownloading {
    case currentIndex
    case currentValue
    case state
    
    public var description: String {
        switch self {
        case .currentIndex:
            return "currentIndex"
        case .currentValue:
            return "currentValue"
        case .state:
            return "state"
        }
    }
}
