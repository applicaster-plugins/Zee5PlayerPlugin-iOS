//
//  VideoOptions.swift
//  Zee5DownloadManager
//
//  Created by User on 19/06/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import Foundation

// Video resolution model
public struct Z5VideoConfig: Codable {
    public var content_id: String?
    public var translation: String?
    public var type: String?
    public var download_options: [Z5Option]?
}

// Available video resolution types as Good, Better, Best, Data Saver
public struct Z5Option: Codable {
    public var bitrate : Int?
    public var resolution : String?
    public var sequence : String?
    public var size : String?
}

// Download manager helper utility class
class ZeeUtility {
    static let utility = ZeeUtility()
    
    func console(_ object: Any) {
        // logs disabled, should be enabled only locally
//        print(object)
    }
}
