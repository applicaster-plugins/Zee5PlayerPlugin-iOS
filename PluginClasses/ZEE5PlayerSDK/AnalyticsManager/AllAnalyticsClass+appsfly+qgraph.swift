//
//  AllAnalyticsClass+appsfly+qgraph.swift
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 16/04/20.
//

import Foundation
import Zee5CoreSDK

extension AllAnalyticsClass{
    
    //MARK:- AppsFlyer Events
    
  //MARK:- Add to WatchList Event
    
    public func addtoWatchlistEvent()
    {
        let parameter : Set = [
        Keys.ADD_TO_WATCHLIST.SOURCE ~>> notAppplicable,
        Keys.ADD_TO_WATCHLIST.ELEMENT ~>> "Add to watch List",
        Keys.ADD_TO_WATCHLIST.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.ADD_TO_WATCHLIST.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
        Keys.ADD_TO_WATCHLIST.CHARACTERS ~>> "",
        Keys.ADD_TO_WATCHLIST.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
        Keys.ADD_TO_WATCHLIST.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
        Keys.ADD_TO_WATCHLIST.SERIES ~>> series == "" ? notAppplicable:series,
        Keys.ADD_TO_WATCHLIST.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
        Keys.ADD_TO_WATCHLIST.CAST_TO ~>> notAppplicable,
        Keys.ADD_TO_WATCHLIST.INTRO_PRESENT ~>> notAppplicable,
        Keys.ADD_TO_WATCHLIST.PAGE_NAME ~>> notAppplicable,
        Keys.ADD_TO_WATCHLIST.DRM_VIDEO ~>> DrmVideo,
        Keys.ADD_TO_WATCHLIST.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
        Keys.ADD_TO_WATCHLIST.CONTENT_ORIGINAL_LANGUAGE ~>> "",
        Keys.ADD_TO_WATCHLIST.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.description:notAppplicable,
        Keys.ADD_TO_WATCHLIST.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.description : notAppplicable,
        Keys.ADD_TO_WATCHLIST.TAB_NAME ~>> notAppplicable,
        Keys.ADD_TO_WATCHLIST.TV_CATEGORY ~>> notAppplicable,
        Keys.ADD_TO_WATCHLIST.CHANNEL_NAME ~>> notAppplicable,
        Keys.ADD_TO_WATCHLIST.CAROUSAL_NAME ~>> notAppplicable,
        Keys.ADD_TO_WATCHLIST.CAROUSAL_ID ~>> notAppplicable,
        Keys.ADD_TO_WATCHLIST.USER_LOGIN_STATUS ~>> User.shared.getType().rawValue == "" ?notAppplicable:User.shared.getType().rawValue,
        Keys.ADD_TO_WATCHLIST.TRACKING_MODE ~>> notAppplicable,
        Keys.ADD_TO_WATCHLIST.UPTIME ~>> notAppplicable,
        ]
         analytics.track(Events.ADD_TO_WATCHLIST, trackedProperties: parameter)
    }
    
    
    //MARK:- Subscription CTA Button cLicked
    
    public func subscribeBtnClicked(){
        
        let parameter : Set = [
        Keys.CONSUMPTION_SUBSCRIBE_CTA_CLICK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.CONSUMPTION_SUBSCRIBE_CTA_CLICK.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
        Keys.CONSUMPTION_SUBSCRIBE_CTA_CLICK.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
        Keys.CONSUMPTION_SUBSCRIBE_CTA_CLICK.PACK_SELECTED ~>> "",
        Keys.CONSUMPTION_SUBSCRIBE_CTA_CLICK.UPTIME ~>> "",
        Keys.CONSUMPTION_SUBSCRIBE_CTA_CLICK.PACK_ID ~>> notAppplicable,
        ]
         analytics.track(Events.CONSUMPTION_SUBSCRIBE_CTA_CLICK, trackedProperties: parameter)
    }
    
    
    
    
    //MARK:- Qgraph Events
    
    //MARK:- liveTv Channel played
    
    public func liveContenPlay(){
        let parameter : Set = [
              Keys.LIVE_CHANNEL_PLAYED.UPTIME ~>> "",
              ]
        analytics.track(Events.LIVE_CHANNEL_PLAYED, trackedProperties: parameter)
          }
    
    //MARK:- 20% video Play Event
    @objc public func VideoWatch20(){
        
        let parameter : Set = [
            Keys.VIDEO_VIEW_20_PERCENT.UPTIME ~>> "",
            Keys.VIDEO_VIEW_20_PERCENT.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.VIDEO_VIEW_20_PERCENT.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.VIDEO_VIEW_20_PERCENT.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.VIDEO_VIEW_20_PERCENT.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
            Keys.VIDEO_VIEW_20_PERCENT.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.description:notAppplicable,
            Keys.VIDEO_VIEW_20_PERCENT.SEASON_ID ~>> notAppplicable,
            Keys.VIDEO_VIEW_20_PERCENT.SHOW_ID ~>> notAppplicable,
            Keys.VIDEO_VIEW_20_PERCENT.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype
            
               ]
        analytics.track(Events.VIDEO_VIEW_20_PERCENT, trackedProperties: parameter)
    
       }
    
    //MARK:- 50% video Play Event
    @objc public func VideoWatch50(){
    
        let parameter : Set = [
            Keys.VIDEO_VIEW_50_PERCENT.UPTIME ~>> "",
            Keys.VIDEO_VIEW_50_PERCENT.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.VIDEO_VIEW_50_PERCENT.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.VIDEO_VIEW_50_PERCENT.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.VIDEO_VIEW_50_PERCENT.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
            Keys.VIDEO_VIEW_50_PERCENT.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.description:notAppplicable,
            Keys.VIDEO_VIEW_50_PERCENT.SEASON_ID ~>> notAppplicable,
            Keys.VIDEO_VIEW_50_PERCENT.SHOW_ID ~>> notAppplicable,
            Keys.VIDEO_VIEW_50_PERCENT.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype
                ]
        
            analytics.track(Events.VIDEO_VIEW_50_PERCENT, trackedProperties: parameter)
          }
    //MARK:- 85% video Play Event
    @objc public func VideoWatch85(){
        
      let parameter : Set = [
            Keys.VIDEO_VIEW_85_PERCENT.UPTIME ~>> "",
            Keys.VIDEO_VIEW_85_PERCENT.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.VIDEO_VIEW_85_PERCENT.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.VIDEO_VIEW_85_PERCENT.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.VIDEO_VIEW_85_PERCENT.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
            Keys.VIDEO_VIEW_85_PERCENT.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.description:notAppplicable,
            Keys.VIDEO_VIEW_85_PERCENT.SEASON_ID ~>> notAppplicable,
            Keys.VIDEO_VIEW_85_PERCENT.SHOW_ID ~>> notAppplicable,
            Keys.VIDEO_VIEW_85_PERCENT.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype
                ]
        analytics.track(Events.VIDEO_VIEW_85_PERCENT, trackedProperties: parameter)
    
        }
    
    
}
