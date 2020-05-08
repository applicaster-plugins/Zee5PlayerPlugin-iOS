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
        let Telco = User.shared.isTelcoUser()
          if Telco.0
            {
                    if let ParameterDict = Telco.1 {
                        debugPrint(ParameterDict["partner_schema_ios"]as Any)
                        openCustomURLScheme(customURLScheme: "\(ParameterDict["partner_schema_ios"] ?? "")://", complitionHandler: {(isNavigate) in
                    if !isNavigate{
                                // handle unable to open the app, perhaps redirect to the App Store
                        let myUrl = "https://itunes.apple.com/us/app/apple-store/\(ParameterDict["partner_bundle_id_ios"] ?? "")?mt=8"
                        if let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                
                            }
                        }
                    }
                )}
               }
        }
    
    
    public func openCustomURLScheme(customURLScheme: String, complitionHandler:@escaping(Bool)->Void)  {
                      let customURL = URL(string: customURLScheme)!
                      UIApplication.shared.open(customURL) { (result) in
                          if result {
                             // The URL was delivered successfully!
                              complitionHandler(true)
                          }
                          else
                          {
                              complitionHandler(false)
                          }
                      }
                  }
}
