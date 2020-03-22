//
//  ZeeDownloadContent.swift
//  Zee5DownloadManager
//
//  Created by User on 20/06/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit
import Foundation

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

fileprivate func == <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l == r
    default:
        return false
    }
}

/************************************************************/
// MARK: - ZeeDownloadContentDelegate protocols
/************************************************************/

protocol ZeeDownloadContentDelegate: class {
    
    /** A delegate method called each time whenever any download task's progress is updated
     */
    func downloadRequestDidUpdateProgress(_ downloadModel: ZeeDownloadModel, bytesWritten : Int64)
    /** A delegate method called when interrupted tasks are repopulated
     */
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModel: [ZeeDownloadModel])
    /** A delegate method called each time whenever new download task is start downloading
     */
    func downloadRequestStarted(_ downloadModel: ZeeDownloadModel, bytesWritten: Int64)
    /** A delegate method called each time whenever running download task is paused. If task is already paused the action will be ignored
     */
    func downloadRequestDidPaused(_ downloadModel: ZeeDownloadModel, didPauseDownloadTasks tasks: [ZeeDownloadItemTask])
    /** A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
     */
    func downloadRequestDidResumed(_ downloadModel: ZeeDownloadModel)
    /** A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
     */
    func downloadRequestDidRetry(_ downloadModel: ZeeDownloadModel)
    /** A delegate method called each time whenever any download task is cancelled by the user
     */
    func downloadRequestCanceled(_ downloadModel: ZeeDownloadModel)
    /** A delegate method called each time whenever any download task is finished successfully
     */
    func downloadRequestFinished(_ downloadModel: ZeeDownloadModel, didFinishDownloading ZeeDownloadItemTask: ZeeDownloadItemTask)
    /** A delegate method called each time whenever any download task is failed due to any reason
     */
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: ZeeDownloadModel)
    /** A delegate method called each time whenever specified destination does not exists. It will be called on the session queue. It provides the opportunity to handle error appropriately
     */
    func downloadRequestDestinationDoestNotExists(_ downloadModel: ZeeDownloadModel, location: URL)
    /** A delegate method called each time whenever thumbnail image is downloaded successfully
     */
    func downloadRequestForThumbnailFinished(downloadItemTask : ZeeDownloadItemTask)
    
}

/************************************************************/
// MARK: - ZeeDownloadContent
/************************************************************/

class ZeeDownloadContent: NSObject {
    
    fileprivate var sessionManager: URLSession!
    
    var backgroundSessionCompletionHandler: (() -> Void)? {
        didSet {
            if backgroundSessionCompletionHandler != nil {
                self.downloadNextTasks()
            }
        }
    }
    
    fileprivate weak var delegate: ZeeDownloadContentDelegate?
    
    var pausedTasks = [ZeeDownloadItemTask]()
    
    /// Queue for holding all the download tasks (FIFO)
    fileprivate var ZeeDownloadItemTasksQueue = ZeeQueue<ZeeDownloadItemTask>()
    var downloadModel : ZeeDownloadModel!
    /// Holds all the active downloads map of session task and the corresponding download task.
    fileprivate var activeDownloads = [URLSessionDownloadTask: ZeeDownloadItemTask]()
    
    fileprivate let syncQue = DispatchQueue(label: "synchronizedQueue")
    
    fileprivate var downloadingTaskCnt: Int {
        return syncQue.sync {
            return self.activeDownloads.count
        }
    }
    
    let maxConcurrentDownlaodTasksCnt: Int = 4
    
    var sessionIdentifier : String!
    
    public convenience init( delegate: ZeeDownloadContentDelegate, sessionConfiguration: URLSessionConfiguration? = nil, completion: (() -> Void)? = nil) {
        self.init()
        self.delegate = delegate
        self.sessionIdentifier = "ZeeDownloadManager-" + UUID().uuidString
        self.setBackgroundURLSession()
    }
    
    deinit {
        self.invokeBackgroundSessionCompletionHandler()
    }
    
    func setBackgroundURLSession() {
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: self.sessionIdentifier)
        // initialize download url session with background configuration
        self.sessionManager = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: nil)
    }
    
    public class func defaultSessionConfiguration(identifier: String) -> URLSessionConfiguration {
        return URLSessionConfiguration.background(withIdentifier: identifier)
    }
    
    fileprivate func backgroundSession(identifier: String, configuration: URLSessionConfiguration? = nil) -> URLSession {
        let sessionConfiguration = configuration ?? ZeeDownloadContent.defaultSessionConfiguration(identifier: identifier)
        assert(identifier == sessionConfiguration.identifier, "Configuration identifiers do not match")
        let session = Foundation.URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        return session
    }
}

/************************************************************/
// MARK: - URLSessionDownloadDelegate
/************************************************************/
extension ZeeDownloadContent: URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if self.downloadModel != nil {
            self.downloadModel.downloadedSize += bytesWritten
            if self.downloadModel.status == ZeeTaskStatus.downloading.description() {
                self.delegate?.downloadRequestDidUpdateProgress(downloadModel, bytesWritten: bytesWritten)
            }
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let downloadItemTask = self.activeDownloads[downloadTask] else {
            return
        }
        
        let fileManager : FileManager = FileManager.default
        
        do {
            // if the file exists for some reason, rewrite it.
            if fileManager.fileExists(atPath: downloadItemTask.destinationUrl.path) {
                try fileManager.removeItem(at: downloadItemTask.destinationUrl)
            }
            try fileManager.moveItem(at: location, to: downloadItemTask.destinationUrl)
            
            if downloadItemTask.type == ZeeDownloadItemTaskType.image {
                self.delegate?.downloadRequestForThumbnailFinished(downloadItemTask: downloadItemTask)
                return
            }
            
            // remove the download task from the active downloads
            self.activeDownloads[downloadTask] = nil
            
            if (self.activeDownloads.count <= 0 && self.ZeeDownloadItemTasksQueue.count <= 0) {
                downloadModel.status = ZeeTaskStatus.completed.description()
            }
            self.delegate?.downloadRequestFinished(downloadModel, didFinishDownloading: downloadItemTask)
            
        } catch {
            
        }
        
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        self.downloadNextTasks()
        if self.activeDownloads.count == 0 && self.ZeeDownloadItemTasksQueue.count == 0 {
            self.invokeBackgroundSessionCompletionHandler()
        }
    }
}

/************************************************************/
// MARK: - URLSessionDelegate
/************************************************************/
extension ZeeDownloadContent : URLSessionDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        let t = activeDownloads[(task as? URLSessionDownloadTask)!]
        // if task was for downloading thumbnail image
        guard t?.type != ZeeDownloadItemTaskType.image else { return }
        
        if let e = error as NSError?, let downloadTask = task as? URLSessionDownloadTask {
            
            // if cancelled no need to handle error
            guard e.code != NSURLErrorCancelled else { return }
            
            // if http response type and error code is 503 retry
            if let httpResponse = task.response as? HTTPURLResponse {
                if httpResponse.statusCode >= 500 {
                    retryDownloadTask(downloadTask: downloadTask, receivedError: error)
                } else {
                    cancel(with: e)
                }
            } else {
                if let resumeData = e.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
                    retryDownloadTask(downloadTask: downloadTask, resumeData: resumeData, receivedError: e)
                } else {
                    retryDownloadTask(downloadTask: downloadTask)
                }
                return
            }
        }
        
        if activeDownloads.count == 0 && self.ZeeDownloadItemTasksQueue.count == 0 {
            self.downloadModel.status = ZeeTaskStatus.completed.description()
            self.invokeBackgroundSessionCompletionHandler()
        } else {
            // take next task if available
            self.downloadNextTasks()
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let e = error {
            self.failed(with: e)
        }
    }
}

/************************************************************/
// MARK: - Private Implementation
/************************************************************/
private extension ZeeDownloadContent {
    
    func invokeBackgroundSessionCompletionHandler() {
        if let backgroundSessionCompletionHandler = self.backgroundSessionCompletionHandler {
            self.backgroundSessionCompletionHandler = nil
            DispatchQueue.main.async {
                backgroundSessionCompletionHandler()
            }
        }
    }
    
    func cancel(with error: Error? = nil) {
        if self.downloadModel.status == ZeeTaskStatus.cancelled.description() {
            return
        }
        // Invalidate the session before canceling, so that no new tast will start
        self.invalidateSession()
        self.cancelDownload()
        self.downloadModel.status = ZeeTaskStatus.cancelled.description()
        if let e = error {
            self.failed(with: e)
        }
    }
    
    func retryDownloadTask(downloadTask: URLSessionDownloadTask, resumeData: Data? = nil, receivedError error: Error? = nil) {
        if var downloadItemTask = self.activeDownloads[downloadTask], downloadItemTask.retry > 0 {
            downloadItemTask.retry -= 1
            downloadItemTask.resumeData = resumeData
            self.ZeeDownloadItemTasksQueue.enqueueAtHead(downloadItemTask)
            self.activeDownloads[downloadTask] = nil
            return
        } else {
            cancel(with: error)
        }
    }
    
    func failed(with error: Error) {
        self.invokeBackgroundSessionCompletionHandler()
        self.delegate?.downloadRequestDidFailedWithError(error as NSError, downloadModel: self.downloadModel)
    }
    
    func downloadNextTasks() {
        
        if self.downloadingTaskCnt < self.maxConcurrentDownlaodTasksCnt && self.ZeeDownloadItemTasksQueue.count > 0 {
            repeat {
                guard let downloadTask = self.ZeeDownloadItemTasksQueue.dequeue() else { continue }
                self.start(downloadTask: downloadTask)
            } while self.downloadingTaskCnt < self.maxConcurrentDownlaodTasksCnt && self.ZeeDownloadItemTasksQueue.count > 0
        }
        
    }
    
    func start(downloadTask: ZeeDownloadItemTask) {
        
        let request = URLRequest(url: downloadTask.contentUrl)
        if sessionManager == nil {
            self.setBackgroundURLSession()
        }
        var urlSessionDownloadTask : URLSessionDownloadTask!
        
        if let resumedata = downloadTask.resumeData {
            urlSessionDownloadTask = sessionManager.downloadTask(withResumeData: resumedata)
        }
        else{
            urlSessionDownloadTask = sessionManager.downloadTask(with: request)
        }
        
        if self.downloadModel.itemId == downloadTask.itemId {
            self.activeDownloads[urlSessionDownloadTask] = downloadTask
            
            urlSessionDownloadTask.resume()
            
        }
    }
}


/************************************************************/
// MARK: - Public helper Implementation
/************************************************************/
extension ZeeDownloadContent {
    
    func startDownloadThumbnail(url: URL, task: ZeeDownloadItemTask) {
        let request = URLRequest(url: url)
        if sessionManager == nil {
            self.setBackgroundURLSession()
        }
        var urlSessionDownloadTask : URLSessionDownloadTask!
        
        urlSessionDownloadTask = sessionManager.downloadTask(with: request)
        self.activeDownloads[urlSessionDownloadTask] = task
        
        urlSessionDownloadTask.resume()
    }
    
    func startDownloadTasks(itemId: String, tasks: [ZeeDownloadItemTask], url : String, downloadPath : String, fileSize : Int64) {
        self.ZeeDownloadItemTasksQueue.enqueue(tasks)
        downloadModel = ZeeDownloadModel.init(itemId:itemId, fileName: itemId, fileURL: url, destinationPath: downloadPath, fileSize : fileSize)
        downloadModel.startTime = Date()
        downloadModel.status = ZeeTaskStatus.downloading.description()
        self.downloadNextTasks()
    }
    
    public func resumeDownload() {
        
        if self.downloadModel.status == ZeeTaskStatus.paused.description() {
            self.ZeeDownloadItemTasksQueue.enqueue(pausedTasks)
            self.setBackgroundURLSession()
            downloadModel.status = ZeeTaskStatus.downloading.description()
            
            self.downloadNextTasks()
            delegate?.downloadRequestDidResumed(self.downloadModel)
        }
    }
    
    
    public func pauseDownload(){
        
        // Make sure to wait for all active downloads to pause by using dispatch queue wait.
        let dispatchGroup = DispatchGroup()
        for (_, _) in self.activeDownloads {
            dispatchGroup.enter()
        }
        for (sessionTask, downloadTask) in self.activeDownloads {
            var downloadTask = downloadTask
            
            sessionTask.cancel(byProducingResumeData: {
                (data) in
                downloadTask.resumeData = data
                self.pausedTasks.append(downloadTask)
                dispatchGroup.leave()
            })
        }
        
        // Waits for all active download tasks to cancel
        dispatchGroup.notify(queue: DispatchQueue.global()) {
            self.invalidateSession()
            self.ZeeDownloadItemTasksQueue.purge()
            self.activeDownloads.removeAll()
            self.downloadModel.status = ZeeTaskStatus.paused.description()
            self.downloadModel.startTime = Date()
            self.delegate?.downloadRequestDidPaused(self.downloadModel, didPauseDownloadTasks: self.pausedTasks)
        }
    }
    
    public func retryDownloadTaskAtIndex(_ index: Int) {
        guard self.downloadModel.status != ZeeTaskStatus.downloading.description() else {
            return
        }
        let downloadtasks = downloadModel.tasks
        for task in downloadtasks! {
            if self.activeDownloads[task] != nil {
                task.resume()
            }
        }
        self.downloadModel.status = ZeeTaskStatus.downloading.description()
        self.downloadModel.startTime = Date()
    }
    
    public func cancelDownload() {
        
        guard self.activeDownloads.count > 0 else { return }
        // Remove all items in the queue before canceling the active ones
        self.ZeeDownloadItemTasksQueue.purge()
        for (sessionTask, _) in self.activeDownloads {
            sessionTask.cancel()
        }
        self.activeDownloads.removeAll()
        self.invalidateSession()
        self.downloadModel.status = ZeeTaskStatus.failed.description()
        self.delegate?.downloadRequestCanceled(self.downloadModel)
    }
    
    public func invalidateSession() {
        if self.sessionManager != nil {
            self.sessionManager.invalidateAndCancel()
            self.sessionManager = nil
        }
    }
}
