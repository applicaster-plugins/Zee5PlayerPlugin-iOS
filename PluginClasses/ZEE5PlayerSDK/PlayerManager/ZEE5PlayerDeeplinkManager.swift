//
//  ZEE5PlayerDeeplinkManager.swift
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 04/02/20.
//

import Foundation
import Zee5CoreSDK
import ZappPlugins


 

@objc public class ZEE5PlayerDeeplinkManager: NSObject
{
    @objc static let sharedMethod = ZEE5PlayerDeeplinkManager()

    //private override init() {}
    
  @objc public func GetSubscrbtion(with Assetid:String,beforetv:Bool)
    {
        Zee5DeepLinkingManager.shared.openURL(withURL:Zee5DeepLinkingManager.URLs.buySubscriptions(assetID: Assetid, beforeTV: beforetv).url)
        
    }
    
    @objc public func NavigatetoLoginpage()
    {
       Zee5DeepLinkingManager.shared.openURL(withURL: Zee5DeepLinkingManager.URLs.login.url)
    }
    
    
    @objc public func NavigatetoParentalViewPage()
    {
      Zee5DeepLinkingManager.shared.openURL(withURL: Zee5DeepLinkingManager.URLs.parentalControl.url)
    }
    
    @objc public func NavigatetoDownloads()
     {
        Zee5DeepLinkingManager.shared.openURL(withURL: Zee5DeepLinkingManager.URLs.myDownload.url)
     }
    
    @objc public func NavigatetoHomeScreen()
    {
       ZAAppConnector.sharedInstance().navigationDelegate.navigateToHomeScreen()
    }
    
    @objc public func NavigateToPartnerApp()
       {
        
      }
}
