//
//  DownloadHelper.swift
//  Zee5DownloadSDK
//
//  Created by Abhishek on 21/12/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import Foundation
import Toast_Swift
import ZappPlugins
import Zee5CoreSDK

public class DownloadHelper: NSObject {
    
    @objc public static let shared = DownloadHelper()
    
    private let licenseUrl = "https://fp-keyos-aps1.licensekeyserver.com/getkey/"
    private let base64 = "MIIE1zCCA7+gAwIBAgIIWWD0ecwMxBUwDQYJKoZIhvcNAQEFBQAwfzELMAkGA1UEBhMCVVMxEzARBgNVBAoMCkFwcGxlIEluYy4xJjAkBgNVBAsMHUFwcGxlIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MTMwMQYDVQQDDCpBcHBsZSBLZXkgU2VydmljZXMgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTcxMTI5MTM1NzI0WhcNMTkxMTMwMTM1NzI0WjBuMQswCQYDVQQGEwJVUzEaMBgGA1UECgwRWjVYIEdsb2JhbCBGWi1MTEMxEzARBgNVBAsMCkM5UkVHUEI0NkMxLjAsBgNVBAMMJUZhaXJQbGF5IFN0cmVhbWluZzogWjVYIEdsb2JhbCBGWi1MTEMwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAMmRxhh2nLbAqJKQQ+7FDJPocqj8fqpwmG3dEIxo4gpBlLhsbgSSM583PBN6kHUeUys/jegl3OhcP8xSn4mD66mprG1mAlUrZFqIglQaZkFOOQN8PHPZUFpKIfrgzlqB8BqvZnmNv/jAAZlyBJeHcCgiWaX30Dj9AI4mlkebS5TFAgMBAAGjggHqMIIB5jAdBgNVHQ4EFgQUJksWck0AHXZSwsyMf1beneKIDjAwDAYDVR0TAQH/BAIwADAfBgNVHSMEGDAWgBRj5EdUy4VxWUYsg6zMRDFkZwMsvjCB4gYDVR0gBIHaMIHXMIHUBgkqhkiG92NkBQEwgcYwgcMGCCsGAQUFBwICMIG2DIGzUmVsaWFuY2Ugb24gdGhpcyBjZXJ0aWZpY2F0ZSBieSBhbnkgcGFydHkgYXNzdW1lcyBhY2NlcHRhbmNlIG9mIHRoZSB0aGVuIGFwcGxpY2FibGUgc3RhbmRhcmQgdGVybXMgYW5kIGNvbmRpdGlvbnMgb2YgdXNlLCBjZXJ0aWZpY2F0ZSBwb2xpY3kgYW5kIGNlcnRpZmljYXRpb24gcHJhY3RpY2Ugc3RhdGVtZW50cy4wNQYDVR0fBC4wLDAqoCigJoYkaHR0cDovL2NybC5hcHBsZS5jb20va2V5c2VydmljZXMuY3JsMA4GA1UdDwEB/wQEAwIFIDA7BgsqhkiG92NkBg0BAwEB/wQpAXBiYWwxd25vcXJybW90ajFlcXE2ZHd3a3ZubG9rd2h6bDV1eTRrZ2EwLQYLKoZIhvdjZAYNAQQBAf8EGwFjMzJ4cXZlZHllaWxvMHowd3VlaWpxcnpuaTANBgkqhkiG9w0BAQUFAAOCAQEAPICsXS/tBrTH4wrSipaLTZYAOEMDgbblgTxK+u7y4jk+QVZ01RpjCO0FJVEAiVmPJvnwBA1OLw1klHVXBGiBcbUXb0MqbcNDwGFK0xAkB6INkFbZCrwNa0EcBXt9QQZIOt0TcHhSHXJCEVuTj5ywJye7EPJiAM4ZDNxw5brn4omqIr8T9CAyRwUnVJJnt+UoMqqZSkEqXZL+VIhIhusaKr39xgl17eE5sSlnZ0R8xwfuPSuMFWsbc5w3yT4c8PHp4M25cv6utMDIpExnQqLBFf8WBnzkdyL2W+egg7hKGUF5fyCbZA22Ij5da/7XwidZgT5q7U8kgaPkFKE/XW0/Uw=="
    private var isOpen = false

    
    private var currentDownloadOptionsView: DownloadQualityMenu?
    
    // MARK:- Start downloading content
    @objc public func startDownloadItem(with item: CurrentItem) {
        let (data, customData) = self.createVodData(with: item)
        let zItem = self.setupContentForDownload(with: data, customData: customData)
        self.addItemToDownload(data: zItem)
    }
    
    fileprivate func createVodData(with item: CurrentItem) -> (VODContentDetailsDataModel, String) {
        let data = VODContentDetailsDataModel()
        data.hlsUrl = item.hls_Url
        data.drmKeyID = item.drm_key
        data.subtitleLanguages = item.subTitles
        data.identifier = item.content_id
        data.title = item.channel_Name
        data.assetType = item.asset_type
        data.assetSubtype = item.asset_subtype
        data.releaseDate = item.release_date
        data.episodeNumber = item.episode_number
        data.showOriginalTitle = item.showName
        data.duration = item.duration
        data.imageUrl = item.imageUrl
        data.tvShowimgurl = item.tvShowImgurl
        data.contentDescription = item.info
        data.geners = item.geners
        data.isDRM = item.isDRM
        data.audioLanguages = item.audioLanguages
        data.ageRating = item.ageRate
        
        return (data, item.drm_token)
    }
    
    fileprivate func addItemToDownload(data: ZeeDownloadItem) {
        do {
            let isDownloaded = try Zee5DownloadManager.shared.isItemAlreadyDownloaded(contentId: data.contentId)
            if isDownloaded == true {
                self.showToast("\(data.title) is already downloaded")
            }
            else {
                try Zee5DownloadManager.shared.addItem(item: data)
                
                Zee5DownloadManager.shared.getVideoBitrates(contentId: data.contentId, contentUrl: data.contentUrl) {
                    (config) in
                    if let config = config {
                        DispatchQueue.main.async {
                            DownloadHelper.shared.setupDownloadOptionMenu(with: config, data: data)
                            AnalyticEngine.shared.PopUpLaunch(with: "Download Quality Pop Up")
                        }
                    }
                    else {
                        self.startDownloadingContent(with: data, bitrate: 800000)
                    }
                }
            }
        }
        catch {
            ZeeUtility.utility.console("Add item to download Error: \(error)")
            self.showToast("Add Item Error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func startDownloadingContent(with data: ZeeDownloadItem, bitrate: Int) {
        
        do {
            Zee5DownloadManager.shared.delegate = self
            try Zee5DownloadManager.shared.startDownload(id: data.contentId, bitrate: bitrate, videoDetail: data)
        }
        catch {
            ZeeUtility.utility.console("Download video Error: \(error.localizedDescription)")
            self.showToast("Download video Error: \(error.localizedDescription)")

        }
    }
    
    // MARK:- Goto download section
    @objc public func gotoDownloadView() {
        
        UIDevice.current.setValue(NSNumber(value: UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        let controller = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
        let bundle = Bundle(for: DownloadRootController.self)
        let storyboard = UIStoryboard(name: "Download", bundle: bundle)
        guard let downloadVC = storyboard.instantiateViewController(withIdentifier: "DownloadRootController") as? DownloadRootController else { return }
        let navControl = UINavigationController(rootViewController: downloadVC)
        controller?.present(navControl, animated: true, completion: nil)
    }
    
    // MARK:- Remove undownloaded content
    @objc public func removeContent(with id: String) {
        do {
            try Zee5DownloadManager.shared.removeDownloadItem(id: id)
        }
        catch {
            ZeeUtility.utility.console("Remove content Error: \(error.localizedDescription)")
          
        }
    }
    
    //
    @objc public func restoreExpiredContent(id: String, isExpired: @escaping ((Bool, String?) -> Void)) {
        let location =  Zee5UserDefaultsManager.shared.getCountryDetailsFromCountryResponse()
        let translation =  Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage() ?? "en"
        ZEE5PlayerManager.sharedInstance().downloadVODContent(id, country: location.country, translation: translation) {
            (data, customData) in
            
            if let Voddata = data , let CustomeString = customData{
                let zItem = self.setupContentForDownload(with: Voddata, customData:CustomeString)
                do {
                    try Zee5DownloadManager.shared.renewExpiredContent(with: zItem)
                    isExpired(true, nil)
                }
                catch {
                    ZeeUtility.utility.console("Restore download Error: \(error.localizedDescription)")
                    isExpired(false, error.localizedDescription)
                    self.showToast("Restore download Error: \(error.localizedDescription)")
                    
                }
            }
        }
    }
    
    fileprivate func setupContentForDownload(with data: VODContentDetailsDataModel, customData: String) -> ZeeDownloadItem {
        
        var videoUrl = ""
        
        if data.hlsUrl.contains("https://") == false {
            videoUrl = data.isDRM ? "https://zee5vod.akamaized.net" + "\(data.hlsUrl)" : data.hlsUrl
        }
        else {
            videoUrl = data.hlsUrl
        }
        
        // Update value from player sdk
        let zeeItem = ZeeDownloadItem(id: data.identifier, url: videoUrl, title: data.title, imageUrl: data.imageUrl,showimgUrl:data.tvShowimgurl, info: data.contentDescription, episodeNumber: data.episodeNumber, assetType: data.assetType, assetSubType: data.assetSubtype, duration: data.duration, showOriginalTitle: data.showOriginalTitle, licenseUrl: self.licenseUrl, base64: self.base64, customData: customData, Agerating: data.ageRating)
        
        // Setup Fairplay license for offline plyaback
        let fairParam = FairPlayDRMParams(licenseUri: self.licenseUrl, base64EncodedCertificate: self.base64)
        let source = PKMediaSource(data.identifier, contentUrl: URL(string: videoUrl), mimeType: nil, drmData: [fairParam], mediaFormat: .hls)
        let entry = PKMediaEntry(data.identifier, sources: [source], duration: 1000)
        let fairPlay = FormFairPlayLicenseProvider()
        fairPlay.customData = customData
        
        // Update fair play license
        Zee5DownloadManager.shared.setFairPlayLicense(fairPlay: fairPlay, entry: entry)
        
        return zeeItem
    }
}

// MARK:- Setup download option menu
extension DownloadHelper {

    fileprivate func setupDownloadOptionMenu(with config: Z5VideoConfig, data: ZeeDownloadItem) {
        guard let parent = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal(),  !isOpen else {
            return
        }
        
        let bundle = Bundle(for: DownloadRootController.self)
        guard let downloadView = bundle.loadNibNamed(DownloadQualityMenu.identifier, owner: self, options: nil)?.first as? DownloadQualityMenu else { return }
        downloadView.setupVideoQuality(with: config, data: data)
        
        parent.view.addSubview(downloadView)
        downloadView.fillParent()
        
        self.currentDownloadOptionsView = downloadView
        isOpen = true
    }
    
    @objc public func removeDownloadOptionMenu() {
        if let currentDownloadOptionsView = self.currentDownloadOptionsView {
            currentDownloadOptionsView.removeFromSuperview()
            self.currentDownloadOptionsView = nil
            isOpen = false
        }
    }
    
    @objc public func selectedVideoResolution(videoBitrate: Int, data: ZeeDownloadItem) {
        self.startDownloadingContent(with: data, bitrate: videoBitrate)
    }
}

extension DownloadHelper: Zee5DownloaderDelegate {
    
    public func downloadItemWithState(id: String, didChangeToState newState: DownloadItemState, error: Error?) {
        ZeeUtility.utility.console("DownloadHelper :: download State :: \(newState.asString())")
    }
    
    public func downloadItemWithData(id: String, didDownloadData totalBytesDownloaded: Int64, totalBytesEstimated: Int64?) {
        ZeeUtility.utility.console("DownloadHelper :: download Data :: \(String(describing: totalBytesEstimated)) / \(totalBytesDownloaded)")
    }
}

extension DownloadHelper {
    
    @objc public func showToast(_ message: String) {
       DispatchQueue.main.async {
         Zee5ToastView.showToast(withMessage: message)
        }
    }
}
