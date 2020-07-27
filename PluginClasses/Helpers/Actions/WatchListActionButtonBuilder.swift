//
//  WatchListActionButtonBuilder.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 26.04.20.
//

import Foundation

import Zee5CoreSDK

class WatchListActionButtonBuilder: BaseActionButtonBuilder, ActionButtonBuilder {
    var isItemInWatchlist = false
    
    func build() -> ActionBarView.ButtonData? {
        guard
            let image = self.image(for: "consumption_favourite"),
            let title = self.localizedText(for: "ShowsConsumption_ShowDetails_Watchlist_ClickableIcon"),
            let style = self.style(for: "consumption_button_text") else {
                return nil
        }
        
        var selectedImage: UIImage? = nil
        if let selectedStyle = self.style(for: "consumption_text_indicator") {
            selectedImage = image.imageColoredIn(with: selectedStyle.color)
        }
                
        return ActionBarView.ButtonData(
            image: image,
            selectedImage: selectedImage,
            title: title,
            font: style.font,
            textColor: style.color,
            isFiller: false,
            custom: nil,
            action: toggleWatchlist
        )
    }
    
    func fetchInitialState() {
        guard let itemId = self.playable.contentId else {
            return
        }
        
        func parseResponse(watchlist: WatchListDataModel) {
            var isItemInWatchlist = false
            
            if let movies = watchlist.movie, movies.count > 0 {
                movies.forEach({ (item) in
                    if item.id == itemId {
                        isItemInWatchlist = true
                    }
                })
            }
            
            if let shows = watchlist.show, shows.count > 0 {
                shows.forEach({ (item) in
                    if item.id == itemId {
                        isItemInWatchlist = true
                    }
                })
            }
            
            if let videos = watchlist.video, videos.count > 0 {
                videos.forEach({ (item) in
                    if item.id == itemId {
                        isItemInWatchlist = true
                    }
                })
            }
            
            self.isItemInWatchlist = isItemInWatchlist
            self.actionBarUpdateHandler.setSelected(isItemInWatchlist)
        }
        
        let country = Zee5UserDefaultsManager.shared.getCountryDetailsFromCountryResponse().country
        let translation = Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage() ?? String()
        
        self.performWatchlistRequest(
            method: .get,
            request: WatchListApiRequest(),
            endpoint: ZEE5ApiEndPoints.watchList(country: country, translation: translation),
            params: nil) { (response) in
                guard let response = response as? WatchListDataModel else {
                    return
                }
                
                parseResponse(watchlist: response)
        }
    }
    
    fileprivate func toggleWatchlist() {
        if self.isItemInWatchlist {
            self.deleteFromWatchlist()
        }
        else {
            self.addToWatchlist()
        }
    }
            
    fileprivate func addToWatchlist() {
        
        // send guest user to login screen
        if User.shared.getType() == .guest {
            ZEE5PlayerManager.sharedInstance().showToastMessage("You must be logged in to perform this action.")
            ZEE5PlayerDeeplinkManager.sharedMethod.NavigatetoLoginpage(Param: "Watclist") { (isSucceess) -> (Void) in
                if isSucceess {
                    ZEE5PlayerDeeplinkManager.sharedMethod.fetchUserdata()
                }
            }
            ZEE5PlayerManager.sharedInstance().pause()
            return
        }
        
        guard
            let itemId = self.playable.contentId,
            let assetType = self.playable.assetType,
            let duration = self.playable.duration else {
                return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = formatter.string(from: Date())
        
        let params = [
            "id": itemId,
            ExtensionsKey.assetType: String(assetType),
            ExtensionsKey.duration: String(duration),
            "date": date
        ]
        
        self.performWatchlistRequest(
            method: .post,
            request: UpdateWatchListApiRequest(),
            endpoint: ZEE5ApiEndPoints.addToWatchList,
            params: params) { (response) in
                self.setItemInWatchList(itemIn: true,
                                  toastMessage: self.localizedText(for: "Consumption_ToastMessage_ItemAddedToWatchlist_Text"))
        }
    }
    
    fileprivate func deleteFromWatchlist() {
        guard
            let itemId = self.playable.contentId,
            let assetType = self.playable.assetType else {
                return
        }
                
        self.performWatchlistRequest(
            method: .delete,
            request: DeleteWatchListApiRequest(),
            endpoint: ZEE5ApiEndPoints.deleteFromWatchList(id: itemId, assetType: String(assetType)),
            params: nil) { (response) in
                self.setItemInWatchList(itemIn: false,
                                  toastMessage: self.localizedText(for: "Consumption_ToastMessage_RemovedFromWatchlist_Text"))
                AnalyticEngine.shared.RemoveFromWatchlistAnlytics()
        }
    }

    fileprivate func performWatchlistRequest<T: ZEE5APIRequest>(method: HTTPMethod, request: T, endpoint: ZEE5ApiEndPoints, params: Dictionary<String, Any>?, completion: @escaping ((Any)->())) {
        let accessToken = Zee5UserDefaultsManager.shared.getUserAccessToken()
        guard
            accessToken.count > 0,
            let data = params as? T.RequestDataType else {
                return
        }
        
        let headers = [
            "Authorization": accessToken,
            "X-Z5-AppPlatform": "mobile_ios"
        ]
        
        self.actionBarUpdateHandler.setDisabled(true)
        
        let requestLoader = ZEE5RequestLoader<T>(apiRequest: request)
        requestLoader.loadAPIRequest(request: method, funcion: endpoint, requestData: data, requestHeaders: headers) { (response, error) in
            self.actionBarUpdateHandler.setDisabled(false)

            guard error == nil, let response = response else {
                return
            }
            
            completion(response)
        }
    }
    
    fileprivate func setItemInWatchList(itemIn: Bool, toastMessage: String?) {
        self.isItemInWatchlist = itemIn
        self.actionBarUpdateHandler.setSelected(itemIn)
        Zee5ToastView.showToast(withMessage: toastMessage ?? "Unknwon Error")
        if itemIn == true {
            AnalyticEngine.shared.AddtoWatchlistAnlytics()
        }
    }
    
}
