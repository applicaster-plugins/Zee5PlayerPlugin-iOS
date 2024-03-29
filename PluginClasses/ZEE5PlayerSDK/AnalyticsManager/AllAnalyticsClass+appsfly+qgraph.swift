//
//  AllAnalyticsClass+appsfly+qgraph.swift
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 16/04/20.
//

import Foundation
import Zee5CoreSDK

extension AllAnalyticsClass{
    
    var source:String {
        return UserDefaults.standard.string(forKey: "analyticsSource") ?? "N/A"
    }
    var currently_tab:String {
        return UserDefaults.standard.string(forKey: "currentlyTab") ?? "N/A"
    }
    var carousal_name:String {
        return UserDefaults.standard.string(forKey: "carousal_name") ?? "N/A"
    }
    var carousal_id:String {
        return UserDefaults.standard.string(forKey: "carousal_id") ?? "N/A"
    }
    var vertical_index:String {
        return UserDefaults.standard.string(forKey: "vertical_index") ?? "N/A"
    }
    var horizontal_index:String {
        return UserDefaults.standard.string(forKey: "horisontal_index") ?? "N/A"
    }
    var preview_status:String {
        return UserDefaults.standard.string(forKey: "preview_status") ?? "N/A"
    }
    var talamoos_click_id:String {
        return UserDefaults.standard.string(forKey: "talamoos_click_id") ?? "N/A"
    }
    var talamoos_origin:String {
        return UserDefaults.standard.string(forKey: "talamoos_origin") ?? "N/A"
    }
    var talamoos_model_name:String {
        return UserDefaults.standard.string(forKey: "talamoos_model_name") ?? "N/A"
    }
    var time_spent:TimeInterval {
        return Zee5PlayerPlugin.sharedInstance().player.currentTime
    }
    
    
    //MARK:- AppsFlyer Events
    
  //MARK:- Add to WatchList Event
    
    public func addtoWatchlistEvent()
    {
        videoStarttime = Int(Zee5PlayerPlugin.sharedInstance().player.currentTime)
        let parameter : Set = [
        Keys.ADD_TO_WATCHLIST.SOURCE ~>> source,
        Keys.ADD_TO_WATCHLIST.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
        Keys.ADD_TO_WATCHLIST.ELEMENT ~>> "Add to watch List",
        Keys.ADD_TO_WATCHLIST.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.ADD_TO_WATCHLIST.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
        Keys.ADD_TO_WATCHLIST.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
        Keys.ADD_TO_WATCHLIST.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
        Keys.ADD_TO_WATCHLIST.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
        Keys.ADD_TO_WATCHLIST.SERIES ~>> series == "" ? notAppplicable:series,
        Keys.ADD_TO_WATCHLIST.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
        Keys.ADD_TO_WATCHLIST.CAST_TO ~>> notAppplicable,
        Keys.ADD_TO_WATCHLIST.INTRO_PRESENT ~>> skipIntroTime == "" ? false : true,
        Keys.ADD_TO_WATCHLIST.PAGE_NAME ~>> currently_tab,
        Keys.ADD_TO_WATCHLIST.DRM_VIDEO ~>> DrmVideo,
        Keys.ADD_TO_WATCHLIST.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
        Keys.ADD_TO_WATCHLIST.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.ADD_TO_WATCHLIST.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.ADD_TO_WATCHLIST.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
        Keys.ADD_TO_WATCHLIST.TAB_NAME ~>> currently_tab,
        Keys.ADD_TO_WATCHLIST.TV_CATEGORY ~>> notAppplicable,
        Keys.ADD_TO_WATCHLIST.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
        Keys.ADD_TO_WATCHLIST.CAROUSAL_NAME ~>> carousal_name,
        Keys.ADD_TO_WATCHLIST.CAROUSAL_ID ~>> carousal_id,
        Keys.ADD_TO_WATCHLIST.USER_LOGIN_STATUS ~>> User.shared.getType().rawValue == "" ?notAppplicable:User.shared.getType().rawValue,
        Keys.ADD_TO_WATCHLIST.TRACKING_MODE ~>> notAppplicable,
        Keys.ADD_TO_WATCHLIST.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
        Keys.ADD_TO_WATCHLIST.HORIZONTAL_INDEX ~>> horizontal_index == "" ? notAppplicable:horizontal_index,
        Keys.ADD_TO_WATCHLIST.VERTICAL_INDEX ~>> vertical_index == "" ? notAppplicable:vertical_index,
        ]
         analytics.track(Events.ADD_TO_WATCHLIST, trackedProperties: parameter)
    }
    
    public func removeFromWatchlistEvent()
    {
        
        let parameter : Set = [
        Keys.REMOVE_FROM_WATCHLIST.SOURCE ~>> source,
        Keys.REMOVE_FROM_WATCHLIST.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
        Keys.REMOVE_FROM_WATCHLIST.ELEMENT ~>> "Remove to watch List",
        Keys.REMOVE_FROM_WATCHLIST.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.REMOVE_FROM_WATCHLIST.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
        Keys.REMOVE_FROM_WATCHLIST.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
        Keys.REMOVE_FROM_WATCHLIST.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
        Keys.REMOVE_FROM_WATCHLIST.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
        Keys.REMOVE_FROM_WATCHLIST.SERIES ~>> series == "" ? notAppplicable:series,
        Keys.REMOVE_FROM_WATCHLIST.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
        Keys.REMOVE_FROM_WATCHLIST.CAST_TO ~>> notAppplicable,
        Keys.REMOVE_FROM_WATCHLIST.INTRO_PRESENT ~>> skipIntroTime == "" ? false : true,
        Keys.REMOVE_FROM_WATCHLIST.PAGE_NAME ~>> currently_tab,
        Keys.REMOVE_FROM_WATCHLIST.DRM_VIDEO ~>> DrmVideo,
        Keys.REMOVE_FROM_WATCHLIST.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
        Keys.REMOVE_FROM_WATCHLIST.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.REMOVE_FROM_WATCHLIST.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.REMOVE_FROM_WATCHLIST.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
        Keys.REMOVE_FROM_WATCHLIST.TAB_NAME ~>> currently_tab,
        Keys.REMOVE_FROM_WATCHLIST.TV_CATEGORY ~>> notAppplicable,
        Keys.REMOVE_FROM_WATCHLIST.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
        Keys.REMOVE_FROM_WATCHLIST.CAROUSAL_NAME ~>> carousal_name,
        Keys.REMOVE_FROM_WATCHLIST.CAROUSAL_ID ~>> carousal_id,
        Keys.REMOVE_FROM_WATCHLIST.TRACKING_MODE ~>> notAppplicable,
        Keys.REMOVE_FROM_WATCHLIST.HORIZONTAL_INDEX ~>> horizontal_index == "" ? notAppplicable:horizontal_index,
        Keys.REMOVE_FROM_WATCHLIST.VERTICAL_INDEX ~>> vertical_index == "" ? notAppplicable:vertical_index,
        ]
         analytics.track(Events.REMOVE_FROM_WATCHLIST, trackedProperties: parameter)
    }
    
    public func shareClickEvent()
    {
    
        let parameter : Set = [
        Keys.SHARE.SOURCE ~>> source,
        Keys.SHARE.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
        Keys.SHARE.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.SHARE.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
        Keys.SHARE.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
        Keys.SHARE.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
        Keys.SHARE.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
        Keys.SHARE.SERIES ~>> series == "" ? notAppplicable:series,
        Keys.SHARE.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
        Keys.SHARE.CAST_TO ~>> notAppplicable,
        Keys.SHARE.INTRO_PRESENT ~>> skipIntroTime == "" ? false : true,
        Keys.SHARE.PAGE_NAME ~>> currently_tab,
        Keys.SHARE.DRM_VIDEO ~>> DrmVideo,
        Keys.SHARE.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
        Keys.SHARE.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.SHARE.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.SHARE.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
        Keys.SHARE.TAB_NAME ~>> currently_tab,
        Keys.SHARE.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
        Keys.SHARE.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
        Keys.SHARE.CAROUSAL_NAME ~>> carousal_name,
        Keys.SHARE.CAROUSAL_ID ~>> carousal_id,
        Keys.SHARE.TRACKING_MODE ~>> notAppplicable,
        Keys.SHARE.HORIZONTAL_INDEX ~>> horizontal_index == "" ? notAppplicable:horizontal_index,
        Keys.SHARE.VERTICAL_INDEX ~>> vertical_index == "" ? notAppplicable:vertical_index,
        ]
         analytics.track(Events.SHARE, trackedProperties: parameter)
    }
    
    
    //MARK:- Subscription CTA Button cLicked
    
    public func subscribeBtnClicked(){
        
        let parameter : Set = [
        Keys.CONSUMPTION_SUBSCRIBE_CTA_CLICK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.CONSUMPTION_SUBSCRIBE_CTA_CLICK.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
        Keys.CONSUMPTION_SUBSCRIBE_CTA_CLICK.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
        Keys.CONSUMPTION_SUBSCRIBE_CTA_CLICK.PACK_SELECTED ~>> "",
        Keys.CONSUMPTION_SUBSCRIBE_CTA_CLICK.PACK_ID ~>> notAppplicable,
        ]
         analytics.track(Events.CONSUMPTION_SUBSCRIBE_CTA_CLICK, trackedProperties: parameter)
    }
    
    
    
    
    //MARK:- Qgraph Events

    
    //MARK:- 20% video Play Event
    @objc public func VideoWatch20(){
        
        let parameter : Set = [
            Keys.VIDEO_VIEW_20_PERCENT.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.VIDEO_VIEW_20_PERCENT.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.VIDEO_VIEW_20_PERCENT.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.VIDEO_VIEW_20_PERCENT.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
            Keys.VIDEO_VIEW_20_PERCENT.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.VIDEO_VIEW_20_PERCENT.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId,
            Keys.VIDEO_VIEW_20_PERCENT.SHOW_ID ~>> notAppplicable,
            Keys.VIDEO_VIEW_20_PERCENT.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype
               ]
        analytics.track(Events.VIDEO_VIEW_20_PERCENT, trackedProperties: parameter)
    
       }
    
    //MARK:- 50% video Play Event
    @objc public func VideoWatch50(){
    
        let parameter : Set = [
            Keys.VIDEO_VIEW_50_PERCENT.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.VIDEO_VIEW_50_PERCENT.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.VIDEO_VIEW_50_PERCENT.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.VIDEO_VIEW_50_PERCENT.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
            Keys.VIDEO_VIEW_50_PERCENT.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.VIDEO_VIEW_50_PERCENT.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId,
            Keys.VIDEO_VIEW_50_PERCENT.SHOW_ID ~>> notAppplicable,
            Keys.VIDEO_VIEW_50_PERCENT.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype
                ]
        
            analytics.track(Events.VIDEO_VIEW_50_PERCENT, trackedProperties: parameter)
          }
    //MARK:- 85% video Play Event
    
    @objc public func VideoWatch85(){
        
      let parameter : Set = [
            Keys.VIDEO_VIEW_85_PERCENT.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.VIDEO_VIEW_85_PERCENT.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.VIDEO_VIEW_85_PERCENT.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.VIDEO_VIEW_85_PERCENT.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
            Keys.VIDEO_VIEW_85_PERCENT.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.VIDEO_VIEW_85_PERCENT.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId,
            Keys.VIDEO_VIEW_85_PERCENT.SHOW_ID ~>> notAppplicable,
            Keys.VIDEO_VIEW_85_PERCENT.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype
                ]
        analytics.track(Events.VIDEO_VIEW_85_PERCENT, trackedProperties: parameter)
    
        }
    
  // MARK:- Live Section Played
    
    @objc public func livePlayed(){
             let parameter : Set = [
                 Keys.LIVE_CHANNEL_PLAYED.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
                 Keys.LIVE_CHANNEL_PLAYED.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
                 Keys.LIVE_CHANNEL_PLAYED.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
                 Keys.LIVE_CHANNEL_PLAYED.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
                 Keys.LIVE_CHANNEL_PLAYED.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
                 Keys.LIVE_CHANNEL_PLAYED.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
                 Keys.LIVE_CHANNEL_PLAYED.SOURCE ~>> source,
                     ]
             analytics.track(Events.LIVE_CHANNEL_PLAYED, trackedProperties: parameter)
    
        }
    
    //MARK:- MusicVideo played Event
    @objc public func Musicplayed(){
        
      let parameter : Set = [
            Keys.MUSICVIDEO_CONTENT_PLAY.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.MUSICVIDEO_CONTENT_PLAY.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.MUSICVIDEO_CONTENT_PLAY.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.MUSICVIDEO_CONTENT_PLAY.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
            Keys.MUSICVIDEO_CONTENT_PLAY.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.MUSICVIDEO_CONTENT_PLAY.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId,
            Keys.MUSICVIDEO_CONTENT_PLAY.SHOW_ID ~>> notAppplicable,
            Keys.MUSICVIDEO_CONTENT_PLAY.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype
                ]
        analytics.track(Events.MUSICVIDEO_CONTENT_PLAY, trackedProperties: parameter)
    
        }
    
    //MARK:- Movie played Event
    @objc public func MoviesPlayed(){
        
      let parameter : Set = [
            Keys.MOVIES_CONTENT_PLAY.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.MOVIES_CONTENT_PLAY.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.MOVIES_CONTENT_PLAY.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.MOVIES_CONTENT_PLAY.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
            Keys.MOVIES_CONTENT_PLAY.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.MOVIES_CONTENT_PLAY.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId,
            Keys.MOVIES_CONTENT_PLAY.SHOW_ID ~>> notAppplicable,
            Keys.MOVIES_CONTENT_PLAY.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype
                ]
        analytics.track(Events.MOVIES_CONTENT_PLAY, trackedProperties: parameter)
    
        }
    
    @objc public func MovieSectionplayed(){
      let parameter : Set = [

            Keys.MOVIESSECTION_PLAYED.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.MOVIESSECTION_PLAYED.MOVIE_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.MOVIESSECTION_PLAYED.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.MOVIESSECTION_PLAYED.EPISODE_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.MOVIESSECTION_PLAYED.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
            Keys.MOVIESSECTION_PLAYED.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
            Keys.MOVIESSECTION_PLAYED.SOURCE ~>> source,
                ]
        analytics.track(Events.MOVIESSECTION_PLAYED, trackedProperties:parameter)
        }

    //MARK:- TV Show played Event
    @objc public func TvShowplayed(){
        
      let parameter : Set = [
            Keys.TVSHOWS_CONTENT_PLAY.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.TVSHOWS_CONTENT_PLAY.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.TVSHOWS_CONTENT_PLAY.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.TVSHOWS_CONTENT_PLAY.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
            Keys.TVSHOWS_CONTENT_PLAY.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.TVSHOWS_CONTENT_PLAY.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId,
            Keys.TVSHOWS_CONTENT_PLAY.SHOW_ID ~>> notAppplicable,
            Keys.TVSHOWS_CONTENT_PLAY.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype
                ]
        analytics.track(Events.TVSHOWS_CONTENT_PLAY, trackedProperties: parameter)
    
        }
    
    @objc public func TvShowSectionplayed(){
           
         let parameter : Set = [
               
               Keys.TVSHOWSSECTION_PLAYED.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
               Keys.TVSHOWSSECTION_PLAYED.PROGRAM_NAME ~>> contentName == "" ? notAppplicable:contentName,
               Keys.TVSHOWSSECTION_PLAYED.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.TVSHOWSSECTION_PLAYED.EPISODE_NAME ~>> contentName == "" ? notAppplicable:contentName,
               Keys.TVSHOWSSECTION_PLAYED.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
               Keys.TVSHOWSSECTION_PLAYED.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
               Keys.TVSHOWSSECTION_PLAYED.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
               Keys.TVSHOWSSECTION_PLAYED.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
                Keys.TVSHOWSSECTION_PLAYED.SOURCE ~>> source,
                   ]
           analytics.track(Events.TVSHOWSSECTION_PLAYED, trackedProperties: parameter)
       
           }
    
    //MARK:- Video Content played Event
       @objc public func videoContentplayed(){
           
         let parameter : Set = [
               Keys.VIDEOS_CONTENT_PLAY.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
               Keys.VIDEOS_CONTENT_PLAY.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
               Keys.VIDEOS_CONTENT_PLAY.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
               Keys.VIDEOS_CONTENT_PLAY.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
               Keys.VIDEOS_CONTENT_PLAY.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.VIDEOS_CONTENT_PLAY.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId,
               Keys.VIDEOS_CONTENT_PLAY.SHOW_ID ~>> contentId == "" ? notAppplicable:contentId,
               Keys.VIDEOS_CONTENT_PLAY.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype
                   ]
           analytics.track(Events.VIDEOS_CONTENT_PLAY, trackedProperties: parameter)
       
           }
    
    @objc public func videoContentSectionplayed(){
             
        let parameter : Set = [
            Keys.VIDEOSECTION_PLAYED.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.VIDEOSECTION_PLAYED.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.VIDEOSECTION_PLAYED.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.VIDEOSECTION_PLAYED.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
            Keys.VIDEOSECTION_PLAYED.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
            Keys.VIDEOSECTION_PLAYED.EPISODE_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.VIDEOSECTION_PLAYED.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
            Keys.VIDEOSECTION_PLAYED.SOURCE ~>> source,
                     ]
            analytics.track(Events.VIDEOSECTION_PLAYED, trackedProperties:parameter)
         
             }
        //MARK:- Original Section played Event
    @objc public func OriginalSectionplayed(){
              
        let parameter : Set = [
        Keys.ORIGINALSSECTION_PLAYED.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
        Keys.ORIGINALSSECTION_PLAYED.PROGRAM_NAME ~>> contentName == "" ? notAppplicable:contentName,
        Keys.ORIGINALSSECTION_PLAYED.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.ORIGINALSSECTION_PLAYED.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
        Keys.ORIGINALSSECTION_PLAYED.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
        Keys.ORIGINALSSECTION_PLAYED.EPISODE_NAME ~>> contentName == "" ? notAppplicable:contentName,
        Keys.ORIGINALSSECTION_PLAYED.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
        Keys.ORIGINALSSECTION_PLAYED.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
        Keys.ORIGINALSSECTION_PLAYED.SOURCE ~>> source,
            ]
          
        analytics.track(Events.ORIGINALSSECTION_PLAYED, trackedProperties:parameter)
              }
    
    //MARK:- Player CTA Pressed
    
    @objc public func PlayerBtnPressed(with Element : String){
        
      let parameter : Set = [
            Keys.PLAYER_CTAS.SOURCE ~>> source,
            Keys.PLAYER_CTAS.ELEMENT ~>> Element  == "" ? notAppplicable : Element,
            Keys.PLAYER_CTAS.BUTTON_TYPE ~>> "Player",
                ]
        analytics.track(Events.PLAYER_CTAS, trackedProperties: parameter)
    
        }
    //MARK:- Download CTA Clicked
    
    @objc public func DownloadCTAclicked(){
        
        var components = DateComponents()
        components.setValue(1, for: .day)
        let date: Date = Date()
        let expirationDate = Calendar.current.date(byAdding: components, to: date, wrappingComponents: false)
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: expirationDate!)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "dd-MMM-yyyy"
        let DownloadExpiryDate = formatter.string(from: yourDate!)
    
        
    let parameter : Set = [
             Keys.DOWNLOAD_CLICK.SOURCE ~>> source,
             Keys.DOWNLOAD_CLICK.ELEMENT ~>> "Download CTA",
             Keys.DOWNLOAD_CLICK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
             Keys.DOWNLOAD_CLICK.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
             Keys.DOWNLOAD_CLICK.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
             Keys.DOWNLOAD_CLICK.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
             Keys.DOWNLOAD_CLICK.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
             Keys.DOWNLOAD_CLICK.SERIES ~>> series == "" ? notAppplicable:series,
             Keys.DOWNLOAD_CLICK.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
             Keys.DOWNLOAD_CLICK.CAST_TO ~>> notAppplicable,
             Keys.DOWNLOAD_CLICK.INTRO_PRESENT ~>> skipIntroTime == "" ? false : true,
             Keys.DOWNLOAD_CLICK.PAGE_NAME ~>> currently_tab,
             Keys.DOWNLOAD_CLICK.DRM_VIDEO ~>> DrmVideo,
             Keys.DOWNLOAD_CLICK.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
             Keys.DOWNLOAD_CLICK.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
             Keys.DOWNLOAD_CLICK.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
             Keys.DOWNLOAD_CLICK.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
             Keys.DOWNLOAD_CLICK.TAB_NAME ~>> currently_tab,
             Keys.DOWNLOAD_CLICK.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
             Keys.DOWNLOAD_CLICK.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
             Keys.DOWNLOAD_CLICK.DOWNLOADED_CONTENT_NAME ~>>  contentName == "" ? notAppplicable:contentName,
             Keys.DOWNLOAD_CLICK.DOWNLOADED_CONTENT_EXPIRY_DATE ~>>  DownloadExpiryDate == "" ? notAppplicable:DownloadExpiryDate,
             Keys.DOWNLOAD_CLICK.DOWNLOADED_CONTENT_NO_OF_DAYS_TO_EXPIRY ~>>  "2",
             Keys.DOWNLOAD_CLICK.DOWNLOADED_CONTENT_IMAGE ~>>  Imageurl == "" ? notAppplicable:Imageurl,
             Keys.DOWNLOAD_CLICK.STATE ~>> ZEE5UserDefaults.getState(),
             ]
              analytics.track(Events.DOWNLOAD_CLICK, trackedProperties: parameter)
        }
    
    
    //MARK:- Video Click Events(1,3,5,7,10,15,20)
    
    @objc public func VideoClicked1(){
        
    let parameter : Set = [
          
             Keys.DD1ST_VIDEO_CLICK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
             Keys.DD1ST_VIDEO_CLICK.SHOW_ID ~>> contentId == "" ? notAppplicable:contentId ,
             Keys.DD1ST_VIDEO_CLICK.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId ,
             Keys.DD1ST_VIDEO_CLICK.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
             Keys.DD1ST_VIDEO_CLICK.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
             Keys.DD1ST_VIDEO_CLICK.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
             Keys.DD1ST_VIDEO_CLICK.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
             Keys.DD1ST_VIDEO_CLICK.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
             Keys.DD1ST_VIDEO_CLICK.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
             Keys.DD1ST_VIDEO_CLICK.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
             Keys.DD1ST_VIDEO_CLICK.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
             ]
              analytics.track(Events.DD1ST_VIDEO_CLICK, trackedProperties: parameter)
        }
    @objc public func VideoClicked3(){
           
       let parameter : Set = [
            
           Keys.DD3RD_VIDEO_CLICK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
           Keys.DD3RD_VIDEO_CLICK.SHOW_ID ~>> contentId == "" ? notAppplicable:contentId ,
           Keys.DD3RD_VIDEO_CLICK.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId,
           Keys.DD3RD_VIDEO_CLICK.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
           Keys.DD3RD_VIDEO_CLICK.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
           Keys.DD3RD_VIDEO_CLICK.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
           Keys.DD3RD_VIDEO_CLICK.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.DD3RD_VIDEO_CLICK.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.DD3RD_VIDEO_CLICK.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.DD3RD_VIDEO_CLICK.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
           Keys.DD3RD_VIDEO_CLICK.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
                ]
                 analytics.track(Events.DD3RD_VIDEO_CLICK, trackedProperties: parameter)
           }
    
    @objc public func VideoClicked5(){
        
    let parameter : Set = [
         
        Keys.DD5TH_VIDEO_CLICK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.DD5TH_VIDEO_CLICK.SHOW_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.DD5TH_VIDEO_CLICK.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId,
        Keys.DD5TH_VIDEO_CLICK.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
        Keys.DD5TH_VIDEO_CLICK.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
        Keys.DD5TH_VIDEO_CLICK.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
        Keys.DD5TH_VIDEO_CLICK.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.DD5TH_VIDEO_CLICK.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.DD5TH_VIDEO_CLICK.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
        Keys.DD5TH_VIDEO_CLICK.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
        Keys.DD3RD_VIDEO_CLICK.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
             ]
              analytics.track(Events.DD5TH_VIDEO_CLICK, trackedProperties: parameter)
        }
    
    @objc public func VideoClicked7(){
        
    let parameter : Set = [
         
        Keys.DD7TH_VIDEO_CLICK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.DD7TH_VIDEO_CLICK.SHOW_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.DD7TH_VIDEO_CLICK.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId,
        Keys.DD7TH_VIDEO_CLICK.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
        Keys.DD7TH_VIDEO_CLICK.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
        Keys.DD7TH_VIDEO_CLICK.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
        Keys.DD7TH_VIDEO_CLICK.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.DD7TH_VIDEO_CLICK.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.DD7TH_VIDEO_CLICK.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
        Keys.DD7TH_VIDEO_CLICK.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
        Keys.DD7TH_VIDEO_CLICK.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
             ]
              analytics.track(Events.DD7TH_VIDEO_CLICK, trackedProperties: parameter)
        }
    
    @objc public func VideoClicked10(){
        
    let parameter : Set = [
         
        Keys.DD10TH_VIDEO_CLICK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.DD10TH_VIDEO_CLICK.SHOW_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.DD10TH_VIDEO_CLICK.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId,
        Keys.DD10TH_VIDEO_CLICK.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
        Keys.DD10TH_VIDEO_CLICK.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
        Keys.DD10TH_VIDEO_CLICK.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
        Keys.DD10TH_VIDEO_CLICK.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.DD10TH_VIDEO_CLICK.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.DD10TH_VIDEO_CLICK.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
        Keys.DD10TH_VIDEO_CLICK.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
        Keys.DD10TH_VIDEO_CLICK.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
             ]
              analytics.track(Events.DD10TH_VIDEO_CLICK, trackedProperties: parameter)
        }
    
    @objc public func VideoClicked15(){
        
    let parameter : Set = [
         
        Keys.DD15TH_VIDEO_CLICK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.DD15TH_VIDEO_CLICK.SHOW_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.DD15TH_VIDEO_CLICK.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId,
        Keys.DD15TH_VIDEO_CLICK.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
        Keys.DD15TH_VIDEO_CLICK.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
        Keys.DD15TH_VIDEO_CLICK.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
        Keys.DD15TH_VIDEO_CLICK.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.DD15TH_VIDEO_CLICK.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.DD15TH_VIDEO_CLICK.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
        Keys.DD15TH_VIDEO_CLICK.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
        Keys.DD15TH_VIDEO_CLICK.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
             ]
              analytics.track(Events.DD15TH_VIDEO_CLICK, trackedProperties: parameter)
        }
    
    @objc public func VideoClicked20(){
        
    let parameter : Set = [
         
        Keys.DD20TH_VIDEO_CLICK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.DD20TH_VIDEO_CLICK.SHOW_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.DD20TH_VIDEO_CLICK.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId,
        Keys.DD20TH_VIDEO_CLICK.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
        Keys.DD20TH_VIDEO_CLICK.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
        Keys.DD20TH_VIDEO_CLICK.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
        Keys.DD20TH_VIDEO_CLICK.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.DD20TH_VIDEO_CLICK.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.DD20TH_VIDEO_CLICK.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
        Keys.DD20TH_VIDEO_CLICK.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
        Keys.DD20TH_VIDEO_CLICK.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
             ]
              analytics.track(Events.DD20TH_VIDEO_CLICK, trackedProperties: parameter)
        }
    
    //MARK:- SVOD Content play
    
    @objc public func SvodContentplayed(){
    
            analytics.track(Events.SVOD_CONTENT_VIEW, trackedProperties: Set<TrackedProperty>())
        }
    //MARK:- AVod Content play
    
    @objc public func AvodContentplayed(){
    
            analytics.track(Events.AVOD_CONTENT_VIEW, trackedProperties: Set<TrackedProperty>())
        }
    
    //MARK:- Video Section Add To WatchList
    public func VideoAddToWatch()
       {
        videoStarttime = Int(Zee5PlayerPlugin.sharedInstance().player.currentTime)
        let parameter : Set = [
           Keys.VIDEOSECTION_ADDED_TO_WATCH_LATER.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
           Keys.VIDEOSECTION_ADDED_TO_WATCH_LATER.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
           Keys.VIDEOSECTION_ADDED_TO_WATCH_LATER.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.VIDEOSECTION_ADDED_TO_WATCH_LATER.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
           Keys.VIDEOSECTION_ADDED_TO_WATCH_LATER.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
           Keys.VIDEOSECTION_ADDED_TO_WATCH_LATER.SOURCE ~>> source,
           ]
            analytics.track(Events.VIDEOSECTION_ADDED_TO_WATCH_LATER, trackedProperties: parameter)
       }
    //MARK:- original Section Watch later
    public func originalAddToWatch()
          {
            videoStarttime = Int(Zee5PlayerPlugin.sharedInstance().player.currentTime)
           let parameter : Set = [
              Keys.ORIGINALSSECTION_ADDED_TO_WATCH_LATER.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
              Keys.ORIGINALSSECTION_ADDED_TO_WATCH_LATER.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
              Keys.ORIGINALSSECTION_ADDED_TO_WATCH_LATER.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
              Keys.ORIGINALSSECTION_ADDED_TO_WATCH_LATER.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
              Keys.ORIGINALSSECTION_ADDED_TO_WATCH_LATER.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
              Keys.ORIGINALSSECTION_ADDED_TO_WATCH_LATER.SOURCE ~>> source,
             Keys.ORIGINALSSECTION_ADDED_TO_WATCH_LATER.EPISODE_NAME ~>> contentName == "" ? notAppplicable:contentName,
             Keys.ORIGINALSSECTION_ADDED_TO_WATCH_LATER.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
             Keys.ORIGINALSSECTION_ADDED_TO_WATCH_LATER.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
              ]
              analytics.track(Events.ORIGINALSSECTION_ADDED_TO_WATCH_LATER, trackedProperties:parameter)
          }
    
    
    //MARK:- TV Show Section Add To WatchList
      public func TVShowAddToWatch()
         {
           videoStarttime = Int(Zee5PlayerPlugin.sharedInstance().player.currentTime)
          let parameter : Set = [
             Keys.TVSHOWSSECTION_ADDED_TO_WATCH_LATER.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
             Keys.TVSHOWSSECTION_ADDED_TO_WATCH_LATER.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
             Keys.TVSHOWSSECTION_ADDED_TO_WATCH_LATER.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
             Keys.TVSHOWSSECTION_ADDED_TO_WATCH_LATER.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
             Keys.TVSHOWSSECTION_ADDED_TO_WATCH_LATER.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
             Keys.TVSHOWSSECTION_ADDED_TO_WATCH_LATER.SOURCE ~>> source,
             Keys.TVSHOWSSECTION_ADDED_TO_WATCH_LATER.EPISODE_NAME ~>> contentName == "" ? notAppplicable:contentName,
             Keys.TVSHOWSSECTION_ADDED_TO_WATCH_LATER.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
            Keys.TVSHOWSSECTION_ADDED_TO_WATCH_LATER.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
             ]
               analytics.track(Events.TVSHOWSSECTION_ADDED_TO_WATCH_LATER, trackedProperties:parameter)
         }
      //MARK:- Movie Section Add To WatchList
    
    public func MovieAddToWatch()
          {
            videoStarttime = Int(Zee5PlayerPlugin.sharedInstance().player.currentTime)
           let parameter : Set = [
              Keys.MOVIESSECTION_ADDED_TO_WATCH_LATER.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
              Keys.MOVIESSECTION_ADDED_TO_WATCH_LATER.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
              Keys.MOVIESSECTION_ADDED_TO_WATCH_LATER.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
              Keys.MOVIESSECTION_ADDED_TO_WATCH_LATER.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
              Keys.MOVIESSECTION_ADDED_TO_WATCH_LATER.TIME_SPENT ~>> videoStarttime == 0 ? Int(time_spent):videoStarttime,
              Keys.MOVIESSECTION_ADDED_TO_WATCH_LATER.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
              Keys.MOVIESSECTION_ADDED_TO_WATCH_LATER.EPISODE_NAME ~>> contentName == "" ? notAppplicable:contentName,
              Keys.MOVIESSECTION_ADDED_TO_WATCH_LATER.SOURCE ~>> source,
              ]
               analytics.track(Events.MOVIESSECTION_ADDED_TO_WATCH_LATER, trackedProperties: parameter)
          }
    
}
