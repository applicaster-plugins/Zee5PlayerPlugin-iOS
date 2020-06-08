//
//  ZEE5PlayerDeeplinkManager.swift
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 04/02/20.
//

import Foundation
import Zee5CoreSDK
import ZappPlugins

var CompletionHandler:((Bool)->(Void))?

@objc public class ZEE5PlayerDeeplinkManager: NSObject
{
    @objc public static let sharedMethod = ZEE5PlayerDeeplinkManager()

    //private override init() {}
    
  @objc public func GetSubscrbtion(with Assetid:String,beforetv:Bool,Param : String , completion:@escaping((Bool)->(Void)))
    {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        User.shared.refreshViewAfterloginOrRegistration = { [] in
                           completion(true)
                       }
        Zee5DeepLinkingManager.shared.openURL(withURL:Zee5DeepLinkingManager.URLs.buySubscriptions(assetID: Assetid, beforeTV: beforetv).url)
    }
    
    @objc public func NavigatetoLoginpage(Param : String , completion:@escaping((Bool)->(Void))){
         let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                User.shared.refreshViewAfterloginOrRegistration = { [] in
                    completion(true)
                }
               Zee5DeepLinkingManager.shared.openURL(withURL: Zee5DeepLinkingManager.URLs.login.url)
    }
    @objc public func NavigatetoParentalViewPage()
    {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
      Zee5DeepLinkingManager.shared.openURL(withURL: Zee5DeepLinkingManager.URLs.parentalControl.url)
    }
    
    @objc public func NavigatetoDownloads()
     {
        Zee5DeepLinkingManager.shared.openURL(withURL: Zee5DeepLinkingManager.URLs.myDownload.url)
     }
    
    @objc public func Hybridpackview(completion:@escaping((Bool)->(Void)))
    {
     Zee5DeepLinkingManager.shared.openURL(withURL: Zee5DeepLinkingManager.URLs.showUpgradePopUp.url)
        User.shared.refreshViewAfterloginOrRegistration = { [] in
                                 completion(true)
                             }
    }
    
    @objc public func NavigatetoHomeScreen()
    {
    let value = UIInterfaceOrientation.portrait.rawValue
    UIDevice.current.setValue(value, forKey: "orientation")
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
    
    @objc public func Showtoast(Message:String){
        Zee5ToastView.showToast(withMessage: Message);
    }
    
 @objc public func fetchUserdata() {
        
        ZEE5UserDefaults.setPlateFormToken(Zee5UserDefaultsManager.shared.getPlatformToken())
        
        ZEE5UserDefaults.setUserType(User.shared.getType().rawValue)
        ZEE5UserDefaults.settranslationLanguage(Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage() ?? "en")
        
        let Country =  Zee5UserDefaultsManager.shared.getCountryDetailsFromCountryResponse()
        
        ZEE5UserDefaults.setCountry(Country.country, andState: Country.state)
        
        if let SubscribeData = Zee5UserDefaultsManager.shared.getSubscriptionPacksData() {
            let dataString = String(data: SubscribeData, encoding: String.Encoding.utf8)
            ZEE5UserDefaults.setUserSubscribedPack(dataString ?? "")
        }
        
        if let UserSetting = Zee5UserDefaultsManager.shared.getUsersSettings() {
        let userSettingString = String(data: UserSetting, encoding: String.Encoding.utf8)
                      ZEE5UserDefaults.setUserSettingData(userSettingString ?? "")
    }
    
}
}
