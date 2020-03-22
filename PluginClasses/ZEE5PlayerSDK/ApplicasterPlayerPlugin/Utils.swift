//
//  Utils.swift
//  ZEE5PlayerSDK
//
//  Created by User on 25/09/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

import Foundation
import ZappPlugins

enum PlayerScreenMode: String, Equatable {
    case inline = "Inline Player"
    case fullscreen = "Full Screen Player"
    
    var key: String {
        return "View"
    }
}

private enum CustomConfiguration: String {
    case videoPlayErrorMessage = "General_Error_Message"
    case videoPlayErrorButtonText = "General_Error_Button"
    case connectivityErrorMessage = "Connectivity_Error_Message"
    case connectivityErrorButtonText = "Connectivity_Error_Button"
}

protocol PlayerViewBuilderProtocol {
    var mode: PlayerScreenMode { get set }
    var kalturaPlayerController: KalturaPlayerController? { get set }
    var errorViewConfiguration: ErrorViewConfiguration? { get set }
}

class PlayerViewBuilder: PlayerViewBuilderProtocol
{
    var mode: PlayerScreenMode = .fullscreen
    weak var kalturaPlayerController: KalturaPlayerController?
    var errorViewConfiguration: ErrorViewConfiguration?
}

class ViewControllerFactory {
    
    public static func createPlayerViewController(videoItems: [ZPPlayable], errorViewConfig: ErrorViewConfiguration?) -> KalturaPlayerController {
        
        let builder = PlayerViewBuilder()
        builder.errorViewConfiguration = errorViewConfig
        let player = ZappZee5PlayerAdapter(items: videoItems)
        let kalturaPlayerController = KalturaPlayerController(builder: builder, player: player)
        builder.kalturaPlayerController = kalturaPlayerController
        
        return kalturaPlayerController
    }
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
