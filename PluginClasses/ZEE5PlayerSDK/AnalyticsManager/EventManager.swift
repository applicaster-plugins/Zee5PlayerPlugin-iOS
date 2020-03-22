//
//  EventManager.swift
//  ZEE5PlayerSDK
//
//  Created by Abbas's Mac Mini on 22/08/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

import Foundation

public class EventManager: NSObject {
    
    // Conviva Analytics
    @objc public func setConvivaConfiguration(customerKey: String, gatewayUrl: String)
    {
        AnalyticEngine.shared.initializeConvivaAnalytics(customerKey: customerKey, gatewayUrl: gatewayUrl)
    }
    
}
