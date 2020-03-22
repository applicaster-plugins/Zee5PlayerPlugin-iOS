//
//  ZeeDownloadUtility.swift
//  Zee5DownloadManager
//
//  Created by User on 20/06/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit

struct ZeeQueue<T> {
    
    /// The physical array that holds queue elements
    fileprivate var array = [T?]()
    /// The index of the first element
    fileprivate var head = 0
    /// The percentage of nil objects from array size to reorder queue elements (O(n) so it is better to only reorder only from some point)
    var queueOptimizationPercentage: Double
    /// The array minimum size to start reordering elements when certain percentage is met.
    var queueOptimizationMinimumSize: Int
    
    init(arrayOptimizationMinimumSize: Int = 50, arrayOptimizationPercentage: Double = 0.25) {
        self.queueOptimizationMinimumSize = arrayOptimizationMinimumSize
        self.queueOptimizationPercentage = arrayOptimizationPercentage
    }
    
    var isEmpty: Bool {
        return self.count == 0
    }
    
    var count: Int {
        return self.array.count - self.head
    }
    
    mutating func enqueue(_ element: T) {
        self.array.append(element)
    }
    
    mutating func enqueue(_ elements: [T]) {
        self.array.append(contentsOf: elements as [T?])
    }
    
    mutating func enqueueAtHead(_ element: T) {
        self.array.insert(element, at: self.head)
    }
    
    mutating func enqueueAtHead(_ elements: [T]) {
        self.array.insert(contentsOf: elements as [T?], at: head)
    }
    
    mutating func dequeue() -> T? {
        guard self.head < self.array.count, let element = self.array[head] else { return nil }
        
        self.array[self.head] = nil
        self.head += 1
        
        let percentage = Double(self.head)/Double(self.array.count)
        if self.array.count > self.queueOptimizationMinimumSize && percentage > self.queueOptimizationPercentage {
            self.array.removeFirst(self.head)
            self.head = 0
        }
        return element
    }
    
    /// clears the queue of all items (like remove all)
    mutating func purge() {
        self.array.removeAll()
    }
    
    var front: T? {
        if self.isEmpty {
            return nil
        } else {
            return self.array[self.head]
        }
    }
}

/************************************************************/
// MARK: - ZeeDownloadItemTask
/************************************************************/

/// `ZeeDownloadItemTask` represents one file to download (could be video, audio or captions)

struct ZeeDownloadItemTask {
    let itemId: String
    /// The content url, should be unique!
    let contentUrl: URL
    let type: ZeeDownloadItemTaskType
    /// The destination to save the download item to.
    let destinationUrl: URL
    var retry: Int = 1
    var resumeData: Data? = nil
    
    init(itemId: String, contentUrl: URL, type: ZeeDownloadItemTaskType, destinationUrl: URL) {
        self.itemId = itemId
        self.contentUrl = contentUrl
        self.type = type
        self.destinationUrl = destinationUrl
    }
}

/************************************************************/
// MARK: - ZeeDownloadItemTaskType
/************************************************************/

enum ZeeDownloadItemTaskType {
    case video
    case audio
    case text
    case key
    case image
    
    static var allTypes: [ZeeDownloadItemTaskType] {
        return [.video, .audio, .text, .key, .image]
    }
    
    init?(type: String) {
        switch type {
        case "video": self = .video
        case "audio": self = .audio
        case "text": self = .text
        case "key": self = .key
        case "image": self = .image
        default: return nil
        }
    }
    
    func asString() -> String {
        switch self {
        case .video: return "video"
        case .audio: return "audio"
        case .text: return "text"
        case .key: return "key"
        case .image: return "image"
        }
    }
}
