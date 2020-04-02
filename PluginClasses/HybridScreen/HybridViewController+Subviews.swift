//
//  HybridViewController+Buttons.swift
//  Alamofire
//
//  Created by Miri on 31/03/2020.
//

import Foundation
import ZappPlugins
import ZappSDK
import UIKit
import Zee5CoreSDK

extension HybridViewController {
    
    // MARK: setup
    
    func setupButtons() {
        guard let buttonViewCollection = self.buttonsViewCollection else {
            return
        }
        
        let buttonStyle = stylesFor(key: "consumption_button_text")
        let indicatorStyle = stylesFor(key: "consumption_text_indicator")
        
        buttonViewCollection.forEach { (button) in
            if let tmpButton = button as? CAButton {
                
                tmpButton.removeTarget(tmpButton, action: #selector(CAButton.handleElementAction(_:)), for: .touchUpInside)
                switch tmpButton.tag {
                    
                case ItemTag.Button.shareButton:
                    let attr = NSAttributedString(string: "MoviesConsumption_MovieDetails_Share_Link".localized(hashMap: [:]))
                    tmpButton.setAttributedTitle(attr, for: .normal)
                    tmpButton.centerContentRelativeLocation(.imageUpTitleDown, spacing: 5)
                    tmpButton.titleLabel?.textColor = .white//buttonStyle.color
                    tmpButton.titleLabel?.font = buttonStyle.font
                    tmpButton.addTarget(self, action: #selector(self.shareButtonAction(_:)), for: .touchUpInside)
                    break
                case ItemTag.Button.watchlistButton:
                    
                    let attr = NSAttributedString(string: "ShowsConsumption_ShowDetails_Watchlist_ClickableIcon".localized(hashMap: [:]))
                    tmpButton.setAttributedTitle(attr, for: .normal)
                    let favouriteImageNormal = ZAAppConnector.sharedInstance().image(forAsset: "consumption_favourite")
                    tmpButton.setImage(favouriteImageNormal, for: .normal)
                    tmpButton.centerContentRelativeLocation(.imageUpTitleDown, spacing: 5)
                    tmpButton.titleLabel?.textColor = .white//buttonStyle.color
                    tmpButton.titleLabel?.font = buttonStyle.font
                    
                    tmpButton.addTarget(self, action: #selector(watchlistButtonAction(_:)), for: .touchUpInside)
                    
                    if consumptionFeedType == .live {
                        if let stackView = tmpButton.superview as? UIStackView {
                            stackView.removeArrangedSubview(tmpButton)
                            tmpButton.removeFromSuperview()
                        }
                    } else {
                        getWatchlist(completion: { (watchlist) in
                            var isItemAlreadyInWatchlist: Bool = false
                            
                            //check if item already in the watchlist
                            if let movies = watchlist.movie, movies.count > 0 {
                                movies.forEach({ (item) in
                                    if item.id == self.currentPlayableItem?.identifier as! String {
                                        isItemAlreadyInWatchlist = true
                                    }
                                })
                            }
                            if let shows = watchlist.show, shows.count > 0 {
                                shows.forEach({ (item) in
                                    if item.id == self.currentPlayableItem?.identifier as! String {
                                        isItemAlreadyInWatchlist = true
                                    }
                                })
                            }
                            if let videos = watchlist.video, videos.count > 0 {
                                videos.forEach({ (item) in
                                    if item.id == self.currentPlayableItem?.identifier as! String {
                                        isItemAlreadyInWatchlist = true
                                    }
                                })
                            }
                            
                            tmpButton.isSelected = isItemAlreadyInWatchlist
                            
                            let favouriteStyle = self.stylesFor(key: "consumption_text_indicator")
                            let favouriteImageNormal = ZAAppConnector.sharedInstance().image(forAsset: "consumption_favourite")
                            let favouriteImageSelected = ZAAppConnector.sharedInstance().image(forAsset: "consumption_favourite")?.imageColoredIn(with: favouriteStyle.color)
                            DispatchQueue.main.async {
                                tmpButton.setImage(isItemAlreadyInWatchlist ? favouriteImageSelected : favouriteImageNormal, for: .normal)
                                
                            }
                        })
                    }
                case ItemTag.Button.castButton:
                    let attr = NSAttributedString(string: "MoviesConsumption_MovieDetails_Cast_Link".localized(hashMap: [:]))
                    tmpButton.setAttributedTitle(attr, for: .normal)
                    tmpButton.centerContentRelativeLocation(.imageUpTitleDown, spacing: 5)
                    tmpButton.titleLabel?.textColor = .white//buttonStyle.color
                    tmpButton.titleLabel?.font = buttonStyle.font
                    tmpButton.addTarget(self, action: #selector(consumptionCastButtonAction(_:)), for: .touchUpInside)
                case ItemTag.Button.downloadButton:
                    
                    var translatedString: String = String()
                    switch consumptionFeedType {
                    case .movie:
                        translatedString = "MoviesConsumption_MovieDetails_Download_Button".localized(hashMap: [:])
                    case .show:
                        translatedString = "ShowsConsumption_ShowDetails_Download_Button".localized(hashMap: [:])
                    case .music:
                        translatedString = "MusicVideosConsumption_VideoDetails_Download_Button".localized(hashMap: [:])
                    default:
                        translatedString = "VideosConsumption_VideoDetails_Download_Button".localized(hashMap: [:])
                    }
                    let attr = NSAttributedString(string: translatedString)
                    tmpButton.setAttributedTitle(attr, for: .normal)
                    tmpButton.centerContentRelativeLocation(.imageUpTitleDown, spacing: 5)
                    tmpButton.titleLabel?.textColor = .white//buttonStyle.color
                    tmpButton.titleLabel?.font = buttonStyle.font
                    tmpButton.addTarget(self, action: #selector(consumptionDownloadButtonAction(_:)), for: .touchUpInside)
                    
                    guard let _ = self.currentPlayableItem else {
                        return
                    }
                    
                    if consumptionFeedType == .live || consumptionFeedType == .news {
                        if let stackView = tmpButton.superview as? UIStackView {
                            stackView.removeArrangedSubview(tmpButton)
                            tmpButton.removeFromSuperview()
                        }
                    }
                case ItemTag.Button.trailerButton:
                    //check if trailer link != nil and feed is equal to movie or episode
                    let attr = NSAttributedString(string: "MoviesConsumption_MovieDetails_WatchTrailer_Button".localized(hashMap: [:]))
                    tmpButton.setAttributedTitle(attr, for: .normal)
                    tmpButton.titleLabel?.textColor = .white//buttonStyle.color
                    tmpButton.titleLabel?.font = buttonStyle.font
                    tmpButton.centerContentRelativeLocation(.imageUpTitleDown, spacing: 5)
                    
                    guard let atom = self.currentPlayableItem else {
                        return
                    }
                    
                    if let _ = atom.extensionsDictionary?[ExtensionsKey.trailerDeeplink], consumptionFeedType == .movie || consumptionFeedType == .episode || consumptionFeedType == .original {
                        tmpButton.addTarget(self, action: #selector(consumptionTrailerButtonAction(_:)), for: .touchUpInside)
                    } else {
                        if let stackView = tmpButton.superview as? UIStackView {
                            stackView.removeArrangedSubview(tmpButton)
                            tmpButton.removeFromSuperview()
                        }
                    }
                    
                case ItemTag.Button.consumptionMoreLessDescriptionButton:
                    tmpButton.imageEdgeInsets.top = 45
                    itemDescriptionLabel!.numberOfLines = 2
                    tmpButton.addTarget(self, action: #selector(consumptionMoreLessDescriptionButtonAction(_:)), for: .touchUpInside)
                default:
                    break
                }
            }
        }
    }
    
    func setupLabels() {
        
        guard let labelsViewCollection = self.labelsCollection else {
            return
        }
        
        labelsViewCollection.forEach { (label) in
            
            switch label.tag {
                
                //             case ItemTag.Label.searchBarErrorLabel:
                //                 label.text = "Search_Body_SearchResult_Text".localized(hashMap: ["search_keyword": "\(getSearchBarString())"])
            //                 NotificationCenter.default.addObserver(self, selector: #selector(updateSearchError), name: Notification.Name(rawValue: DataBinderNotifications.updateSearchErrorAction.rawValue), object: nil)
            case ItemTag.Label.storyLineLabel:
                label.text = "Upcoming_Body_StoryLine_Text".localized(hashMap: [:])
                
            case ItemTag.Label.releasingOnLabel:
                
                var releasingString: String = "Upcoming_Body_ReleasingOn_Text".localized(hashMap: ["release_date": String()]) + ""
                
                guard let atom = self.currentPlayableItem, let date: String = atom.extensionsDictionary?[ExtensionsKey.releaseDate] as? String, !date.isEmptyOrWhitespace() else {
                    label.text = releasingString
                    return
                }
                var releaseString: String?
                //create date from string
                let dateFormatter = DateFormatter.init()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let releaseDate: Date = dateFormatter.date(from: date)!
                dateFormatter.dateFormat = "dd MMMM"
                
                releaseString = dateFormatter.string(from: releaseDate)
                
                releasingString = releasingString + (releaseString ?? String())
                label.text = releasingString
                
            case ItemTag.Label.numberTagLabel:
                guard let atom = self.currentPlayableItem, let numberText: Int = atom.extensionsDictionary?[ExtensionsKey.numberTagText] as? Int else {
                    return
                }
                label.text = "\(numberText)"
            case ItemTag.Label.consumptionTitleLabel:
                label.text = self.currentPlayableItem?.playableName()
                label.isHidden = label.text == nil
            case ItemTag.Label.consumptionMainInfoLabel:
                label.text = consumptionMainInfoLabel()
                label.isHidden = label.text == nil
            case ItemTag.Label.consumptionIMDBRatingLabel:
                //setup IMDB rating label
                if let rating: NSNumber = self.currentPlayableItem?.extensionsDictionary?[ExtensionsKey.rating] as? NSNumber {
                    label.text = rating.stringValue
                    label.layer.cornerRadius = 3
                    label.isHidden = false
                } else {
                    label.isHidden = true
                }
            case ItemTag.Label.consumptionAvailableInLabel:
                label.text = "MoviesConsumption_MovieDetails_AvailableVideoTechnology_Text".localized(hashMap: ["video_technology": String()])
            case ItemTag.Label.consumptionDescriptionLabel:
                break
            case ItemTag.Label.consumptionCastLabel:
                label.text = "     " + "MoviesConsumption_MovieDetails_Cast_Link".localized(hashMap: [:])
                
            case ItemTag.Label.consumptionCreatorsLabel:
                label.text = "     " + "MoviesConsumption_MovieDetails_Creators_Text".localized(hashMap: [:])
            case ItemTag.Label.upNextLabel:
                //setup up next label
                
                guard let atom = self.currentPlayableItem, let upNext = atom.extensionsDictionary?[ExtensionsKey.upNext] as? String  else {
                    return
                }
                label.text = "Up next: \(upNext)" //TODO: add translation for "Up next"
            case ItemTag.Label.timeLeftLabel:
                
                guard let atom = self.currentPlayableItem, let timeLeft = atom.extensionsDictionary?[ExtensionsKey.leftDuration] as? Int else {
                    return
                }
                
                //setup left duration
                let (h,m,s) = secondsToHoursMinutesSeconds(seconds: timeLeft)
                
                var timeString = String()
                if h != nil {
                    timeString.append("\(h!)h ")
                }
                if m != nil {
                    timeString.append("\(m!)m ")
                }
                if s != nil {
                    timeString.append("\(s!)s ")
                }
                
                if h != nil || m != nil || s != nil {
                    timeString.append(contentsOf: "left") //TODO: add translation for "left"
                }
                label.text = timeString
                //             case ItemTag.Label.episodeNumberAndDateLabel:
                //
                //                guard let atom = self.currentPlayableItem else {
                //                     return
                //                 }
                //
                //                 //setup Episode | date label
                //                 var timeString = String()
                //
                //                 var episodeNumber: String?
                //                 if let seasonDetails: [String: Any] = (atom.extensionsDictionary?[ExtensionsKey.seasonDetails] as? [String: Any]) {
                //                     if let currentEpisode = seasonDetails[ExtensionsKey.currentEpisode] as? String {
                //                         episodeNumber = "E\(currentEpisode)"
                //                         timeString.append(contentsOf: episodeNumber!)
                //                     }
                //                 }
                //
                //                 var publishedString: String?
                //                 guard let date: String = atom.publishDate, !date.isEmptyOrWhitespace() else {
                //                     label.text = timeString
                //                     return
                //                 }
                //                 //create date from string
                //                 let dateFormatter = DateFormatter.init()
                //                 dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                //                 let publishedDate: Date = dateFormatter.date(from: date)!
                //                 dateFormatter.dateFormat = "dd MMM"
                //
                //                 publishedString = dateFormatter.string(from: publishedDate)
                //                 timeString.append(contentsOf: timeString.isEmptyOrWhitespace() ? "\(publishedString!)" : " | \(publishedString!)")
                //
                //                 label.text = timeString
                
            case ItemTag.Label.timeFromToLabel:
                
                guard let atom = self.currentPlayableItem, let durationString = atom.extensionsDictionary?[ExtensionsKey.durationDate] as? String else {
                    return
                }
                
                //setup time from - to label
                label.text = durationString
            default:
                break
            }
        }
    }
    
    func setupViews() {
        guard let viewsViewCollection = self.viewCollection else {
            return
        }
        viewsViewCollection.forEach { (view) in
            
            let index = viewsViewCollection.firstIndex{$0 as? UIView === view as? UIView }
            
            //               if let componentModel = componentModel as? CAComponentModel {
            //                   let attributesDict: [String: Any]? = componentModel.value(forAttributeKey: "view_\(index!)", withModel: componentDataSourceModel) as? [String : Any]
            
            switch (view as! UIView).tag {
                
            case ItemTag.View.consumptionCastCollection, ItemTag.View.consumptionCreatorCollection, ItemTag.View.consumptionLanguagesSubtitlesCollection:
                if let tmpView = view as? UICollectionView {
                    
                    tmpView.delegate = self
                    tmpView.dataSource = self
                    
                    tmpView.register(HybridViewTitleSubtitleCell.self, forCellWithReuseIdentifier: "HybridViewTitleSubtitleCell")
                    
                    guard self.currentPlayableItem != nil else {
                        return
                    }
                    
                    setupDataSources()
                    tmpView.reloadData()
                }
            case ItemTag.View.consumptionCastCollectionStackView, ItemTag.View.consumptionCreatorCollectionStackView, ItemTag.View.consumptionLanguagesSubtitlesCollectionStackView:
                
                guard self.currentPlayableItem != nil else {
                    return
                }
                setupDataSources()
                
                switch (view as! UIView).tag {
                case ItemTag.View.consumptionCastCollectionStackView:
                    //remove cast collection view from the stack view if it is empty
                    if castDataSource == nil || castDataSource?.count == 0 {
                        (view as! UIStackView).removeFromSuperview()
                    }
                case ItemTag.View.consumptionCreatorCollectionStackView:
                    //remove creators collection view from the stack view if it is empty
                    if creatorsDataSource == nil || creatorsDataSource?.count == 0 {
                        (view as! UIStackView).removeFromSuperview()
                    }
                case ItemTag.View.consumptionLanguagesSubtitlesCollectionStackView:
                    //remove languages & subtitles collection view from the stack view if it is empty
                    if languagesSubtitlesDataSource == nil || languagesSubtitlesDataSource?.count == 0 {
                        (view as! UIStackView).removeFromSuperview()
                    }
                default: break
                }
            case ItemTag.View.consumptionContentView:
                consumptionContentView = view as? UIView
            case ItemTag.View.consumptionButtonsView:
                
                guard let buttonsBackgroundStyle = ZAAppConnector.sharedInstance().layoutsStylesDelegate.styleParams?(byStyleName: "consumption_bg_buttons"),
                    let color = buttonsBackgroundStyle["color"] as? UIColor else {
                        return
                }
                (view as! UIStackView).addBackground(color: color)
                
            default:
                break
            }
        }
        //           }
    }
    
    //MARK:
    
    private func secondsToHoursMinutesSeconds (seconds : Int) -> (Int?, Int?, Int?) {
        return ((seconds / 3600) > 1 ? (seconds / 3600) : nil, ((seconds % 3600) / 60) > 1 ? ((seconds % 3600) / 60) : nil, ((seconds % 3600) % 60) > 1 ? ((seconds % 3600) % 60) : nil)
    }
    
    
    private func stylesFor(key: String) -> (font: UIFont, color: UIColor) {
        
        guard let style = ZAAppConnector.sharedInstance().layoutsStylesDelegate.styleParams?(byStyleName: key),
            let color = style["color"] as? UIColor,
            let font = style["font"] as? UIFont else {
                return (font: UIFont.systemFont(ofSize: 14), color: UIColor.white)
        }
        
        return (font: font, color: color)
    }
    
    
    //MARK: button actions
    
    @objc func watchlistButtonAction(_ sender: CAButton) {
        
        guard self.currentPlayableItem != nil else {
            return
        }
        
        //add / remove item from watchlist
        
        let completionBlock: (CAButton) -> () = { sender in
            
            DispatchQueue.main.async {
                sender.isSelected = !sender.isSelected
                
                let favouriteStyle = self.stylesFor(key: "consumption_text_indicator")
                let favouriteImageNormal = ZAAppConnector.sharedInstance().image(forAsset: "consumption_favourite")
                let favouriteImageSelected = ZAAppConnector.sharedInstance().image(forAsset: "consumption_favourite")?.imageColoredIn(with: favouriteStyle.color)
                
                sender.setImage(sender.isSelected ? favouriteImageSelected : favouriteImageNormal, for: .normal)
            }
        }
        
        if sender.isSelected {
            let assetType: NSNumber = NSNumber(value: currentPlayableItem?.extensionsDictionary![ExtensionsKey.assetType] as! Int)
            deleteWatchlist(withId: currentPlayableItem!.identifier as! String, assetType: assetType.stringValue) { (model) in
                print(model)
                if let code = model.code, code == 1 {
                    completionBlock(sender)
                }
            }
        } else {
            addItemToWatchlist { (model) in
                if let code = model.code, code == 1 {
                    completionBlock(sender)
                }
            }
        }
    }
    
    @objc func consumptionCastButtonAction(_ sender: CAButton) {
        
    }
    
    @objc func consumptionDownloadButtonAction(_ sender: CAButton) {
        
    }
    
    @objc func consumptionMoreLessDescriptionButtonAction(_ sender: CAButton) {
        sender.isSelected = !sender.isSelected
        sender.setImage(ZAAppConnector.sharedInstance().image(forAsset: sender.isSelected ? "consumption_arrow_up" : "consumption_arrow_down"), for: [.normal, .selected])
        
        //change height of parent view
        let oldDescrSizeHeight: CGFloat = self.itemDescriptionLabel!.intrinsicContentSize.height
        self.itemDescriptionLabel!.numberOfLines = sender.isSelected ? 0 : 2
        let newDescrSizeHeight: CGFloat = self.itemDescriptionLabel!.intrinsicContentSize.height
        let diff = newDescrSizeHeight - oldDescrSizeHeight
        let totalHeight: CGFloat = self.consumptionContentView!.frame.size.height + diff
        
        NotificationCenter.default.post(name: Notification.Name("kConsumptionCellLayoutHeightChangedNotification"), object: totalHeight)
    }
    
    @objc func consumptionTrailerButtonAction(_ sender: CAButton) {
        
        //show trailer in new consumption screen
        if let trailerDeeplink = currentPlayableItem?.extensionsDictionary?[ExtensionsKey.trailerDeeplink] {
            let url: URL = URL(string: trailerDeeplink as! String)!
            UIApplication.shared.openURL(url)
        }
    }
    @objc func shareButtonAction(_ sender: CAButton){
        
        var newAtomEntry: APAtomEntry!
        var atom: APAtomEntryProtocol?
        
        if let currentPlayableItem = self.currentPlayableItem as? APAtomEntryPlayable,
            let atomEntry = currentPlayableItem.atomEntry {
            atom = atomEntry
            if let link = atomEntry.link {
                newAtomEntry = APAtomEntry.linkEntry(withURLString: link)
            }
        }
        
        guard newAtomEntry != nil else {
            return
        }
        
        guard let urlComponents = URLComponents(string: newAtomEntry.link) else {
            return
        }
        
        newAtomEntry.link = urlComponents.string
        newAtomEntry.title = atom!.title
        newAtomEntry.entryType = atom!.entryType
        
        APSocialSharingManager.sharedInstance().shareWithDefaultText(withModel: newAtomEntry, andSharingType: APSharingViaNativeType)
        
        // Send analytics:
        let parameters = [
            "sharingType" : "native",
            "location"    : "iOS Unknown"
        ]
        
        NotificationCenter.default.post(name: NSNotification.Name.caCellTappedShareButton, object: newAtomEntry, userInfo: parameters as [AnyHashable : Any])
        
    }
    
    //MARK: main info sting
    
    private func consumptionMainInfoLabel() -> String? {
        
        guard self.currentPlayableItem != nil, let extensions = self.currentPlayableItem!.extensionsDictionary else {
            return nil
        }
        
        var mainInfostring: String = String()
        
        var release: String?
        if let extraData: [String: Any] = (extensions[ExtensionsKey.extraData] as? [String: Any]) {
            release = extraData[ExtensionsKey.releaseYear] as? String
        }
        if release == nil {
            release = extensions[ExtensionsKey.releaseYear] as? String
        }
        let duration: String? = extensions[ExtensionsKey.duration] as? String
        var genre: String?
        if let mainGenre: [String: Any] = (extensions[ExtensionsKey.mainGenre] as? [String: Any]) {
            genre = mainGenre["value"] as? String
        }
        if genre == nil {
            if let genres = (extensions[ExtensionsKey.genres] as? [[String: Any]]), genres.count > 0 {
                genre = genres.first!["value"] as? String
            }
        }
        let age: String? = extensions[ExtensionsKey.ageRating] as? String
        
        var rating: String?
        if let ratingNumber: NSNumber = extensions[ExtensionsKey.rating] as? NSNumber {
            rating = ratingNumber.stringValue
        }
        var episodeNumber: String?
        var totalEpisodes: String?
        if let seasonDetails: [String: Any] = (extensions[ExtensionsKey.seasonDetails] as? [String: Any]) {
            episodeNumber = seasonDetails[ExtensionsKey.currentEpisode] as? String
            totalEpisodes = seasonDetails[ExtensionsKey.totalEpisodes] as? String
        }
        let owner: String? = extensions[ExtensionsKey.contentOwner] as? String
        let primaryCategory: String? = extensions[ExtensionsKey.primaryCategory] as? String
        
        if let feedType = consumptionFeedType {
            switch feedType {
            case .movie, .trailer, .show, .original:
                mainInfostring = "\(feedType.rawValue) • " + createInfoString(with: [release, duration, genre, age])
            case .episode:
                mainInfostring = (totalEpisodes != nil ? "\(totalEpisodes!) Episodes • " : "Episode • ") + createInfoString(with: [release, genre, age])
            case .news:
                mainInfostring = createInfoString(with: [owner, genre, release, duration])
            case .music:
                mainInfostring = "Videos • " + createInfoString(with: [duration, genre, age])
            case .live:
                mainInfostring = "Episode • " + createInfoString(with: [episodeNumber])
            }
            if rating != nil {
                mainInfostring.append(mainInfostring.isEmptyOrWhitespace() ? "IMDb" : " • IMDb")
            }
        } else {
            mainInfostring = createInfoString(with: [primaryCategory, release, duration, genre, age])
        }
        
        return mainInfostring
    }
    
    private func createInfoString(with array: [String?]) -> String {
        var tmpString = String()
        
        for item in array {
            if let item = item {
                if tmpString.isEmptyOrWhitespace() {
                    tmpString.append("\(item)")
                } else {
                    tmpString.append(" • \(item)")
                }
            }
        }
        return tmpString
    }
    
    
    //MARK: add / remove element from the watchlist
    
    private func deleteWatchlist(withId id:String, assetType:String, completion: @escaping ((SuccessDataModel)->())) {
        
        let accessToken = Zee5UserDefaultsManager.shared.getUserAccessToken()
        if accessToken.count > 0 {
            let requestLoader = ZEE5RequestLoader(apiRequest: DeleteWatchListApiRequest())
            requestLoader.loadAPIRequest(request: HTTPMethod.delete, funcion: ZEE5ApiEndPoints.deleteFromWatchList(id: id, assetType: assetType), requestData: nil, requestHeaders: ["Authorization":accessToken]) { (response, error) in
                if let error = error {
                    print(error)
                    return
                }
                completion(response!)
            }
        }
    }
    
    private func getWatchlist(completion: @escaping ((WatchListDataModel)->())) {
        
        let accessToken = Zee5UserDefaultsManager.shared.getUserAccessToken()
        if accessToken.count > 0 {
            let requestLoader = ZEE5RequestLoader(apiRequest: WatchListApiRequest())
            requestLoader.loadAPIRequest(request: HTTPMethod.get, funcion: ZEE5ApiEndPoints.watchList(country: Zee5UserDefaultsManager.shared.getCountryDetailsFromCountryResponse().country, translation: Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage() ?? String()), requestData: nil, requestHeaders: ["Authorization":accessToken]) { (response, error) in
                if let error = error {
                    print(error)
                    return
                }
                completion(response!)
            }
        }
    }
    
    private func addItemToWatchlist(completion: @escaping ((SuccessDataModel)->())) {
        
        let accessToken = Zee5UserDefaultsManager.shared.getUserAccessToken()
        if accessToken.count > 0 {
            let requestLoader = ZEE5RequestLoader(apiRequest: UpdateWatchListApiRequest())
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let date: String = formatter.string(from: Date())
            
            requestLoader.loadAPIRequest(request: HTTPMethod.post, funcion: ZEE5ApiEndPoints.addToWatchList, requestData: ["id": currentPlayableItem?.identifier, ExtensionsKey.assetType: currentPlayableItem?.extensionsDictionary![ExtensionsKey.assetType], ExtensionsKey.duration: currentPlayableItem?.extensionsDictionary![ExtensionsKey.duration], "date": date], requestHeaders: ["Authorization":accessToken]) { (response, error) in
                if let error = error {
                    print(error)
                    return
                }
                completion(response!)
            }
        }
    }
}

//MARK: extension

extension HybridViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView.tag {
        case ItemTag.View.consumptionCastCollection:
            return castDataSource?.count ?? 0
        case ItemTag.View.consumptionCreatorCollection:
            return creatorsDataSource?.count ?? 0
        case ItemTag.View.consumptionLanguagesSubtitlesCollection:
            return languagesSubtitlesDataSource?.count ?? 0
        default:
            break
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HybridViewTitleSubtitleCell", for: indexPath) as? HybridViewTitleSubtitleCell  else {
            return UICollectionViewCell()
        }
        
        var dataSource: [(title: String?, subtitle: String?, description: String?)]?
        var textAlignment: NSTextAlignment!
        switch collectionView.tag {
        case ItemTag.View.consumptionCastCollection:
            dataSource = castDataSource
            textAlignment = .center
        case ItemTag.View.consumptionCreatorCollection:
            dataSource = creatorsDataSource
            textAlignment = .center
            
        case ItemTag.View.consumptionLanguagesSubtitlesCollection:
            dataSource = languagesSubtitlesDataSource
            textAlignment = .left
        default:
            break
        }
        if dataSource != nil {
            
            let model = dataSource![indexPath.row]
            
            cell.data = model
            cell.titleLabel.textAlignment = textAlignment
            cell.subtitleLabel.textAlignment = textAlignment
            
            let descriptionStyle = stylesFor(key: "consumption_text_description")
            let indicatorStyle = stylesFor(key: "consumption_text_indicator")
            let visibilityStyle = stylesFor(key: "consumption_visibility_text")
            
            switch collectionView.tag {
            case ItemTag.View.consumptionCastCollection, ItemTag.View.consumptionCreatorCollection:
                
                cell.titleLabel.textColor = descriptionStyle.color
                cell.titleLabel.font = descriptionStyle.font
                cell.subtitleLabel.textColor = indicatorStyle.color
                cell.subtitleLabel.font = indicatorStyle.font
                
            case ItemTag.View.consumptionLanguagesSubtitlesCollection:
                
                let title = NSMutableAttributedString(string: model.title ?? String(), attributes: [NSAttributedString.Key.foregroundColor: descriptionStyle.color, NSAttributedString.Key.font: descriptionStyle.font])
                let subtitle = NSAttributedString.init(string: model.subtitle ?? String(), attributes: [NSAttributedString.Key.foregroundColor: indicatorStyle.color, NSAttributedString.Key.font: indicatorStyle.font])
                title.append(subtitle)
                cell.titleLabel.attributedText = title
                cell.subtitleLabel.textColor = visibilityStyle.color
                cell.subtitleLabel.font = visibilityStyle.font
            default:
                break
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screen = UIScreen.main.bounds.width
        switch collectionView.tag {
        case ItemTag.View.consumptionCastCollection:
            return CGSize(width: screen/3, height: collectionView.frame.size.height)
        case ItemTag.View.consumptionCreatorCollection:
            return CGSize(width: screen/3, height: collectionView.frame.size.height)
        case ItemTag.View.consumptionLanguagesSubtitlesCollection:
            return CGSize(width: screen/2, height: collectionView.frame.size.height)
        default: break
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case ItemTag.View.consumptionLanguagesSubtitlesCollection:
            if languagesSubtitlesDataSource![indexPath.row] == languagesSubtitlesDataSource!.first! { //languages button action
                //TODO: show langiages sheet
            } else { // subtitles button action
                //TODO: show subtitles sheet
            }
            break
        default: break
        }
    }
}

extension ZAAppConnector {
    func image(forAsset asset: String?) -> UIImage? {
        guard let asset = asset else {
            return nil
        }
        
        if let image = UIImage(named: asset) {
            return image
        }
        else { return nil }
    }
}

extension CAButton {
    
    enum ImageTitleRelativeLocation {
        case imageUpTitleDown
        case imageDownTitleUp
        case imageLeftTitleRight
        case imageRightTitleLeft
    }
    func centerContentRelativeLocation(_ relativeLocation:
        ImageTitleRelativeLocation,
                                       spacing: CGFloat = 0) {
        assert(contentVerticalAlignment == .center,
               "only works with contentVerticalAlignment = .center !!!")
        
        guard (title(for: .normal) != nil) || (attributedTitle(for: .normal) != nil) else {
            //assert(false, "TITLE IS NIL! SET TITTLE FIRST!")
            return
        }
        
        guard let imageSize = self.currentImage?.size else {
            //assert(false, "IMGAGE IS NIL! SET IMAGE FIRST!!!")
            return
        }
        guard let titleSize = titleLabel?
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) else {
                //assert(false, "TITLELABEL IS NIL!")
                return
        }
        
        let horizontalResistent: CGFloat
        // extend contenArea in case of title is shrink
        if frame.width < titleSize.width + imageSize.width {
            horizontalResistent = titleSize.width + imageSize.width - frame.width
            print("horizontalResistent", horizontalResistent)
        } else {
            horizontalResistent = 0
        }
        
        var adjustImageEdgeInsets: UIEdgeInsets = .zero
        var adjustTitleEdgeInsets: UIEdgeInsets = .zero
        var adjustContentEdgeInsets: UIEdgeInsets = .zero
        
        let verticalImageAbsOffset = abs((titleSize.height + spacing) / 2)
        let verticalTitleAbsOffset = abs((imageSize.height + spacing) / 2)
        
        switch relativeLocation {
        case .imageUpTitleDown:
            
            adjustImageEdgeInsets.top = -verticalImageAbsOffset
            adjustImageEdgeInsets.bottom = verticalImageAbsOffset
            adjustImageEdgeInsets.left = titleSize.width / 2 + horizontalResistent / 2
            adjustImageEdgeInsets.right = -titleSize.width / 2 - horizontalResistent / 2
            
            adjustTitleEdgeInsets.top = verticalTitleAbsOffset
            adjustTitleEdgeInsets.bottom = -verticalTitleAbsOffset
            adjustTitleEdgeInsets.left = -imageSize.width / 2 + horizontalResistent / 2
            adjustTitleEdgeInsets.right = imageSize.width / 2 - horizontalResistent / 2
            
            adjustContentEdgeInsets.top = spacing
            adjustContentEdgeInsets.bottom = spacing
            adjustContentEdgeInsets.left = -horizontalResistent
            adjustContentEdgeInsets.right = -horizontalResistent
        case .imageDownTitleUp:
            adjustImageEdgeInsets.top = verticalImageAbsOffset
            adjustImageEdgeInsets.bottom = -verticalImageAbsOffset
            adjustImageEdgeInsets.left = titleSize.width / 2 + horizontalResistent / 2
            adjustImageEdgeInsets.right = -titleSize.width / 2 - horizontalResistent / 2
            
            adjustTitleEdgeInsets.top = -verticalTitleAbsOffset
            adjustTitleEdgeInsets.bottom = verticalTitleAbsOffset
            adjustTitleEdgeInsets.left = -imageSize.width / 2 + horizontalResistent / 2
            adjustTitleEdgeInsets.right = imageSize.width / 2 - horizontalResistent / 2
            
            adjustContentEdgeInsets.top = spacing
            adjustContentEdgeInsets.bottom = spacing
            adjustContentEdgeInsets.left = -horizontalResistent
            adjustContentEdgeInsets.right = -horizontalResistent
        case .imageLeftTitleRight:
            adjustImageEdgeInsets.left = -spacing / 2
            adjustImageEdgeInsets.right = spacing / 2
            
            adjustTitleEdgeInsets.left = spacing / 2
            adjustTitleEdgeInsets.right = -spacing / 2
            
            adjustContentEdgeInsets.left = spacing
            adjustContentEdgeInsets.right = spacing
        case .imageRightTitleLeft:
            adjustImageEdgeInsets.left = titleSize.width + spacing / 2
            adjustImageEdgeInsets.right = -titleSize.width - spacing / 2
            
            adjustTitleEdgeInsets.left = -imageSize.width - spacing / 2
            adjustTitleEdgeInsets.right = imageSize.width + spacing / 2
            
            adjustContentEdgeInsets.left = spacing
            adjustContentEdgeInsets.right = spacing
        }
        
        imageEdgeInsets = adjustImageEdgeInsets
        titleEdgeInsets = adjustTitleEdgeInsets
        contentEdgeInsets = adjustContentEdgeInsets
        
        setNeedsLayout()
    }
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}