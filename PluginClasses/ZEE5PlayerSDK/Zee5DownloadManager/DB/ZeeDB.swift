//
//  ZeeDB.swift
//  Zee5DownloadManager
//
//  Created by User on 19/06/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import Foundation
import SQLite
import os.log

var db: Connection! = nil

// returns a configured realm object.
func getZeeDB() throws -> Bool {
    return initializeDB()
}

func initializeDB() -> Bool {
    var isInitialized = true
    do {
        let fileURL = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("ZeeDownloadmanager.sqlite3")
        db = try Connection(fileURL.absoluteString)
    } catch {
        isInitialized = false
    }
    return isInitialized
}

protocol DB: class {
    
    // Items API
    
    func update(item: ZeeDownloadItem) throws
    func item(byId id: String) throws -> ZeeDownloadItem?
    func removeItem(byId id: String) throws
    func allItems() throws -> [ZeeDownloadItem]
    
    func items(byState state: DownloadItemState) throws -> [ZeeDownloadItem]
    func update(itemState: DownloadItemState, byId id: String) throws
    
    func updateItemByDownloadSize(id: String, totalSize: Int) throws
    
    ///
    func updateDownloadSizeInDB(for id: String, totalBytes: Int, downloadedBytes: Int) throws
    
    // Tasks API
    func set(tasks: [ZeeDownloadItemTask]) throws
    func tasks(forItemId id: String) throws -> [ZeeDownloadItemTask]
    func removeTasks(withItemId id: String) throws
    func remove(_ tasks: [ZeeDownloadItemTask]) throws
    func update(_ tasks: [ZeeDownloadItemTask]) throws
}

class ZeeDB: DB {
    
    fileprivate let zeeDownloadDatabase = ZeeDownloadDatabase()
    init() {}
}

/************************************************************/
// MARK: - DB API - Items
/************************************************************/

extension ZeeDB {
    
    func createTable(){
        _ = self.zeeDownloadDatabase.createDownloadItemTable()
        _ = self.zeeDownloadDatabase.createDownloadItemTaskTable()
    }
    
    func add(item: ZeeDownloadItem) throws {
        try db?.transaction {
            _ = try self.zeeDownloadDatabase.insertIntoDownloadItemTable(downloadItem: item)
        }
    }
    
    func update(item: ZeeDownloadItem) throws {
        try db?.transaction {
            try self.zeeDownloadDatabase.updateItem(item: item)
        }
    }
    
    func item(byId id: String) throws -> ZeeDownloadItem? {
        return try self.zeeDownloadDatabase.itemById(id:id)
    }
    
    func allItems() throws -> [ZeeDownloadItem] {
        return try self.zeeDownloadDatabase.getAllDownloadItems()
    }
    
    /* New Function - This method is for fetching movies etc., */
    func getAllMovies() throws -> [ZeeDownloadItem] {
        return try self.zeeDownloadDatabase.getMovies()
    }
    
    /* New Function - This method is for fetching videos, other etc., */
    func getAllVideos() throws -> [ZeeDownloadItem] {
        return try self.zeeDownloadDatabase.getVideos()
    }
    
    /* New Function - This method is for fetching episodes etc. */
    func getEpisodes(title: String) throws -> [ZeeDownloadItem] {
        return try zeeDownloadDatabase.getAllEpisodesByShow(showTitle: title )
    }
    
    func getAllShows() throws -> [ZeeDownloadItem] {
        return try zeeDownloadDatabase.getAllShows()
    }
    
    func getDownloadsCount() throws -> [String: String] {
        return try zeeDownloadDatabase.getDownloadsCount()
    }
    
    func items(byState state: DownloadItemState) throws -> [ZeeDownloadItem] {
        var items = [ZeeDownloadItem]()
        for item in try self.allItems() {
            if item.state == state {
                items.append(item)
            }
        }
        return items
    }
    
    func update(itemState: DownloadItemState, byId id: String) throws {
        try self.zeeDownloadDatabase.update(itemState: itemState, byId: id)
    }
    
    func removeItem(byId id: String) throws {
        try db?.transaction {
            try self.zeeDownloadDatabase.deleteTaskById(id: id)
            try self.zeeDownloadDatabase.deleteItemById(id: id)
        }
    }
    
    func updateItemByDownloadSize(id: String, totalSize: Int) throws {
        try self.zeeDownloadDatabase.updateItemByDownloadSize(id: id, totalSize: totalSize)
    }
    
    //
    func updateDownloadSizeInDB(for id: String, totalBytes: Int, downloadedBytes: Int) throws {
        try self.zeeDownloadDatabase.updateDownloadSizeInDB(for: id, totalBytes: totalBytes, downloadedBytes: downloadedBytes)
    }
    
    func updateOfflineVideoDurationInDB(for id: String, seconds: Int) throws {
        try self.zeeDownloadDatabase.updateOfflineVideoDuration(for: id, seconds: seconds)
    }
    
    func getOfflineVideoPlayedDuration(for id: String) throws -> Int {
        return try self.zeeDownloadDatabase.getOfflineVideoDuration(for: id)
    }
}

/************************************************************/
// MARK: - DB API - Tasks
/************************************************************/

extension ZeeDB {
    
    func set(tasks: [ZeeDownloadItemTask]) throws {
        try db?.transaction {
            try self.zeeDownloadDatabase.set(tasks: tasks)
        }
    }
    
    func tasks(forItemId id: String) throws -> [ZeeDownloadItemTask] {
        return try self.zeeDownloadDatabase.findTasksById(id: id)
    }
    
    func removeTasks(withItemId id: String) throws {
        try db?.transaction {
            try self.zeeDownloadDatabase.deleteTaskById(id: id)
        }
    }
    
    func remove(_ tasks: [ZeeDownloadItemTask]) throws {
        try self.zeeDownloadDatabase.remove(tasks: tasks)
    }
    
    func update(_ tasks: [ZeeDownloadItemTask]) throws {
        try db?.transaction {
            try self.zeeDownloadDatabase.updateByTask(tasks: tasks)
        }
    }
}
