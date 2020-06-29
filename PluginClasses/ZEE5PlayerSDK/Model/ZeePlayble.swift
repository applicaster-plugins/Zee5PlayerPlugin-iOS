//
//  ZeePlayble.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 21.06.20.
//

import Foundation

class ZeePlayable {
    typealias Extensions = [String: Any]
    typealias DefaultDict = [String: Any]
    typealias SeasonDetails = (episodeNumber: String?, totalEpisodes: String?)
    typealias AudioTrack = String
    typealias TextTrack = String

    let extensions: Extensions
    
    init(_ extensions: Extensions) {
        self.extensions = extensions
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
        
        if let mainGenre = self.extensions[ExtensionsKey.mainGenre] as? Extensions {
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
    
    public var seasonDetails: SeasonDetails? {
        var result: SeasonDetails? = nil
        
        if let seasonDetails = self.extensions[ExtensionsKey.seasonDetails] as? Extensions {
            result = SeasonDetails(
                seasonDetails[ExtensionsKey.currentEpisode] as? String,
                seasonDetails[ExtensionsKey.totalEpisodes] as? String
            )
        }
        
        return result
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
}
