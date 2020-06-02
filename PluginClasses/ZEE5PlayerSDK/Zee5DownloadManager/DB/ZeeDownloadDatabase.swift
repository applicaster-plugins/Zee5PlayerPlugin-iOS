//
//  ZeeDownloadDatabase.swift
//  Zee5DownloadManager
//
//  Created by User on 19/06/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import Foundation
import SQLite
import os.log

class ZeeDownloadDatabase {
    
    // Download Item Table
    let downloadItemTable        = Table("DownloadItemTable")
    let contentId                = Expression<String>("contentId")
    let contentUrl               = Expression<String>("contentUrl")
    let licenseUrl               = Expression<String>("licenseUrl")
    let title                    = Expression<String>("title")
    var imageURL                 = Expression<String>("imageURL")
    var showimgUrl               = Expression<String>("showimgUrl")
    var description              = Expression<String>("description")
    let category                 = Expression<String>("category")
    let episode                  = Expression<String>("episode")
    let base64encodedcertificate = Expression<String>("base64encodedcertificate")
    let customData               = Expression<String>("customData")
    let estimatedSize            = Expression<Int>("estimatedSize")
    let downloadedSize           = Expression<Int>("downloadedSize")
    let isDrmRegistered          = Expression<Bool>("isDrmRegistered")
    let isDrmProtected           = Expression<Bool>("isDrmProtected")
    let destinationUrl           = Expression<String>("destinationUrl")
    let localThumbnailUrl        = Expression<String>("localThumbnailUrl")
    var itemStatus               = Expression<String>("item_status")
    var expiryTime               = Expression<Int64>("expiryTime")
    //
    var assetType                = Expression<String>("assetType")
    var assetSubType             = Expression<String>("assetSubType")
    var episodeNumber            = Expression<Int>("episodeNumber")
    var duration                 = Expression<Int>("duration")
    var offlinePlayingDuration   = Expression<Int>("offlinePlayingDuration")
    var Agerating                = Expression<String>("Agerating")
    
    //
    var showOriginalTitle        = Expression<String>("showOriginalTitle")
    
    // DownloadItemTask Table
    let downloadTaskTable       = Table("DownloadItemTaskTable")
    let taskId                  = Expression<Int64>("id")
    let taskContentId           = Expression<String>("task_content_id")
    let taskContentURL          = Expression<String>("task_content_url")
    let taskItemType            = Expression<String>("item_type")
    let taskItemDestinationURL  = Expression<String>("item_destination_url")
    let taskItemResumeData      = Expression<String>("item_resume_data")
    
    let titleCount              = Expression<Int>("count(\\title\\)")
    let totalSize               = Expression<Int>("sum(\\downloadedSize\\)")
}

// MARK:- DB API - DownloadItemTable

extension ZeeDownloadDatabase {
    
    func createDownloadItemTable() -> Bool {
        var isTableCreated : Bool = true
        do {
            try db.run(downloadItemTable.create(ifNotExists: true) { t in
                t.column(contentId, unique: true)
                t.column(contentUrl)
                t.column(licenseUrl)
                t.column(title)
                t.column(imageURL)
                t.column(showimgUrl)
                t.column(description)
                t.column(category)
                t.column(episode)
                t.column(base64encodedcertificate)
                t.column(customData)
                t.column(estimatedSize)
                t.column(downloadedSize)
                t.column(isDrmRegistered)
                t.column(isDrmProtected)
                t.column(destinationUrl)
                t.column(localThumbnailUrl)
                t.column(itemStatus)
                t.column(expiryTime)
                t.column(assetType)
                t.column(assetSubType)
                t.column(episodeNumber)
                t.column(duration)
                t.column(offlinePlayingDuration)
                t.column(Agerating)
                t.column(showOriginalTitle)
            })
        } catch {
            isTableCreated = false
        }
        return isTableCreated
    }
    
    func insertIntoDownloadItemTable(downloadItem: ZeeDownloadItem) throws -> Bool {
        var isInserted: Bool = true
        do {
            let insert = downloadItemTable.insert(contentId <- downloadItem.contentId,
                                                  contentUrl <- downloadItem.contentUrl,
                                                  licenseUrl <- downloadItem.licenseUrl,
                                                  title <- downloadItem.title,
                                                  imageURL <- downloadItem.imageURL,
                                                  showimgUrl <- downloadItem.showimgUrl,
                                                  description <- downloadItem.description,
                                                  category <- downloadItem.category,
                                                  episode <- downloadItem.episode,
                                                  base64encodedcertificate <- downloadItem.base64encodedcertificate,
                                                  customData <- downloadItem.customData,
                                                  estimatedSize <- Int(downloadItem.estimatedSize),
                                                  downloadedSize <- Int(downloadItem.downloadedSize),
                                                  isDrmRegistered <- downloadItem.isDrmRegistered,
                                                  isDrmProtected <- downloadItem.isDrmProtected,
                                                  destinationUrl <- downloadItem.destinationUrl,
                                                  localThumbnailUrl <- downloadItem.localThumbnailUrl,
                                                  itemStatus <- downloadItem.state.asString(),
                                                  expiryTime <- downloadItem.expiryTime,
                                                  assetType <- downloadItem.assetType,
                                                  assetSubType <- downloadItem.assetSubType,
                                                  episodeNumber <- downloadItem.episodeNumber,
                                                  duration <- downloadItem.duration,
                                                  offlinePlayingDuration <- downloadItem.offlinePlayingDuration,
                                                  Agerating <- downloadItem.Agerating,
                                                  showOriginalTitle <- downloadItem.showOriginalTitle)
            _ = try db.run(insert)
            
        } catch {
            isInserted = false
            throw error
        }
        
        return isInserted
    }
    
    func itemById(id: String) throws -> ZeeDownloadItem {
        do {
            for row in try db.prepare(downloadItemTable) {
                if row[contentId] == id {
                    let item = self.createDownloadItem(itemRow: row)
                    return item
                }
            }
        }
        catch {
            throw ZeeError.itemNotFound(itemId: id)
        }
        throw ZeeError.itemNotFound(itemId: id)
    }
    
    func deleteItemById(id: String) throws {
        do {
            let item = downloadItemTable.filter(contentId == id)
            try db.run(item.delete())
        } catch {
            throw ZeeError.unableToCancel(itemId: id)
        }
    }
    
    func updateItem(item: ZeeDownloadItem) throws {
        
        let item1 = downloadItemTable.filter(contentId == item.contentId)
        
        let update_query = item1.update(contentId <- item.contentId,
                                         contentUrl <- item.contentUrl,
                                         licenseUrl <- item.licenseUrl,
                                         title <- item.title,
                                         imageURL <- item.imageURL,
                                         showimgUrl <- item.showimgUrl,
                                         description <- item.description,
                                         category <- item.category,
                                         episode <- item.episode,
                                         base64encodedcertificate <- item.base64encodedcertificate,
                                         customData <- item.customData,
                                         estimatedSize <- Int(item.estimatedSize),
                                         downloadedSize <- Int(item.downloadedSize),
                                         isDrmProtected <- item.isDrmProtected,
                                         isDrmRegistered <- item.isDrmRegistered,
                                         destinationUrl <- item.destinationUrl,
                                         localThumbnailUrl <- item.localThumbnailUrl,
                                         itemStatus <- item.state.asString(),
                                         localThumbnailUrl <- item.localThumbnailUrl,
                                         assetType <- item.assetType,
                                         assetSubType <- item.assetSubType,
                                         episodeNumber <- item.episodeNumber,
                                         duration <- item.duration,
                                         offlinePlayingDuration <- item.offlinePlayingDuration,
                                         Agerating <- item.Agerating,
                                         showOriginalTitle <- item.showOriginalTitle)
        
        do {
            try db?.run(update_query)
        } catch {
            throw error
        }
    }
    
    func update(itemState: DownloadItemState, byId id: String) throws {
        let item1 = downloadItemTable.filter(contentId == id)
        let update_query = item1.update(itemStatus <- itemState.asString())
        do {
            try db?.run(update_query)
        } catch {
            throw error
        }
    }
    
    func updateItemById(id: String, status: String) throws {
        do {
            let item = downloadItemTable.filter(contentId == id)
            try db.run(item.update(itemStatus <- status))
        } catch {
            throw error
        }
    }
    
    func updateItemByDownloadSize(id: String, totalSize: Int) throws {
        do {
            let item = downloadItemTable.filter(contentId == id)
            try db.run(item.update(estimatedSize <- totalSize))
        }
        catch {
            throw error
        }
    }
    
    ///
    func updateDownloadSizeInDB(for id: String, totalBytes: Int, downloadedBytes: Int) throws {
        let item = downloadItemTable.filter(contentId == id)
        let update = item.update(estimatedSize <- totalBytes,
                                 downloadedSize <- downloadedBytes)
        do {
            try db.run(update)
        }
        catch {
            throw error
        }
    }
    
    func getAllDownloadItems() throws -> [ZeeDownloadItem] {
        do{
            var downloadItems = [ZeeDownloadItem]()
            for row in try db.prepare(downloadItemTable) {
                downloadItems.append(self.createDownloadItem(itemRow: row))
            }
            return downloadItems
        } catch {
            throw error
        }
    }
    
     /* New Function */
    func getAllEpisodesByShow(showTitle:String) throws -> [ZeeDownloadItem]{
        do {
            var downloadItems = [ZeeDownloadItem]()
            let filterResult = downloadItemTable.filter(showOriginalTitle == showTitle)
            for row in try db.prepare(filterResult){
                downloadItems.append(self.createDownloadItem(itemRow: row))
            }
            return downloadItems
        } catch  {
            throw error
        }
    }
    
    /* New Function */
    func getMovies() throws -> [ZeeDownloadItem] {
        do {
            var downloadItems = [ZeeDownloadItem]()
            let filterResult = downloadItemTable.filter(self.assetSubType == "movie")
            for row in try db.prepare(filterResult) {
                downloadItems.append(self.createDownloadItem(itemRow: row))
            }
            return downloadItems
        } catch {
            throw error
        }
    }
    
    func getVideos() throws -> [ZeeDownloadItem] {
        do {
            var downloadItems = [ZeeDownloadItem]()
            let filterResult = downloadItemTable.filter((self.assetSubType != "movie" && self.assetSubType != "tvshow" && self.assetSubType != "episode"))
            for row in try db.prepare(filterResult) {
                downloadItems.append(self.createDownloadItem(itemRow: row))
            }
            return downloadItems
        } catch {
            throw error
        }
    }
    
    /* New Function */ //getShows - filter by asserttype ="1" groupby title
    func getShows() throws -> [ZeeDownloadItem] {
        do{
            var downloadItems = [ZeeDownloadItem]()
            let filterResult = downloadItemTable.filter(self.assetType == "1").group(showOriginalTitle)
            
            for row in try db.prepare(filterResult) {
                downloadItems.append(self.createDownloadItem(itemRow: row))
            }
            return downloadItems
        } catch {
            throw error
        }
    }
    /* New Function */ //getShows - filter by asserttype ="1" groupby title, episodes, downloadSize
    func getAllShows() throws -> [ZeeDownloadItem] {
        do{
            var downloadItems = [ZeeDownloadItem]()
            var tmp : ZeeDownloadItem
            for row in try db.prepare("SELECT showOriginalTitle,imageURL,showimgUrl,count(title),sum(estimatedSize),assetType, contentId, assetSubType FROM DownloadItemTable WHERE (assetType = '1') GROUP BY showOriginalTitle") {
                tmp = ZeeDownloadItem()
                tmp.showOriginalTitle = row[0] as! String
                tmp.imageURL = row[1] as! String
                tmp.showimgUrl = row[2] as! String
                tmp.episode = String(row[3] as!  Int64)
                tmp.downloadedSize = Int(row[4] as! Int64)
                tmp.assetType = row[5] as! String
                tmp.contentId = row[6] as! String
                tmp.assetSubType = row[7] as! String
                downloadItems.append(tmp)
            }
            return downloadItems
        } catch {
            throw error
        }
    }
    
    func getDownloadsCount() throws -> [String: String] {
        do {
            var dict: [String: String] = [:]
            var count: String
            var tmp: ZeeDownloadItem
            for row in try db.prepare("SELECT showOriginalTitle,showimgUrl,count(item_status) FROM DownloadItemTable WHERE assetType == 1 and item_status in ('inProgress','inQueue','paused') GROUP BY showOriginalTitle ") {
                tmp = ZeeDownloadItem()
                tmp.showOriginalTitle = row[0] as! String
                tmp.showimgUrl = row[1] as! String
                count =  String(row[2] as! Int64)
                dict = [tmp.showOriginalTitle: count]
            }
            return dict
        }
        catch {
            throw error
        }
    }
    
    func createDownloadItem(itemRow: Row) -> ZeeDownloadItem  {
        
        let item = ZeeDownloadItem()
        item.contentId = itemRow[contentId]
        item.contentUrl = itemRow[contentUrl]
        item.licenseUrl = itemRow[licenseUrl]
        item.Agerating = itemRow[Agerating]
        item.title = itemRow[title]
        item.imageURL = itemRow[imageURL]
        item.showimgUrl = itemRow[showimgUrl]
        item.info = itemRow[description]
        item.category = itemRow[category]
        item.episode = itemRow[episode]
        item.base64encodedcertificate = itemRow[base64encodedcertificate]
        item.customData = itemRow[customData]
        item.downloadedSize = itemRow[downloadedSize]
        item.estimatedSize = itemRow[estimatedSize]
        item.isDrmRegistered = itemRow[isDrmRegistered]
        item.isDrmProtected = itemRow[isDrmProtected]
        item.destinationUrl = itemRow[destinationUrl]
        item.localThumbnailUrl = itemRow[localThumbnailUrl]
        item.state = DownloadItemState(value: itemRow[itemStatus]) ?? DownloadItemState.new
        item.expiryTime = itemRow[expiryTime]
        item.assetType = itemRow[assetType]
        item.assetSubType = itemRow[assetSubType]
        item.episodeNumber = itemRow[episodeNumber]
        item.duration = itemRow[duration]
        item.showOriginalTitle = itemRow[showOriginalTitle]
        item.offlinePlayingDuration = itemRow[offlinePlayingDuration]
        return item
    }
    
    func updateOfflineVideoDuration(for id: String, seconds: Int) throws {
        let item = downloadItemTable.filter(contentId == id)
        let update = item.update(offlinePlayingDuration <- seconds)
        do {
            try db.run(update)
        }
        catch {
            throw error
        }
    }
    
    func getOfflineVideoDuration(for id: String) throws -> Int {
        do {
            for row in try db.prepare(downloadItemTable) {
                if row[contentId] == id {
                    let item = self.createDownloadItem(itemRow: row)
                    return item.offlinePlayingDuration
                }
            }
        }
        catch {
            throw ZeeError.itemNotFound(itemId: id)
        }
        throw ZeeError.itemNotFound(itemId: id)
    }
}

/************************************************************/
// MARK: - DB API - DownloadTaskTable
/************************************************************/

extension ZeeDownloadDatabase {
    
    func createDownloadItemTaskTable() -> Bool {
        var isTableCreated : Bool = true
        do {
            try db.run(downloadTaskTable.create(ifNotExists: true) { t in
                t.column(taskContentId)
                t.column(taskContentURL)
                t.column(taskItemType)
                t.column(taskItemDestinationURL)
                t.column(taskItemResumeData)
                t.primaryKey(taskContentId, taskContentURL)
            })
        } catch {
            os_log("Error creating download item task table." , type: .debug)
            isTableCreated = false
        }
        return isTableCreated
    }
    
    func insertIntoDownloadItemTask(task: ZeeDownloadItemTask) throws -> Bool {
        let isInserted : Bool = true
        do {
            let insert = downloadTaskTable.insert(taskContentId <- task.itemId,
                                                  taskContentURL <- task.contentUrl.absoluteString,
                                                  taskItemType <- task.type.asString(),
                                                  taskItemDestinationURL <- task.destinationUrl.absoluteString,
                                                  taskItemResumeData <- "")
            
            _ = try db.run(insert)
        } catch let Result.error(_, code, _) where code == 19 {
            // if UNIQUE constraint failed: license url -> do nothing and continue
        } catch {
            try self.deleteTaskById(id: task.itemId)
            try self.deleteItemById(id: task.itemId)
            throw error
        }
        return isInserted
    }
    
    func set(tasks: [ZeeDownloadItemTask]) throws {
        for task in tasks {
            _ = try self.insertIntoDownloadItemTask(task: task)
        }
    }
    
    func findTasksById(id: String) throws -> [ZeeDownloadItemTask] {
        do{
            var tasks = [ZeeDownloadItemTask]()
            for row in try db.prepare(downloadTaskTable) {
                if (row[contentId] == id) {
                    tasks.append(self.createDownloadItemTask(itemRow: row))
                }
            }
            return tasks
        } catch {
            throw error
        }
    }
    
    func deleteTaskById( id : String) throws {
        do {
            let itemTasks = downloadTaskTable.filter(taskContentId == id)
            try db.run(itemTasks.delete())
        } catch {
            throw error
        }
    }
    
    func updateByTask(tasks: [ZeeDownloadItemTask]) throws {
        for t in tasks {
            var resumedata = ""
            if t.resumeData != nil {
                resumedata = self.convertDataIntoString(data: t.resumeData!)
            }
            let new_task = downloadTaskTable.filter(taskContentURL == t.contentUrl.absoluteString)
            let update_query = new_task.update(taskContentId <- t.itemId,
                                               taskContentURL <- t.contentUrl.absoluteString,
                                               taskItemType <- t.type.asString(),
                                               taskItemDestinationURL <- t.destinationUrl.absoluteString,
                                               taskItemResumeData <- resumedata)
            
            try db?.run(update_query)
        }
    }
    
    func remove(tasks: [ZeeDownloadItemTask]) throws {
        for t in tasks {
            let task = downloadTaskTable.filter(taskContentURL == t.contentUrl.absoluteString)
            try db?.run(task.delete())
        }
    }
    
    func createDownloadItemTask(itemRow: Row) -> ZeeDownloadItemTask {
        
        let itemId = itemRow[taskContentId]
        let contentUrl = URL(string: itemRow[taskContentURL])!
        let destinationUrl = URL(string: itemRow[taskItemDestinationURL])!
        let type = ZeeDownloadItemTaskType.init(type: itemRow[taskItemType])!
        
        var task = ZeeDownloadItemTask(itemId: itemId, contentUrl: contentUrl, type: type, destinationUrl: destinationUrl)
        if itemRow[taskItemResumeData] != "" {
            let resumeData =  self.convertStringIntoData(text: itemRow[taskItemResumeData])
            task.resumeData = resumeData
        }
        return task
    }
    
    // MARK:- DB utilities
    func convertDataIntoString(data: Data) -> String {
        return String(decoding: data, as: UTF8.self)
    }
    
    func convertStringIntoData(text: String) -> Data {
        return text.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
    }
}
