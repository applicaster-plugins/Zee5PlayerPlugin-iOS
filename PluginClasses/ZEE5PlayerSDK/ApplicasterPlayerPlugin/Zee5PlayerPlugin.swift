//
//  Zee5PlayerPlugin.swift
//  ZEE5PlayerSDK
//
//  Created by User on 24/09/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

import Foundation
import ZappPlugins
import ApplicasterSDK
import Zee5CoreSDK

public class ZappPlayerAdapter: NSObject {
   
    var userAccessToken = ""
    static let shared = ZappPlayerAdapter()
    
    @objc public func getUserAccessToken()->String
       {
           User.shared.getAccessToken { (Token, error) in
                         print(Token)
               self.userAccessToken = Token
                     }
           return userAccessToken
       }
    
}
