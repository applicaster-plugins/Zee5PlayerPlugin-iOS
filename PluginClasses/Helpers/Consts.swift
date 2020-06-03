//
//  Consts.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 14.04.20.
//

import Foundation

public enum ConsumptionFeedType: String, CaseIterable {
    case movie = "Movie"
    case episode = "Episode"
    case news = "News"
    case music = "Music"
    case live = "Live"
    case trailer = "Trailer"
    case show = "Show"
    case original = "Original"
    case video = "Video"
    case channel = "channel"

    init?(type: ConsumptionType) {
        switch type {
        case Movie:
            self = .movie
        case Episode:
            self = .episode
        case Shows:
            self = .show
        case Trailer:
            self = .trailer
        case Live:
            self = .live
        case Music:
            self = .music
        case Original:
            self = .original
        case Video:
            self = .video
        default:
            return nil
        }
    }
}

public struct ExtensionsKey {
    static let consumptionFeedType = "consumption_feed_type"
    static let isFree = "isFree"
    static let trailerDeeplink = "trailer_deeplink"
    static let playProgress = "playProgress"
    static let promotedUrl = "promoted_url"
    static let durationDate = "durationDate"
    static let assetType = "asset_type"
    static let assetSubtype = "asset_subtype"
    static let rating = "rating"
    static let extraData = "extra_data"
    static let releaseYear = "release_year"
    static let duration = "duration"
    static let mainGenre = "main_genre"
    static let genres = "genres"
    static let ageRating = "age_rating"
    static let seasonDetails = "season_details"
    static let currentEpisode = "current_episode"
    static let totalEpisodes = "total_episodes"
    static let contentOwner = "content_owner"
    static let leftDuration = "leftDuration"
    static let numberTagText = "numberTagText"
    static let upNext = "upNext"
    static let openWithPluginId = "open_with_plugin_id"
    static let cast = "cast"
    static let creators = "creators"
    static let languages = "languages"
    static let subtitleLanguages = "subtitle_languages"
    static let primaryCategory = "primary_category"
    static let isReminder = "is_reminder"
    static let releaseDate = "release_date"
    static let screenName = "screen_name"
    static let itemDetailsUrl = "item_details_url"
    static let relatedContent = "relatedContent"
    static let shareLink = "share_link"
    static let businessType = "business_type"
}

public struct ItemTag {
    struct Button {
        static let playImage = 109
        static let clearButton = 110
        static let getPremiumButton = 111
        static let searchBarCleanButton = 116
        static let searchBarBackButton = 117
        static let consumptionMoreButton = 117
        
        static let shareButton = 806
        static let watchlistButton = 807
        static let castButton = 808
        static let downloadButton = 809
        static let trailerButton = 810
        
        static let consumptionMoreLessDescriptionButton = 823
        
        static let reminderButton = 824
    }
    struct Image {
        static let premiumImage = 112
        static let top10Image = 113
    }
    struct View {
        static let progressBarView = 114
        static let searchBarTextField = 118
        
        static let consumptionCastCollection = 827
        static let consumptionCastCollectionStackView = 828
        static let consumptionCreatorCollection = 830
        static let consumptionCreatorCollectionStackView = 831
        static let consumptionLanguagesSubtitlesCollection = 855
        static let consumptionLanguagesSubtitlesCollectionStackView = 856
        static let consumptionVideoContainerView = 857
        
        static let consumptionContentView = 870
        static let consumptionButtonsView = 871
        
        static let adsBanner = 880
        static let premiumBanner = 881
    }
    struct Label {
        
        static let searchBarErrorLabel = 837
        
        static let numberTagLabel = 115
        static let timeLeftLabel = 119
        static let episodeNumberAndDateLabel = 120
        static let upNextLabel = 121
        static let timeFromToLabel = 122
        
        static let consumptionTitleLabel = 800
        static let consumptionMainInfoLabel = 801
        static let consumptionIMDBRatingLabel = 802
        static let consumptionAvailableInLabel = 803
        static let consumptionDescriptionLabel = 825
        static let consumptionCastLabel = 804
        static let consumptionCreatorsLabel = 805
        
        static let releasingOnLabel = 835
        static let storyLineLabel = 836
    }
}

public class ExtensionsHelper {
    public static func isPlaybleFree(_ extensions: [String: Any]) -> Bool {
        var result = true
        
        if let isFreeValue = extensions[ExtensionsKey.isFree] as? Bool {
            result = isFreeValue
        }
        
        return result
    }
}
