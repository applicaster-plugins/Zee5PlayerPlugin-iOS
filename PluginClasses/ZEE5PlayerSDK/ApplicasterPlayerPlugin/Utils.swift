//
//  Utils.swift
//  ZEE5PlayerSDK
//
//  Created by User on 25/09/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

import Foundation

private enum CustomConfiguration: String {
    case videoPlayErrorMessage = "General_Error_Message"
    case videoPlayErrorButtonText = "General_Error_Button"
    case connectivityErrorMessage = "Connectivity_Error_Message"
    case connectivityErrorButtonText = "Connectivity_Error_Button"
}

class ErrorViewConfiguration {
    let videoPlayErrorMessage: String
    let videoPlayErrorButtonText: String
    let connectivityErrorMessage: String
    let connectivityErrorButtonText: String
    
    init(fromDictionary dict: NSDictionary) {
        videoPlayErrorMessage = dict[CustomConfiguration.videoPlayErrorMessage.rawValue] as? String ?? ""
        videoPlayErrorButtonText = dict[CustomConfiguration.videoPlayErrorButtonText.rawValue] as? String ?? ""
        connectivityErrorMessage = dict[CustomConfiguration.connectivityErrorMessage.rawValue] as? String ?? ""
        connectivityErrorButtonText = dict[CustomConfiguration.connectivityErrorButtonText.rawValue] as? String ?? ""
    }
}
