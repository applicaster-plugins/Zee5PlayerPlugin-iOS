//
//  ZPReactNativeZappPipes.swift
//  ZappReactNativeAdapter
//
//  Created by Avi Levin on 29/01/2018.
//  Copyright © 2018 Applicaster Ltd. All rights reserved.
//

import Foundation
import React
import ApplicasterSDK

@objc (ReactNativePlayerStatusModule)
class ReactNativePlayerStatusModule: NSObject, RCTBridgeModule {
    
    static func moduleName() -> String! {
        return "ReactNativePlayerStatusModule"
    }
    
    var bridge: RCTBridge!
    
    @objc(getCurrentPlayable:rejecter:)
    func getCurrentPlayable(resolver: @escaping RCTPromiseResolveBlock,
                            rejecter: @escaping RCTPromiseRejectBlock) -> Void {
        guard
            let lastActiveInstance = ZPPlayerManager.sharedInstance.lastActiveInstance as? KanPluggablePlayer,
            let playable = lastActiveInstance.currentPlayableItem,
            let hybridViewController = lastActiveInstance.hybridViewController else {
                resolver([])
                return
        }
        var playableID = ""
        if let identifier = playable.identifier as String? {
            playableID = identifier
        }
        print("playableID \(playableID)")

        resolver(["id": playableID,
                  "type":(hybridViewController.isLive == true ? "channel": "")])
    }
    
}
