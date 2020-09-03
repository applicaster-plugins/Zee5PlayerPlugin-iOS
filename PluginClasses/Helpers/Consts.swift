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
    case channel = "Channel"
}

public enum PlayableBusinessType: String, CaseIterable {
    case premiumDownloadable = "premium_downloadable"
    case advertisementDownloadable = "advertisement_downloadable"
    case freeDownloadable = "free_downloadable"
    case premium = "premium"
    case advertisement = "advertisement"
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
    static let seasons = "seasons"
    static let seasonDetails = "season_details"
    static let currentEpisode = "current_episode"
    static let totalEpisodes = "total_episodes"
    static let contentOwner = "content_owner"
    static let leftDuration = "leftDuration"
    static let numberTagText = "numberTagText"
    static let upNext = "upNext"
    static let openWithPluginId = "open_with_plugin_id"
    static let actors = "actors"
    static let creators = "creators"
    static let languages = "languages"
    static let subtitleLanguages = "subtitle_languages"
    static let primaryCategory = "primary_category"
    static let isReminder = "is_reminder"
    static let releaseDate = "release_date"
    static let screenName = "screen_name"
    static let itemDetailsUrl = "item_details_url"
    static let relatedContent = "relatedContent"
    static let related = "related"
    static let shareLink = "share_link"
    static let businessType = "business_type"
    static let published = "published"
    static let title = "title"
    static let description = "description"
    static let contentId = "id"
    static let tvShowDetails = "tvshow_details"
    static let trailers = "trailers"
    static let isDrm = "is_drm"
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
        static let consumptionVideoContainerView = 857
        
        static let consumptionContentView = 870
        static let consumptionButtonsView = 871
        
        static let adsBanner = 880
        static let premiumBanner = 881
    }
    struct Label {
        
        static let searchBarErrorLabel = 837
        
        static let numberTagLabel = 115
        static let episodeNumberAndDateLabel = 120
        
        static let consumptionTitleLabel = 800
        static let consumptionIMDBRatingLabel = 802
        static let consumptionAvailableInLabel = 803
        static let consumptionDescriptionLabel = 825
        static let consumptionCastLabel = 804
        static let consumptionCreatorsLabel = 805
        
        static let releasingOnLabel = 835
        static let storyLineLabel = 836
    }
}

class ExtensionsHelper {
    static func isLive(_ consumptionFeedType: ConsumptionFeedType) -> Bool {
        return consumptionFeedType == .live || consumptionFeedType == .channel
    }
    
    static func isDownloadable(_ consumptionFeedType: ConsumptionFeedType, _ buisnessType: PlayableBusinessType) -> Bool {
        return  !isLive(consumptionFeedType) &&
                (buisnessType == .premiumDownloadable || buisnessType == .freeDownloadable || buisnessType == .advertisementDownloadable)

    }
}
