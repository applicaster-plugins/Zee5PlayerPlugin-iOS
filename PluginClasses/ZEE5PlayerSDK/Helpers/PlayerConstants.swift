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
        
        
        //DOWNLOADS
        case Downloads_OverflowMenu_Pause_Button = "Downloads_OverflowMenu_Pause_Button"
        case Downloads_OverflowMenu_Resume_Button = "Downloads_OverflowMenu_Resume_Button"
        case Downloads_Tag_NewEpisode_Text = "Downloads_Tag_NewEpisode_Text"
        case Downloads_ErrorMessage_DownloadFailed_Text = "Downloads_ErrorMessage_DownloadFailed_Text"
        case Downloads_InsufficientMemoryPopup_Ok_CTA = "Downloads_InsufficientMemoryPopup_Ok_CTA"
        case Downloads_Header_Downloads_Text = "Downloads_Header_Downloads_Text"
        case Downloads_SubHeader_Shows_Tab = "Downloads_SubHeader_Shows_Tab"
        case Downloads_SubHeader_Movies_Tab = "Downloads_SubHeader_Movies_Tab"
        case Downloads_SubHeader_Videos_Tab = "Downloads_SubHeader_Videos_Tab"
        case Downloads_CTA_BrowseToDownload_Button = "Downloads_CTA_BrowseToDownload_Button"
        case Downloads_SubHeader_SelectItemsToDelete_Text = "Downloads_SubHeader_SelectItemsToDelete_Text"
        case Downloads_SubHeader_Delete_Link = "Downloads_SubHeader_Delete_Link"
        case Downloads_ListItemDetails_NumberOfEpisodes_Text = "Downloads_ListItemDetails_NumberOfEpisodes_Text"
        case Downloads_ListItemDetails_Downloading_Text = "Downloads_ListItemDetails_Downloading_Text"
        case Downloads_SubHeader_Edit_Link = "Downloads_SubHeader_Edit_Link"
        case Downloads_ListItemDetails_DownloadingVideos_Text = "Downloads_ListItemDetails_DownloadingVideos_Text"
        case Downloads_ListItemDetails_ExpiresIn_Text = "Downloads_ListItemDetails_ExpiresIn_Text"
        case Downloads_ListItemDetails_Queued_Text = "Downloads_ListItemDetails_Queued_Text"
        case Downloads_ListItemDetails_NewEpisodeOut_Text = "Downloads_ListItemDetails_NewEpisodeOut_Text"
        case Downloads_ListItemDetails_DownloadNow_Link = "Downloads_ListItemDetails_DownloadNow_Link"
        case Downloads_SubHeader_SelectAll_Link = "Downloads_SubHeader_SelectAll_Link"
        case Downloads_Body_SubscriptionExpiryReminder_Text = "Downloads_Body_SubscriptionExpiryReminder_Text"
        case Downloads_Body_RenewSubscriptionConfirmation_Text = "Downloads_Body_RenewSubscriptionConfirmation_Text"
        case Downloads_ListItemDetails_RestoreDownload_Link = "Downloads_ListItemDetails_RestoreDownload_Link"
        case Downloads_ListItemDetails_DownloadError_Text = "Downloads_ListItemDetails_DownloadError_Text"
        case Downloads_ListItemDetails_DownloadExpired_Text = "Downloads_ListItemDetails_DownloadExpired_Text"
        case Downloads_ListItemOverflowMenu_Play_MenuItem = "Downloads_ListItemOverflowMenu_Play_MenuItem"
        case Downloads_ListItemOverflowMenu_DeleteDownload_MenuItem = "Downloads_ListItemOverflowMenu_DeleteDownload_MenuItem"
        case Downloads_ListItemOverflowMenu_RetryDownload_MenuItem = "Downloads_ListItemOverflowMenu_RetryDownload_MenuItem"
        case Downloads_ListItemOverflowMenu_CancelDownload_MenuItem = "Downloads_ListItemOverflowMenu_CancelDownload_MenuItem"
        case Downloads_Body_NotConnectedToInternet_Text = "Downloads_Body_NotConnectedToInternet_Text"
        case Downloads_Body_Retry_Link = "Downloads_Body_Retry_Link"
        case Downloads_CTA_GoToDownloads_Button = "Downloads_CTA_GoToDownloads_Button"
        case Downloads_ErrorDescription_OutOfSpace_Text = "Downloads_ErrorDescription_OutOfSpace_Text"
        case Downloads_ListItemOverflowMenu_PauseAll_MenuItem = "Downloads_ListItemOverflowMenu_PauseAll_MenuItem"
        case Downloads_SubHeader_SelectedItemToDelete_Text = "Downloads_SubHeader_SelectedItemToDelete_Text"
        case Downloads_CTA_DownloadMoreEpisodes_Button = "Downloads_CTA_DownloadMoreEpisodes_Button"
        case Downloads_ListItemDetails_Paused_Text = "Downloads_ListItemDetails_Paused_Text"

    }
    
    @objc public static let shared = PlayerConstants()
    
    @objc public func detailApiFailed() ->String{
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
