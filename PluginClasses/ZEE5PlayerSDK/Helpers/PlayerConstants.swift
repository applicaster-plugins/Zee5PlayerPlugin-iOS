//
//  PlayerConstants.swift
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 10/06/20.
//

import UIKit
import Zee5CoreSDK

@objc public class PlayerConstants: NSObject {
    
   enum localizedKeys: String {
    case Consumption_PlayerError_ContentNotAvailable_Text = "Consumption_PlayerError_ContentNotAvailable_Text"
    case Player_PlayerBody_Wait24Hours_Text = "Player_PlayerBody_Wait24Hours_Text"
    
}
    
  @objc public static let shared = PlayerConstants()
    
    @objc public func DetailApiFailed() ->String{
        let str = localizedKeys.Consumption_PlayerError_ContentNotAvailable_Text.rawValue.localized()
        return str
    }
    
    @objc public func deviceFullError() ->String{
         let str = localizedKeys.Player_PlayerBody_Wait24Hours_Text.rawValue.localized()
          return str
      }

}
extension String{
    func localized() -> String {
        return self.localized(Zee5UserDefaultsManager.shared.selectedDisplayLanguageCode())
    }
    /**
     Local plugin method to the localized string for the given language code.
     */
    func localized(_ lang:String) -> String {
        let localizedString = self.getLocalizedString(lang: lang, bundle: nil)
        // to check if language key is present or not. if not showing english.
        if self.caseInsensitiveCompare(localizedString) == .orderedSame {
            return self.getLocalizedString(lang: Zee5UserDefaultsKeys.defaultLocale.rawValue, bundle: nil)
        }
        return localizedString
    }
}

public extension UIFont {
    @objc static func jbs_registerFont(withFilenameString filenameString: String, bundle: Bundle) {
        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil) else {
            return
        }
        
        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            return
        }
        
        guard let dataProvider = CGDataProvider(data: fontData) else {
            return
        }
        
        guard let font = CGFont(dataProvider) else {
            return
        }
        
        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
        }
    }
}
