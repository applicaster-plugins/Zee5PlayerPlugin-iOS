//
//  ZeePlayble.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 21.06.20.
//

import Foundation

class ZeePlayable {
    typealias Extensions = [AnyHashable: Any]
    typealias DefaultDict = [String: Any]
    typealias Episode = (contentId: String?, title: String?)
    typealias ParentSeasonDetails = (episodeNumber: String?, totalEpisodes: String?)
    typealias Season = (contentId: String?, episodes: [Episode]?)
    typealias AudioTrack = String
    typealias TextTrack = String
    typealias CastMember = (actor: String, character: String)
    typealias Creator = (name: String, title: String)

    let extensions: Extensions
    
    init(_ extensions: Extensions) {
        self.extensions = extensions
    }
    
    public var contentId: String? {
        return self.extensions[ExtensionsKey.contentId] as? String
    }
    
    public var title: String? {
        return self.extensions[ExtensionsKey.title] as? String
    }
   
    public var description: String? {
        return self.extensions[ExtensionsKey.description] as? String
    }
    
    public var assetType: Int? {
        return self.extensions[ExtensionsKey.assetType] as? Int
    }
    
    public var assetSubtype: String? {
        return self.extensions[ExtensionsKey.assetSubtype] as? String
    }
    public var isDrm: Int? {
        return self.extensions[ExtensionsKey.isDrm] as? Int
    }
    
    public var consumptionType: ConsumptionFeedType {
        guard let type = self.assetType else {
            return .video
        }
        
        if (type == 9) {
            return .live
        }
        
        guard let subtype = self.assetSubtype else {
            return .video
        }
        
        switch subtype {
        case "trailer", "promo":
            return .trailer
            
        case "movie":
            return .movie
            
        case "episode":
            if let showDetails = self.extensions["tvshow_details"] as? DefaultDict, let showType = showDetails["asset_subtype"] as? String {
                if showType == "tvshow" {
                    return .episode
                }
                
                if showType == "original" {
                    return .original
                }
            }
            
            return .video
            
        case "video":
            guard let genres = self.extensions[ExtensionsKey.genres] as? [DefaultDict] else {
                return .video
            }
            
            for genre in genres {
                guard let value = genre["value"] as? String else {
                    continue
                }
                
                switch value.lowercased() {
                case "music":
                    return .music
                case "news":
                    return .news
                default:
                    break
                }
            }
            
        default:
            break
        }
        
        return .video
    }
    
    public var isFree: Bool {
        var result = true
        
        if let isFreeValue = self.extensions[ExtensionsKey.isFree] as? Bool {
            result = isFreeValue
        }
        
        return result
    }
    
    public var releaseYear: String? {
        var result: String? = nil
        
        if let extraData = self.extensions[ExtensionsKey.extraData] as? DefaultDict {
            result = extraData[ExtensionsKey.releaseYear] as? String
        }
        
        if result == nil {
            result = self.extensions[ExtensionsKey.releaseYear] as? String
        }
        
        return result
    }
    
    public var duration: Int? {
        return self.extensions[ExtensionsKey.duration] as? Int
    }
    
    public var published: String? {
        return self.extensions[ExtensionsKey.published] as? String
    }
    
    public var genre: String? {
        var result: String? = nil
        
        if let mainGenre = self.extensions[ExtensionsKey.mainGenre] as? DefaultDict {
            result = mainGenre["value"] as? String
        }
        
        if result == nil {
            if let genres = self.extensions[ExtensionsKey.genres] as? [DefaultDict] {
                result = genres.first?["value"] as? String
            }
        }
        
        return result
    }
    
    public var age: String? {
        return self.extensions[ExtensionsKey.ageRating] as? String
    }
    
    public var rating: String? {
        var result: String? = nil

        if let ratingNumber = self.extensions[ExtensionsKey.rating] as? NSNumber {
            result = ratingNumber.stringValue
        }
        
        return result
    }
    
    public var parentSeasonDetails: ParentSeasonDetails? {
        var result: ParentSeasonDetails? = nil
        
        if let seasonDetails = self.extensions[ExtensionsKey.seasonDetails] as? DefaultDict {
            result = ParentSeasonDetails(
                seasonDetails[ExtensionsKey.currentEpisode] as? String,
                seasonDetails[ExtensionsKey.totalEpisodes] as? String
            )
        }
        
        return result
    }
    
    public var latestEpisode: Episode? {
        guard let seasons = self.extensions[ExtensionsKey.seasons] as? [DefaultDict] else {
            return nil
        }
        
        let latestSeason = seasons.max { (season1, season2) -> Bool in
            let season1Index = season1["index"] as? Int ?? 0
            let season2Index = season2["index"] as? Int ?? 0

            return season1Index < season2Index
        }
        
        let Episodes = (latestSeason?["episodes"] as? [DefaultDict])
        if ((Episodes?.count) == 0) {
            if let Promos = latestSeason?["promos"] as? [DefaultDict] {
                if Promos.count > 0 {
                    let latestPromo = Promos[0]
                    return Episode(contentId: latestPromo["id"] as? String, title: latestPromo["title"] as? String)
                }
            }
            return nil
        }
       let latestEpisode = Episodes?[0]

        guard let result = latestEpisode else {
            return nil
        }
        
        return Episode(contentId: result["id"] as? String, title: result["title"] as? String)
    }
    
    public var releaseDate: String? {
        return self.extensions[ExtensionsKey.releaseDate] as? String
    }
    
    public var numberTag: Int? {
        return self.extensions[ExtensionsKey.numberTagText] as? Int
    }
    
    public var owner: String? {
        return self.extensions[ExtensionsKey.contentOwner] as? String
    }
    
    public var primaryCategory: String? {
        return self.extensions[ExtensionsKey.primaryCategory] as? String
    }
    
    public var audioTracks: [AudioTrack]? {
        return self.extensions[ExtensionsKey.languages] as? [AudioTrack]
    }
    
    public var textTracks: [TextTrack]? {
        return self.extensions[ExtensionsKey.subtitleLanguages] as? [TextTrack]
    }
    
    public var cast: [CastMember]? {
        guard let cast = self.extensions[ExtensionsKey.actors] as? [String] else {
            return nil
        }
        
        var result = [CastMember]()
        
        for castMember in cast {
            let values = castMember.components(separatedBy: ":")
            guard values.count > 1 else {
                continue
            }
            
            result.append(CastMember(values[0], values[1]))
        }
        
        return result
    }
    
    public var creators: [Creator]? {
        return self.extensions[ExtensionsKey.creators] as? [Creator]
    }
    
    public var trailerContentId: String? {
        var items: [DefaultDict]?
        
        if let tvshowDetails = self.extensions[ExtensionsKey.tvShowDetails] as? DefaultDict,
            let trailerItems = tvshowDetails[ExtensionsKey.trailers] as? [DefaultDict] {
            items = trailerItems
        } else if let relatedItems = self.extensions[ExtensionsKey.related] as? [DefaultDict] {
            items = relatedItems
        }
        
        guard let unwrappedItems = items else {
            return nil
        }
        
        for item in unwrappedItems {
            guard
                let assetSubtype = item["asset_subtype"] as? String,
                assetSubtype == "trailer",
                let contentId = item["id"] as? String else {
                    continue
            }
            
            return contentId
        }
        
        return nil
    }
    
    public var businessType: PlayableBusinessType {
        guard let value = self.extensions["business_type"] as? String else {
            return .freeDownloadable
        }
        
        return PlayableBusinessType(rawValue: value) ?? .freeDownloadable
    }
}
