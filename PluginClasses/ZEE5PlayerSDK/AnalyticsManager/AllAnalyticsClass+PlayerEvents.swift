//
//  AllAnalyticsClass+PlayerEvents.swift
//  Alamofire
//
//  Created by Tejas Todkar on 06/12/19.
//

import Foundation
import Zee5CoreSDK
import Alamofire

extension AllAnalyticsClass
{
   //MARK:- PlayerAnaytics Events
    
    
    
      // MARK:- VIDEO_VIEW
       
public func VideoViewEvent()
{
    if firstFramecontentId == contentId {
        return
    }
    let parameter : Set = [
        Keys.VIDEO_VIEW.SOURCE ~>> source,
        Keys.VIDEO_VIEW.IMAGE_URL ~>> Imageurl == "" ? notAppplicable:Imageurl,
        Keys.VIDEO_VIEW.TIME_SPENT ~>> videoStarttime == 0 ? 0:videoStarttime,
        Keys.VIDEO_VIEW.VIDEO_INITIATION_METHOD ~>> notAppplicable,
        Keys.VIDEO_VIEW.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
        Keys.VIDEO_VIEW.SEASON_ID ~>> seasonId == "" ? notAppplicable:seasonId ,
        Keys.VIDEO_VIEW.SHOW_ID ~>> TvShowId == "" ? notAppplicable:TvShowId ,
        Keys.VIDEO_VIEW.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
        Keys.VIDEO_VIEW.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
        Keys.VIDEO_VIEW.PREVIEW_STATUS ~>> preview_status,
        Keys.VIDEO_VIEW.PAGE_NAME ~>> currently_tab,
        Keys.VIDEO_VIEW.DRM_VIDEO ~>> DrmVideo,
        Keys.VIDEO_VIEW.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
        Keys.VIDEO_VIEW.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.VIDEO_VIEW.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
        Keys.VIDEO_VIEW.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
        Keys.VIDEO_VIEW.TAB_NAME ~>> currently_tab,
        Keys.VIDEO_VIEW.CAST_TO ~>> notAppplicable,
        Keys.VIDEO_VIEW.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
        Keys.VIDEO_VIEW.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
        Keys.VIDEO_VIEW.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
        Keys.VIDEO_VIEW.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
        Keys.VIDEO_VIEW.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
        Keys.VIDEO_VIEW.SERIES ~>> series == "" ? notAppplicable:series,
        Keys.VIDEO_VIEW.TITLE ~>> contentName == "" ? notAppplicable:contentName,
        Keys.VIDEO_VIEW.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
        Keys.VIDEO_VIEW.PLAYER_HEAD ~>> currentDuration == 0 ? 0:currentDuration,
        Keys.VIDEO_VIEW.PLAYER_NAME ~>> "Kaltura",
        Keys.VIDEO_VIEW.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
        Keys.VIDEO_VIEW.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
        Keys.VIDEO_VIEW.CDN ~>> notAppplicable,
        Keys.VIDEO_VIEW.DNS ~>> notAppplicable,
        Keys.VIDEO_VIEW.CAROUSAL_NAME ~>> carousal_name,
        Keys.VIDEO_VIEW.CAROUSAL_ID ~>> carousal_id,
        Keys.VIDEO_VIEW.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
        Keys.VIDEO_VIEW.PLAYER_HEAD_POSITION ~>> videoStarttime == 0 ? "0":String(videoStarttime),
        Keys.VIDEO_VIEW.PLAYER_HEAD_START_POSITION ~>> videoStarttime == 0 ? "0":String(videoStarttime),
        Keys.VIDEO_VIEW.PLAYER_HEAD_END_POSITION ~>> duration == 0 ? "0":String(duration),
        Keys.VIDEO_VIEW.CLICKMETRICS ~>> 1,
    ]
      analytics.track(Events.VIDEO_VIEW, trackedProperties: parameter)
      firstFramecontentId = contentId
    
    if Buisnesstype == "premium" || Buisnesstype == "premium_downloadable"{
        AllAnalyticsClass.shared.SvodContentplayed()
    }else{
        AllAnalyticsClass.shared.AvodContentplayed()
    }
           
    }
    
    // MARK:- Auto-Seek
    
    public func AutoseekChanged(with Direction: NSString , EndValue:NSInteger,startvalue:NSInteger)
    {
        let scrubDuration =  EndValue - startvalue
        
        let parameter : Set = [
            Keys.AUTO_SEEK.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
            Keys.AUTO_SEEK.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
            Keys.AUTO_SEEK.SOURCE ~>> source,
            Keys.AUTO_SEEK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.AUTO_SEEK.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
            Keys.AUTO_SEEK.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.AUTO_SEEK.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
            Keys.AUTO_SEEK.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
            Keys.AUTO_SEEK.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
            Keys.AUTO_SEEK.SERIES ~>> series == "" ? notAppplicable:series,
            Keys.AUTO_SEEK.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
            Keys.AUTO_SEEK.PREVIEW_STATUS ~>> preview_status,
            Keys.AUTO_SEEK.PAGE_NAME ~>> currently_tab,
            Keys.AUTO_SEEK.DRM_VIDEO ~>> DrmVideo,
            Keys.AUTO_SEEK.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
            Keys.AUTO_SEEK.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.AUTO_SEEK.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.AUTO_SEEK.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
            Keys.AUTO_SEEK.TAB_NAME ~>> currently_tab,
            Keys.AUTO_SEEK.CAST_TO ~>> notAppplicable,
            Keys.AUTO_SEEK.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
            Keys.AUTO_SEEK.PROVIDER_ID ~>> notAppplicable,
            Keys.AUTO_SEEK.PROVIDER_NAME ~>> notAppplicable,
            Keys.AUTO_SEEK.PLAYER_HEAD_POSITION ~>> startvalue == 0 ? "0":String(startvalue),
            Keys.AUTO_SEEK.PLAYER_HEAD_START_POSITION ~>> startvalue == 0 ? "0":String(startvalue),
            Keys.AUTO_SEEK.PLAYER_HEAD_END_POSITION ~>> EndValue == 0 ? "0":String(EndValue),
            Keys.AUTO_SEEK.DIRECTION ~>> Direction == "" ? notAppplicable: Direction as String,
            Keys.AUTO_SEEK.SEEK_SCRUB_DURATION ~>> scrubDuration == 0 ? "0":String(scrubDuration),
            Keys.AUTO_SEEK.PLAYER_NAME ~>> "Kaltura",
            Keys.AUTO_SEEK.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
            Keys.AUTO_SEEK.CDN ~>> notAppplicable,
            Keys.AUTO_SEEK.DNS ~>> notAppplicable,
            Keys.AUTO_SEEK.CAROUSAL_NAME ~>> carousal_name,
            Keys.AUTO_SEEK.CAROUSAL_ID ~>> carousal_id,
            Keys.AUTO_SEEK.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,

        ]
        analytics.track(Events.AUTO_SEEK, trackedProperties: parameter)
        
    }
    
  //MARK:-  Replay video Event
    
    public func ReplayVideoEvent()
       {
           
           let parameter : Set = [
               Keys.REPLAY.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
               Keys.REPLAY.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
               Keys.REPLAY.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
               Keys.REPLAY.SOURCE ~>> source,
               Keys.REPLAY.ELEMENT ~>> "Player Replay Button",
               Keys.REPLAY.BUTTON_TYPE ~>> "Replay Button",
               Keys.REPLAY.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
               Keys.REPLAY.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
               Keys.REPLAY.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
               Keys.REPLAY.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
               Keys.REPLAY.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
               Keys.REPLAY.SERIES ~>> series == "" ? notAppplicable:series,
               Keys.REPLAY.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
               Keys.REPLAY.PREVIEW_STATUS ~>> preview_status,
               Keys.REPLAY.PAGE_NAME ~>> currently_tab,
               Keys.REPLAY.DRM_VIDEO ~>> DrmVideo,
               Keys.REPLAY.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
               Keys.REPLAY.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.REPLAY.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.REPLAY.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
               Keys.REPLAY.TAB_NAME ~>> currently_tab,
               Keys.REPLAY.CAST_TO ~>> notAppplicable,
               Keys.REPLAY.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
               Keys.REPLAY.PROVIDER_ID ~>> notAppplicable,
               Keys.REPLAY.PROVIDER_NAME ~>> notAppplicable,
               Keys.REPLAY.PLAYER_HEAD_POSITION ~>> duration == 0 ? "0":String(duration),
               Keys.REPLAY.PLAYER_HEAD_START_POSITION ~>> duration == 0 ? "0":String(duration),
               Keys.REPLAY.PLAYER_HEAD_END_POSITION ~>> "0",
               Keys.REPLAY.PLAYER_NAME ~>> "Kaltura",
               Keys.REPLAY.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
               Keys.REPLAY.CDN ~>> notAppplicable,
               Keys.REPLAY.DNS ~>> notAppplicable,
               Keys.REPLAY.CAROUSAL_NAME ~>> carousal_name,
               Keys.REPLAY.CAROUSAL_ID ~>> carousal_id,
               Keys.REPLAY.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,

           ]
           analytics.track(Events.REPLAY, trackedProperties: parameter)
           
       }
    
    
//MARK:-  SKIP_INTRO Video Analytics
    
    public func SkipIntoVideo(with SkipstartTime: NSString , SkipendTime:NSString)
       {
           
          let parameter : Set = [
           Keys.SKIP_INTRO.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.SKIP_INTRO.ELEMENT ~>> "Skip Intro CTA",
           Keys.SKIP_INTRO.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
           Keys.SKIP_INTRO.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.SKIP_INTRO.SOURCE ~>> source,
           Keys.SKIP_INTRO.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
           Keys.SKIP_INTRO.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
           Keys.SKIP_INTRO.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
           Keys.SKIP_INTRO.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
           Keys.SKIP_INTRO.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
           Keys.SKIP_INTRO.SERIES ~>> series == "" ? notAppplicable:series,
           Keys.SKIP_INTRO.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
           Keys.SKIP_INTRO.PREVIEW_STATUS ~>> preview_status,
           Keys.SKIP_INTRO.PAGE_NAME ~>> currently_tab,
           Keys.SKIP_INTRO.DRM_VIDEO ~>> DrmVideo,
           Keys.SKIP_INTRO.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
           Keys.SKIP_INTRO.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.SKIP_INTRO.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.SKIP_INTRO.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
           Keys.SKIP_INTRO.TAB_NAME ~>> currently_tab,
           Keys.SKIP_INTRO.CAST_TO ~>> notAppplicable,
           Keys.SKIP_INTRO.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.SKIP_INTRO.PROVIDER_ID ~>> notAppplicable,
           Keys.SKIP_INTRO.PROVIDER_NAME ~>> notAppplicable,
           Keys.SKIP_INTRO.PLAYER_HEAD_POSITION ~>> SkipstartTime == "" ? notAppplicable:SkipstartTime as String,
           Keys.SKIP_INTRO.PLAYER_HEAD_START_POSITION ~>> SkipstartTime == "" ? notAppplicable:SkipstartTime as String,
           Keys.SKIP_INTRO.PLAYER_HEAD_END_POSITION ~>> SkipendTime == "" ? notAppplicable:SkipendTime as String,
           Keys.SKIP_INTRO.PLAYER_NAME ~>> "Kaltura",
           Keys.SKIP_INTRO.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
           Keys.SKIP_INTRO.CDN ~>> "",
           Keys.SKIP_INTRO.DNS ~>> notAppplicable,
           Keys.SKIP_INTRO.CAROUSAL_NAME ~>> carousal_name,
           Keys.SKIP_INTRO.CAROUSAL_ID ~>> carousal_id,
           Keys.SKIP_INTRO.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,

           ]
           analytics.track(Events.SKIP_INTRO, trackedProperties: parameter)
           
       }
    

//MARK:-  SKIP_RECAP Video Analytics
       
       public func SkipRecapVideo(with SkipstartTime: NSString , SkipendTime:NSString)
          {
              
             let parameter : Set = [
              Keys.SKIP_RECAP.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
              Keys.SKIP_RECAP.SOURCE ~>> source,
              Keys.SKIP_RECAP.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
              Keys.SKIP_RECAP.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
              Keys.SKIP_RECAP.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
              Keys.SKIP_RECAP.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
              Keys.SKIP_RECAP.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
              Keys.SKIP_RECAP.SERIES ~>> series == "" ? notAppplicable:series,
              Keys.SKIP_RECAP.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
              Keys.SKIP_RECAP.PREVIEW_STATUS ~>> preview_status,
              Keys.SKIP_RECAP.PAGE_NAME ~>> currently_tab,
              Keys.SKIP_RECAP.DRM_VIDEO ~>> DrmVideo,
              Keys.SKIP_RECAP.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
              Keys.SKIP_RECAP.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
              Keys.SKIP_RECAP.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
              Keys.SKIP_RECAP.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
              Keys.SKIP_RECAP.TAB_NAME ~>> currently_tab,
              Keys.SKIP_RECAP.CAST_TO ~>> notAppplicable,
              Keys.SKIP_RECAP.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
              Keys.SKIP_RECAP.PROVIDER_ID ~>> notAppplicable,
              Keys.SKIP_RECAP.PROVIDER_NAME ~>> notAppplicable,
              Keys.SKIP_RECAP.PLAYER_HEAD_START_POSITION ~>> SkipstartTime == "" ? notAppplicable:SkipstartTime as String,
              Keys.SKIP_RECAP.PLAYER_HEAD_END_POSITION ~>> SkipendTime == "" ? notAppplicable:SkipendTime as String,
              Keys.SKIP_RECAP.PLAYER_NAME ~>> "Kaltura",
              Keys.SKIP_RECAP.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
              Keys.SKIP_RECAP.CDN ~>> "",
              Keys.SKIP_RECAP.DNS ~>> notAppplicable,
              Keys.SKIP_RECAP.CAROUSAL_NAME ~>> carousal_name,
              Keys.SKIP_RECAP.CAROUSAL_ID ~>> carousal_id,

              ]
              analytics.track(Events.SKIP_RECAP, trackedProperties: parameter)
              
          }
       
    
    //MARK:-  Watch_Credits Video Analytics
    
    public func watchCredit(with creditStartTime: NSString)
       {

          let parameter : Set = [
           Keys.WATCH_CREDITS.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.WATCH_CREDITS.SOURCE ~>> source,
           Keys.WATCH_CREDITS.ELEMENT ~>> "Player Watch Credits",
           Keys.WATCH_CREDITS.BUTTON_TYPE ~>> "Watch Credits",
           Keys.WATCH_CREDITS.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
           Keys.WATCH_CREDITS.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
           Keys.WATCH_CREDITS.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
           Keys.WATCH_CREDITS.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
           Keys.WATCH_CREDITS.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
           Keys.WATCH_CREDITS.SERIES ~>> series == "" ? notAppplicable:series,
           Keys.WATCH_CREDITS.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
           Keys.WATCH_CREDITS.PREVIEW_STATUS ~>> preview_status,
           Keys.WATCH_CREDITS.PAGE_NAME ~>> currently_tab,
           Keys.WATCH_CREDITS.DRM_VIDEO ~>> DrmVideo,
           Keys.WATCH_CREDITS.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
           Keys.WATCH_CREDITS.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.WATCH_CREDITS.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.WATCH_CREDITS.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
           Keys.WATCH_CREDITS.TAB_NAME ~>> currently_tab,
           Keys.WATCH_CREDITS.CAST_TO ~>> notAppplicable,
           Keys.WATCH_CREDITS.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.WATCH_CREDITS.PROVIDER_ID ~>> notAppplicable,
           Keys.WATCH_CREDITS.PROVIDER_NAME ~>> notAppplicable,
           Keys.WATCH_CREDITS.PLAYER_HEAD_POSITION ~>> creditStartTime == "" ? notAppplicable:creditStartTime as String,
           Keys.WATCH_CREDITS.PLAYER_HEAD_START_POSITION ~>> creditStartTime == "" ? notAppplicable:creditStartTime as String,
           Keys.WATCH_CREDITS.PLAYER_HEAD_END_POSITION ~>> duration == 0 ? 0:duration,
           Keys.WATCH_CREDITS.PLAYER_NAME ~>> "Kaltura",
           Keys.WATCH_CREDITS.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
           Keys.WATCH_CREDITS.CDN ~>> "",
           Keys.WATCH_CREDITS.DNS ~>> notAppplicable,
           Keys.WATCH_CREDITS.CAROUSAL_NAME ~>> carousal_name,
           Keys.WATCH_CREDITS.CAROUSAL_ID ~>> carousal_id,

           ]
           analytics.track(Events.WATCH_CREDITS, trackedProperties: parameter)

       }
    
    //MARK:-  Pause Event Analytics
    
    public func PauseEvent()
       {
           
          let parameter : Set = [
           Keys.PAUSE.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.PAUSE.ELEMENT ~>> "Pause",
           Keys.PAUSE.BUTTON_TYPE ~>> "Player Pause Button",
           Keys.PAUSE.SOURCE ~>> source,
           Keys.PAUSE.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
           Keys.PAUSE.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
           Keys.PAUSE.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
           Keys.PAUSE.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
           Keys.PAUSE.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
           Keys.PAUSE.SERIES ~>> series == "" ? notAppplicable:series,
           Keys.PAUSE.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
           Keys.PAUSE.PREVIEW_STATUS ~>> preview_status,
           Keys.PAUSE.PAGE_NAME ~>> currently_tab,
           Keys.PAUSE.DRM_VIDEO ~>> DrmVideo,
           Keys.PAUSE.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
           Keys.PAUSE.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.PAUSE.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.PAUSE.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
           Keys.PAUSE.TAB_NAME ~>> currently_tab,
           Keys.PAUSE.CAST_TO ~>> notAppplicable,
           Keys.PAUSE.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.PAUSE.PROVIDER_ID ~>> notAppplicable,
           Keys.PAUSE.PROVIDER_NAME ~>> notAppplicable,
           Keys.PAUSE.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
           Keys.PAUSE.PLAYER_HEAD_START_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
           Keys.PAUSE.PLAYER_HEAD_END_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
           Keys.PAUSE.PLAYER_NAME ~>> "Kaltura",
           Keys.PAUSE.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
           Keys.PAUSE.CDN ~>> notAppplicable,
           Keys.PAUSE.DNS ~>> notAppplicable,
           Keys.PAUSE.CAROUSAL_NAME ~>> carousal_name,
           Keys.PAUSE.CAROUSAL_ID ~>> carousal_id,
           Keys.PAUSE.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.PAUSE.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
           Keys.PAUSE.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,

           ]
           analytics.track(Events.PAUSE, trackedProperties: parameter)
           
       }
    
    
    //MARK:-  ResumePlay Event Analytics
    
    public func PlayResumeEvent()
       {
           
          let parameter : Set = [
           Keys.RESUME.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.RESUME.ELEMENT ~>> "Resume",
           Keys.RESUME.BUTTON_TYPE ~>> "Player Resume Button",
           Keys.RESUME.SOURCE ~>> source,
           Keys.RESUME.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
           Keys.RESUME.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
           Keys.RESUME.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
           Keys.RESUME.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
           Keys.RESUME.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
           Keys.RESUME.SERIES ~>> series == "" ? notAppplicable:series,
           Keys.RESUME.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
           Keys.RESUME.PREVIEW_STATUS ~>> preview_status,
           Keys.RESUME.PAGE_NAME ~>> currently_tab,
           Keys.RESUME.DRM_VIDEO ~>> DrmVideo,
           Keys.RESUME.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
           Keys.RESUME.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.RESUME.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.RESUME.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
           Keys.RESUME.TAB_NAME ~>> currently_tab,
           Keys.RESUME.CAST_TO ~>> notAppplicable,
           Keys.RESUME.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.RESUME.PROVIDER_ID ~>> notAppplicable,
           Keys.RESUME.PROVIDER_NAME ~>> notAppplicable,
           Keys.RESUME.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
           Keys.RESUME.PLAYER_HEAD_START_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
           Keys.RESUME.PLAYER_HEAD_END_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
           Keys.RESUME.PLAYER_NAME ~>> "Kaltura",
           Keys.RESUME.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
           Keys.RESUME.CDN ~>> "",
           Keys.RESUME.DNS ~>> notAppplicable,
           Keys.RESUME.CAROUSAL_NAME ~>> carousal_name,
           Keys.RESUME.CAROUSAL_ID ~>> carousal_id,
           Keys.RESUME.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.RESUME.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
           Keys.RESUME.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,

           ]
           analytics.track(Events.RESUME, trackedProperties: parameter)
           
       }
    
    
// MARK:- SEEk-BAR Changed
       
    public func Seekbar_ChangeEvent(with Direction: NSString , StartTime:NSInteger,EndTime:NSInteger)
       {
           let scrubDuration = EndTime - StartTime
           
           let parameter : Set = [
               Keys.SCRUB_SLASH_SEEK.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
               Keys.SCRUB_SLASH_SEEK.SOURCE ~>> source,
               Keys.SCRUB_SLASH_SEEK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
               Keys.SCRUB_SLASH_SEEK.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
               Keys.SCRUB_SLASH_SEEK.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
               Keys.SCRUB_SLASH_SEEK.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
               Keys.SCRUB_SLASH_SEEK.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
               Keys.SCRUB_SLASH_SEEK.SERIES ~>> series == "" ? notAppplicable:series,
               Keys.SCRUB_SLASH_SEEK.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
               Keys.SCRUB_SLASH_SEEK.PREVIEW_STATUS ~>> preview_status,
               Keys.SCRUB_SLASH_SEEK.PAGE_NAME ~>> currently_tab,
               Keys.SCRUB_SLASH_SEEK.DRM_VIDEO ~>> DrmVideo,
               Keys.SCRUB_SLASH_SEEK.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
               Keys.SCRUB_SLASH_SEEK.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.SCRUB_SLASH_SEEK.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.SCRUB_SLASH_SEEK.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
               Keys.SCRUB_SLASH_SEEK.TAB_NAME ~>> currently_tab,
               Keys.SCRUB_SLASH_SEEK.CAST_TO ~>> notAppplicable,
               Keys.SCRUB_SLASH_SEEK.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
               Keys.SCRUB_SLASH_SEEK.PROVIDER_ID ~>> notAppplicable,
               Keys.SCRUB_SLASH_SEEK.PROVIDER_NAME ~>> notAppplicable,
               Keys.SCRUB_SLASH_SEEK.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
               Keys.SCRUB_SLASH_SEEK.PLAYER_HEAD_START_POSITION ~>> StartTime == 0 ? "0":String(StartTime),
               Keys.SCRUB_SLASH_SEEK.PLAYER_HEAD_END_POSITION ~>> EndTime == 0 ? "0":String(EndTime),
               Keys.SCRUB_SLASH_SEEK.DIRECTION ~>> Direction == "" ? notAppplicable: Direction as String,
               Keys.SCRUB_SLASH_SEEK.SEEK_SCRUB_DURATION ~>> scrubDuration == 0 ? "0":String(scrubDuration),
               Keys.SCRUB_SLASH_SEEK.PLAYER_NAME ~>> "Kaltura",
               Keys.SCRUB_SLASH_SEEK.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
               Keys.SCRUB_SLASH_SEEK.CDN ~>> notAppplicable,
               Keys.SCRUB_SLASH_SEEK.DNS ~>> notAppplicable,
               Keys.SCRUB_SLASH_SEEK.CAROUSAL_NAME ~>> carousal_name,
               Keys.SCRUB_SLASH_SEEK.CAROUSAL_ID ~>> carousal_id,
               Keys.SCRUB_SLASH_SEEK.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
               Keys.SCRUB_SLASH_SEEK.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
               Keys.SCRUB_SLASH_SEEK.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,

           ]
           analytics.track(Events.SCRUB_SLASH_SEEK, trackedProperties: parameter)
           
       }
    
    
    // MARK:- Audio-Language Changed

    public func AudiochangeEvent(with Old: String , New:String,TrackingMode:String)
       {
           let parameter : Set = [
               Keys.LANGUAGE_AUDIO_CHANGE.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
               Keys.LANGUAGE_AUDIO_CHANGE.SOURCE ~>> source,
               Keys.LANGUAGE_AUDIO_CHANGE.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
               Keys.LANGUAGE_AUDIO_CHANGE.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
               Keys.LANGUAGE_AUDIO_CHANGE.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
               Keys.LANGUAGE_AUDIO_CHANGE.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
               Keys.LANGUAGE_AUDIO_CHANGE.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
               Keys.LANGUAGE_AUDIO_CHANGE.SERIES ~>> series == "" ? notAppplicable:series,
               Keys.LANGUAGE_AUDIO_CHANGE.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
               Keys.LANGUAGE_AUDIO_CHANGE.PREVIEW_STATUS ~>> preview_status,
               Keys.LANGUAGE_AUDIO_CHANGE.PAGE_NAME ~>> currently_tab,
               Keys.LANGUAGE_AUDIO_CHANGE.DRM_VIDEO ~>> DrmVideo,
               Keys.LANGUAGE_AUDIO_CHANGE.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
               Keys.LANGUAGE_AUDIO_CHANGE.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.LANGUAGE_AUDIO_CHANGE.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.LANGUAGE_AUDIO_CHANGE.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
               Keys.LANGUAGE_AUDIO_CHANGE.TAB_NAME ~>> currently_tab,
               Keys.LANGUAGE_AUDIO_CHANGE.CAST_TO ~>> notAppplicable,
               Keys.LANGUAGE_AUDIO_CHANGE.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
               Keys.LANGUAGE_AUDIO_CHANGE.PROVIDER_ID ~>> notAppplicable,
               Keys.LANGUAGE_AUDIO_CHANGE.PROVIDER_NAME ~>> notAppplicable,
               Keys.LANGUAGE_AUDIO_CHANGE.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
               Keys.LANGUAGE_AUDIO_CHANGE.PLAYER_NAME ~>> "Kaltura",
               Keys.LANGUAGE_AUDIO_CHANGE.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
               Keys.LANGUAGE_AUDIO_CHANGE.OLD_AUDIO_LANGUAGE ~>> Old == "" ? notAppplicable:Old ,
               Keys.LANGUAGE_AUDIO_CHANGE.NEW_AUDIO_LANGUAGE ~>> New == "" ? notAppplicable:New ,
               Keys.LANGUAGE_AUDIO_CHANGE.CDN ~>> "",
               Keys.LANGUAGE_AUDIO_CHANGE.DNS ~>> notAppplicable,
               Keys.LANGUAGE_AUDIO_CHANGE.TRACKING_MODE ~>> TrackingMode == "" ? notAppplicable:TrackingMode,
               Keys.LANGUAGE_AUDIO_CHANGE.CAROUSAL_NAME ~>> carousal_name,
               Keys.LANGUAGE_AUDIO_CHANGE.CAROUSAL_ID ~>> carousal_id,
               Keys.LANGUAGE_AUDIO_CHANGE.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
               Keys.LANGUAGE_AUDIO_CHANGE.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
               Keys.LANGUAGE_AUDIO_CHANGE.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,

           ]
           analytics.track(Events.LANGUAGE_AUDIO_CHANGE, trackedProperties: parameter)
           
       }
    
    
    
    // MARK:- Subtitle-Language Changed

    public func SubtitleLangChangeEvent(with Old: String , New:String ,TrackingMode:String)
       {
           let parameter : Set = [
               Keys.SUBTITLE_LANGUAGE_CHANGE.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
               Keys.SUBTITLE_LANGUAGE_CHANGE.SOURCE ~>> source,
               Keys.SUBTITLE_LANGUAGE_CHANGE.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
               Keys.SUBTITLE_LANGUAGE_CHANGE.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
               Keys.SUBTITLE_LANGUAGE_CHANGE.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
               Keys.SUBTITLE_LANGUAGE_CHANGE.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
               Keys.SUBTITLE_LANGUAGE_CHANGE.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
               Keys.SUBTITLE_LANGUAGE_CHANGE.SERIES ~>> series == "" ? notAppplicable:series,
               Keys.SUBTITLE_LANGUAGE_CHANGE.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
               Keys.SUBTITLE_LANGUAGE_CHANGE.PREVIEW_STATUS ~>> preview_status,
               Keys.SUBTITLE_LANGUAGE_CHANGE.PAGE_NAME ~>> currently_tab,
               Keys.SUBTITLE_LANGUAGE_CHANGE.DRM_VIDEO ~>> DrmVideo,
               Keys.SUBTITLE_LANGUAGE_CHANGE.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
               Keys.SUBTITLE_LANGUAGE_CHANGE.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.SUBTITLE_LANGUAGE_CHANGE.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.SUBTITLE_LANGUAGE_CHANGE.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
               Keys.SUBTITLE_LANGUAGE_CHANGE.TAB_NAME ~>> currently_tab,
               Keys.SUBTITLE_LANGUAGE_CHANGE.CAST_TO ~>> notAppplicable,
               Keys.SUBTITLE_LANGUAGE_CHANGE.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
               Keys.SUBTITLE_LANGUAGE_CHANGE.PROVIDER_ID ~>> notAppplicable,
               Keys.SUBTITLE_LANGUAGE_CHANGE.PROVIDER_NAME ~>> notAppplicable,
               Keys.SUBTITLE_LANGUAGE_CHANGE.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
               Keys.SUBTITLE_LANGUAGE_CHANGE.PLAYER_NAME ~>> "Kaltura",
               Keys.SUBTITLE_LANGUAGE_CHANGE.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
               Keys.SUBTITLE_LANGUAGE_CHANGE.OLD_SUBTITLE_LANGUAGE ~>> Old == "" ? notAppplicable:Old ,
               Keys.SUBTITLE_LANGUAGE_CHANGE.NEW_SUBTITLE_LANGUAGE ~>> New == "" ? notAppplicable:New ,
               Keys.SUBTITLE_LANGUAGE_CHANGE.CDN ~>> notAppplicable,
               Keys.SUBTITLE_LANGUAGE_CHANGE.DNS ~>> notAppplicable,
               Keys.SUBTITLE_LANGUAGE_CHANGE.TRACKING_MODE ~>> TrackingMode == "" ? notAppplicable:TrackingMode,
               Keys.SUBTITLE_LANGUAGE_CHANGE.CAROUSAL_NAME ~>> carousal_name,
               Keys.SUBTITLE_LANGUAGE_CHANGE.CAROUSAL_ID ~>> carousal_id,
               Keys.SUBTITLE_LANGUAGE_CHANGE.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
               Keys.SUBTITLE_LANGUAGE_CHANGE.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
               Keys.SUBTITLE_LANGUAGE_CHANGE.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,

           ]
           analytics.track(Events.SUBTITLE_LANGUAGE_CHANGE, trackedProperties: parameter)
           
       }
    
    
    //MARK:-  BUFFER START Event
       
       public func BufferStartEvent()
          {
              
             let parameter : Set = [
              Keys.BUFFER_START.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
              Keys.BUFFER_START.SOURCE ~>> source,
              Keys.BUFFER_START.VIDEO_INITIATION_METHOD ~>> notAppplicable,
              Keys.BUFFER_START.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
              Keys.BUFFER_START.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
              Keys.BUFFER_START.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
              Keys.BUFFER_START.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
              Keys.BUFFER_START.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
              Keys.BUFFER_START.SERIES ~>> series == "" ? notAppplicable:series,
              Keys.BUFFER_START.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
              Keys.BUFFER_START.PREVIEW_STATUS ~>> preview_status,
              Keys.BUFFER_START.PAGE_NAME ~>> currently_tab,
              Keys.BUFFER_START.DRM_VIDEO ~>> DrmVideo,
              Keys.BUFFER_START.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
              Keys.BUFFER_START.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
              Keys.BUFFER_START.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
              Keys.BUFFER_START.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
              Keys.BUFFER_START.TAB_NAME ~>> currently_tab,
              Keys.BUFFER_START.CAST_TO ~>> notAppplicable,
              Keys.BUFFER_START.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
              Keys.BUFFER_START.PROVIDER_ID ~>> notAppplicable,
              Keys.BUFFER_START.PROVIDER_NAME ~>> notAppplicable,
              Keys.BUFFER_START.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
              Keys.BUFFER_START.PLAYER_NAME ~>> "Kaltura",
              Keys.BUFFER_START.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
              Keys.BUFFER_START.CDN ~>> "",
              Keys.BUFFER_START.DNS ~>> notAppplicable,
              Keys.BUFFER_START.CAROUSAL_NAME ~>> carousal_name,
              Keys.BUFFER_START.CAROUSAL_ID ~>> carousal_id,

              ]
              analytics.track(Events.BUFFER_START, trackedProperties: parameter)
              
          }
    
    //MARK:-  BUFFER END Event
    
    public func BufferENDEvent(with BufferDuration: Int)
       {
           
          let parameter : Set = [
           Keys.BUFFER_END.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.BUFFER_END.SOURCE ~>> source,
           Keys.BUFFER_END.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
           Keys.BUFFER_END.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
           Keys.BUFFER_END.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
           Keys.BUFFER_END.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
           Keys.BUFFER_END.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
           Keys.BUFFER_END.SERIES ~>> series == "" ? notAppplicable:series,
           Keys.BUFFER_END.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
           Keys.BUFFER_END.PREVIEW_STATUS ~>> preview_status,
           Keys.BUFFER_END.PAGE_NAME ~>> currently_tab,
           Keys.BUFFER_END.DRM_VIDEO ~>> DrmVideo,
           Keys.BUFFER_END.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
           Keys.BUFFER_END.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.BUFFER_END.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.BUFFER_END.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
           Keys.BUFFER_END.TAB_NAME ~>> currently_tab,
           Keys.BUFFER_END.CAST_TO ~>> notAppplicable,
           Keys.BUFFER_END.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.BUFFER_END.PROVIDER_ID ~>> notAppplicable,
           Keys.BUFFER_END.PROVIDER_NAME ~>> notAppplicable,
           Keys.BUFFER_END.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
           Keys.BUFFER_END.PLAYER_NAME ~>> "Kaltura",
           Keys.BUFFER_END.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
           Keys.BUFFER_END.CDN ~>> "",
           Keys.BUFFER_END.DNS ~>> notAppplicable,
           Keys.BUFFER_END.BUFFER_DURATION ~>> "",
           Keys.BUFFER_END.CAROUSAL_NAME ~>> carousal_name,
           Keys.BUFFER_END.CAROUSAL_ID ~>> carousal_id,

           ]
           analytics.track(Events.BUFFER_END, trackedProperties: parameter)
           
       }
    
    
    //MARK:-  PlayerView Changed Event
       
    public func playerOrientationChanged(from oldPlayerOrientation: String, to newPlayerOrientation: String) {
        let parameter : Set = [
              Keys.PLAYER_VIEW_CHANGED.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
              Keys.PLAYER_VIEW_CHANGED.SOURCE ~>> source,
              Keys.PLAYER_VIEW_CHANGED.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
              Keys.PLAYER_VIEW_CHANGED.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
              Keys.PLAYER_VIEW_CHANGED.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
              Keys.PLAYER_VIEW_CHANGED.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
              Keys.PLAYER_VIEW_CHANGED.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
              Keys.PLAYER_VIEW_CHANGED.SERIES ~>> series == "" ? notAppplicable:series,
              Keys.PLAYER_VIEW_CHANGED.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
              Keys.PLAYER_VIEW_CHANGED.PREVIEW_STATUS ~>> preview_status,
              Keys.PLAYER_VIEW_CHANGED.PAGE_NAME ~>> currently_tab,
              Keys.PLAYER_VIEW_CHANGED.DRM_VIDEO ~>> DrmVideo,
              Keys.PLAYER_VIEW_CHANGED.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
              Keys.PLAYER_VIEW_CHANGED.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
              Keys.PLAYER_VIEW_CHANGED.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
              Keys.PLAYER_VIEW_CHANGED.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
              Keys.PLAYER_VIEW_CHANGED.TAB_NAME ~>> currently_tab,
              Keys.PLAYER_VIEW_CHANGED.CAST_TO ~>> notAppplicable,
              Keys.PLAYER_VIEW_CHANGED.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
              Keys.PLAYER_VIEW_CHANGED.PROVIDER_ID ~>> notAppplicable,
              Keys.PLAYER_VIEW_CHANGED.PROVIDER_NAME ~>> notAppplicable,
              Keys.PLAYER_VIEW_CHANGED.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
              Keys.PLAYER_VIEW_CHANGED.PLAYER_HEAD_START_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
              Keys.PLAYER_VIEW_CHANGED.PLAYER_HEAD_END_POSITION ~>> duration == 0 ? "0":String(duration),
              Keys.PLAYER_VIEW_CHANGED.PLAYER_NAME ~>> "Kaltura",
              Keys.PLAYER_VIEW_CHANGED.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
              Keys.PLAYER_VIEW_CHANGED.CDN ~>> "",
              Keys.PLAYER_VIEW_CHANGED.DNS ~>> notAppplicable,
              Keys.PLAYER_VIEW_CHANGED.OLD_VIEW_POSITION ~>> oldPlayerOrientation,
              Keys.PLAYER_VIEW_CHANGED.NEW_VIEW_POSITION ~>> newPlayerOrientation,
              Keys.PLAYER_VIEW_CHANGED.CAROUSAL_NAME ~>> carousal_name,
              Keys.PLAYER_VIEW_CHANGED.CAROUSAL_ID ~>> carousal_id,
              Keys.PLAYER_VIEW_CHANGED.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
              Keys.PLAYER_VIEW_CHANGED.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
              Keys.PLAYER_VIEW_CHANGED.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
        ]
        
        analytics.track(Events.PLAYER_VIEW_CHANGED, trackedProperties: parameter)
    }
       
    //MARK:-  VideoExit Event
    
    public func VideoExit()
       {
        let DurationPlayer = Zee5PlayerPlugin.sharedInstance().getCurrentTime()
        
          let parameter : Set = [
           Keys.VIDEO_EXIT.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.VIDEO_EXIT.SOURCE ~>> source,
           Keys.VIDEO_EXIT.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
           Keys.VIDEO_EXIT.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
           Keys.VIDEO_EXIT.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
           Keys.VIDEO_EXIT.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
           Keys.VIDEO_EXIT.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
           Keys.VIDEO_EXIT.SERIES ~>> series == "" ? notAppplicable:series,
           Keys.VIDEO_EXIT.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
           Keys.VIDEO_EXIT.PREVIEW_STATUS ~>> preview_status,
           Keys.VIDEO_EXIT.PAGE_NAME ~>> currently_tab,
           Keys.VIDEO_EXIT.DRM_VIDEO ~>> DrmVideo,
           Keys.VIDEO_EXIT.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
           Keys.VIDEO_EXIT.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.VIDEO_EXIT.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.VIDEO_EXIT.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
           Keys.VIDEO_EXIT.TAB_NAME ~>> currently_tab,
           Keys.VIDEO_EXIT.CAST_TO ~>> notAppplicable,
           Keys.VIDEO_EXIT.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.VIDEO_EXIT.PROVIDER_ID ~>> notAppplicable,
           Keys.VIDEO_EXIT.PROVIDER_NAME ~>> notAppplicable,
           Keys.VIDEO_EXIT.PLAYER_HEAD_POSITION ~>> DurationPlayer == 0 ? "0":String(DurationPlayer),
           Keys.VIDEO_EXIT.PLAYER_HEAD_START_POSITION ~>> DurationPlayer == 0 ? "0":String(DurationPlayer),
           Keys.VIDEO_EXIT.PLAYER_HEAD_END_POSITION ~>> DurationPlayer == 0 ? "0":String(DurationPlayer),
           Keys.VIDEO_EXIT.PLAYER_NAME ~>> "Kaltura",
           Keys.VIDEO_EXIT.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion,
           Keys.VIDEO_EXIT.CDN ~>> notAppplicable,
           Keys.VIDEO_EXIT.DNS ~>> notAppplicable,
           Keys.VIDEO_EXIT.CAROUSAL_NAME ~>> carousal_name,
           Keys.VIDEO_EXIT.CAROUSAL_ID ~>> carousal_id,
           Keys.VIDEO_EXIT.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.VIDEO_EXIT.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
           Keys.VIDEO_EXIT.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,

           ]
           analytics.track(Events.VIDEO_EXIT, trackedProperties: parameter)
           
       }
    
    
    //MARK:-  VideoWatchDuration Event
    
    public func VideoWatchDuration()
       {
         let DurationPlayer = Zee5PlayerPlugin.sharedInstance().getCurrentTime()
         if DurationPlayer == 0.0 {
            return;
         }
          let parameter : Set = [
           Keys.VIDEO_WATCH_DURATON.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.VIDEO_WATCH_DURATON.SOURCE ~>> source,
           Keys.VIDEO_WATCH_DURATON.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
           Keys.VIDEO_WATCH_DURATON.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
           Keys.VIDEO_WATCH_DURATON.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
           Keys.VIDEO_WATCH_DURATON.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
           Keys.VIDEO_WATCH_DURATON.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
           Keys.VIDEO_WATCH_DURATON.SERIES ~>> series == "" ? notAppplicable:series,
           Keys.VIDEO_WATCH_DURATON.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
           Keys.VIDEO_WATCH_DURATON.PREVIEW_STATUS ~>> preview_status,
           Keys.VIDEO_WATCH_DURATON.PAGE_NAME ~>> currently_tab,
           Keys.VIDEO_WATCH_DURATON.DRM_VIDEO ~>> DrmVideo,
           Keys.VIDEO_WATCH_DURATON.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
           Keys.VIDEO_WATCH_DURATON.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.VIDEO_WATCH_DURATON.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.VIDEO_WATCH_DURATON.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
           Keys.VIDEO_WATCH_DURATON.TAB_NAME ~>> currently_tab,
           Keys.VIDEO_WATCH_DURATON.CAST_TO ~>> notAppplicable,
           Keys.VIDEO_WATCH_DURATON.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.VIDEO_WATCH_DURATON.PROVIDER_ID ~>> notAppplicable,
           Keys.VIDEO_WATCH_DURATON.PROVIDER_NAME ~>> notAppplicable,
            Keys.VIDEO_WATCH_DURATON.PLAYER_HEAD_POSITION ~>> DurationPlayer == 0 ? "0":String(DurationPlayer),
            Keys.VIDEO_WATCH_DURATON.PLAYER_HEAD_END_POSITION ~>> DurationPlayer == 0 ? "0":String(DurationPlayer),
            Keys.VIDEO_WATCH_DURATON.PLAYER_HEAD_END_POSITION ~>> DurationPlayer == 0 ? "0":String(DurationPlayer),
           Keys.VIDEO_WATCH_DURATON.PLAYER_NAME ~>> "Kaltura",
           Keys.VIDEO_WATCH_DURATON.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion,
           Keys.VIDEO_WATCH_DURATON.CDN ~>> "",
           Keys.VIDEO_WATCH_DURATON.DNS ~>> notAppplicable,
           Keys.VIDEO_WATCH_DURATON.CAROUSAL_NAME ~>> carousal_name,
           Keys.VIDEO_WATCH_DURATON.CAROUSAL_ID ~>> carousal_id,
           Keys.VIDEO_WATCH_DURATON.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.VIDEO_WATCH_DURATON.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
           Keys.VIDEO_WATCH_DURATON.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.VIDEO_WATCH_DURATON.VERTICAL_INDEX ~>> vertical_index,
           Keys.VIDEO_WATCH_DURATON.HORIZONTAL_INDEX ~>> horizontal_index,

           ]
           analytics.track(Events.VIDEO_WATCH_DURATON, trackedProperties: parameter)
           
       }
    //MARK:-  PlayBackError Event
       
    public func PlayBackError(with ErrorMessage : String)
          {
              
             let parameter : Set = [
             
              Keys.PLAYBACK_ERROR.SOURCE ~>> source,
              Keys.PLAYBACK_ERROR.PROVIDER_ID ~>> notAppplicable,
              Keys.PLAYBACK_ERROR.PROVIDER_NAME ~>> notAppplicable,
              Keys.PLAYBACK_ERROR.ERROR_MESSAGE ~>> notAppplicable
              ]
              analytics.track(Events.PLAYBACK_ERROR, trackedProperties: parameter)
          }
    
    //MARK:-  CastingStarted Event
    
    public func CastingStartEvent(with CastTo:String)
       {
           
          let parameter : Set = [
           Keys.CASTING_STARTED.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.CASTING_STARTED.SOURCE ~>> source,
           Keys.CASTING_STARTED.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
           Keys.CASTING_STARTED.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
           Keys.CASTING_STARTED.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
           Keys.CASTING_STARTED.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
           Keys.CASTING_STARTED.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
           Keys.CASTING_STARTED.SERIES ~>> series == "" ? notAppplicable:series,
           Keys.CASTING_STARTED.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
           Keys.CASTING_STARTED.PREVIEW_STATUS ~>> preview_status,
           Keys.CASTING_STARTED.PAGE_NAME ~>> currently_tab,
           Keys.CASTING_STARTED.DRM_VIDEO ~>> DrmVideo,
           Keys.CASTING_STARTED.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
           Keys.CASTING_STARTED.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.CASTING_STARTED.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.CASTING_STARTED.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
           Keys.CASTING_STARTED.TAB_NAME ~>> currently_tab,
           Keys.CASTING_STARTED.CAST_TO ~>> CastTo == "" ? notAppplicable:CastTo,
           Keys.CASTING_STARTED.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.CASTING_STARTED.PROVIDER_ID ~>> notAppplicable,
           Keys.CASTING_STARTED.PROVIDER_NAME ~>> notAppplicable,
           Keys.CASTING_STARTED.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
           Keys.CASTING_STARTED.PLAYER_NAME ~>> "Kaltura",
           Keys.CASTING_STARTED.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion,
           Keys.CASTING_STARTED.CDN ~>> "",
           Keys.CASTING_STARTED.DNS ~>> notAppplicable,
           Keys.CASTING_STARTED.CAROUSAL_NAME ~>> carousal_name,
           Keys.CASTING_STARTED.CAROUSAL_ID ~>> carousal_id,

           ]
           analytics.track(Events.CASTING_STARTED, trackedProperties: parameter)
           
       }
    
    
    //MARK:-  CastingEnd Event
    
    public func CastingEndEvent(with CastTo:String)
       {
           
          let parameter : Set = [
           Keys.CASTING_ENDED.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.CASTING_ENDED.SOURCE ~>> source,
           Keys.CASTING_ENDED.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
           Keys.CASTING_ENDED.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
           Keys.CASTING_ENDED.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
           Keys.CASTING_ENDED.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
           Keys.CASTING_ENDED.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
           Keys.CASTING_ENDED.SERIES ~>> series == "" ? notAppplicable:series,
           Keys.CASTING_ENDED.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
           Keys.CASTING_ENDED.PREVIEW_STATUS ~>> preview_status,
           Keys.CASTING_ENDED.PAGE_NAME ~>> currently_tab,
           Keys.CASTING_ENDED.DRM_VIDEO ~>> DrmVideo,
           Keys.CASTING_ENDED.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
           Keys.CASTING_ENDED.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.CASTING_ENDED.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.CASTING_ENDED.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
           Keys.CASTING_ENDED.TAB_NAME ~>> currently_tab,
           Keys.CASTING_ENDED.CAST_TO ~>> CastTo == "" ? notAppplicable:CastTo,
           Keys.CASTING_ENDED.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.CASTING_ENDED.PROVIDER_ID ~>> notAppplicable,
           Keys.CASTING_ENDED.PROVIDER_NAME ~>> notAppplicable,
           Keys.CASTING_ENDED.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
           Keys.CASTING_ENDED.PLAYER_NAME ~>> "Kaltura",
           Keys.CASTING_ENDED.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion,
           Keys.CASTING_ENDED.CDN ~>> "",
           Keys.CASTING_ENDED.DNS ~>> notAppplicable,
           Keys.CASTING_ENDED.CAROUSAL_NAME ~>> carousal_name,
           Keys.CASTING_ENDED.CAROUSAL_ID ~>> carousal_id,

           ]
           analytics.track(Events.CASTING_ENDED, trackedProperties: parameter)
           
       }
    
    
    //MARK:- OFFLINE DOWNLOAD   - StartDownload
    
    public func DownloadStart(with Quality:String)
       {
           
          let parameter : Set = [
           Keys.DOWNLOAD_START.TITLE ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.DOWNLOAD_START.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.DOWNLOAD_START.SOURCE ~>> source,
           Keys.DOWNLOAD_START.ELEMENT ~>> "Download",
           Keys.DOWNLOAD_START.BUTTON_TYPE ~>> "Player Download Button",
           Keys.DOWNLOAD_START.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId,
           Keys.DOWNLOAD_START.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
           Keys.DOWNLOAD_START.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
           Keys.DOWNLOAD_START.VIDEO_INITIATION_METHOD ~>> "",
           Keys.DOWNLOAD_START.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
           Keys.DOWNLOAD_START.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
           Keys.DOWNLOAD_START.SERIES ~>> series == "" ? notAppplicable:series,
           Keys.DOWNLOAD_START.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
           Keys.DOWNLOAD_START.SHARING_PLATFORM ~>> "",
           Keys.DOWNLOAD_START.PREVIEW_STATUS ~>> preview_status,
           Keys.DOWNLOAD_START.PAGE_NAME ~>> currently_tab,
           Keys.DOWNLOAD_START.DRM_VIDEO ~>> DrmVideo,
           Keys.DOWNLOAD_START.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
           Keys.DOWNLOAD_START.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.DOWNLOAD_START.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.DOWNLOAD_START.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
           Keys.DOWNLOAD_START.TAB_NAME ~>> currently_tab,
           Keys.DOWNLOAD_START.CAST_TO ~>> notAppplicable,
           Keys.DOWNLOAD_START.INTRO_PRESENT ~>> skipIntroTime == "" ? false : true,
           Keys.DOWNLOAD_START.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.DOWNLOAD_START.PROVIDER_ID ~>> notAppplicable,
           Keys.DOWNLOAD_START.PROVIDER_NAME ~>> notAppplicable,
           Keys.DOWNLOAD_START.DOWNLOAD_VIDEOS_QUALITY ~>> Quality == "" ? notAppplicable:Quality,
           Keys.DOWNLOAD_START.CONTENT_SPECIFICATION ~>> notAppplicable,
           Keys.DOWNLOAD_START.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
           Keys.DOWNLOAD_START.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           ]
           analytics.track(Events.DOWNLOAD_START, trackedProperties: parameter)
           
       }
    
    //MARK:- DownloadCompleteOrFail.
    
    public func DownloadCompleteOrFail(with item:DownloadItem)
       {
          let parameter : Set = [
           Keys.DOWNLOAD_RESULT.TITLE ~>> item.title == "" ? notAppplicable:item.title ?? notAppplicable ,
           Keys.DOWNLOAD_RESULT.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
           Keys.DOWNLOAD_RESULT.SOURCE ~>> source,
           Keys.DOWNLOAD_RESULT.ELEMENT ~>> notAppplicable,
           Keys.DOWNLOAD_RESULT.BUTTON_TYPE ~>> notAppplicable,
           Keys.DOWNLOAD_RESULT.CONTENT_ID ~>> item.contentId ?? notAppplicable  ,
           Keys.DOWNLOAD_RESULT.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
           Keys.DOWNLOAD_RESULT.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
           Keys.DOWNLOAD_RESULT.VIDEO_INITIATION_METHOD ~>> "",
           Keys.DOWNLOAD_RESULT.CONTENT_DURATION ~>> item.duration ?? 0,
           Keys.DOWNLOAD_RESULT.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
           Keys.DOWNLOAD_RESULT.SERIES ~>> series == "" ? notAppplicable:series,
           Keys.DOWNLOAD_RESULT.EPISODE_NO ~>> item.episodeNumber ?? 0,
           Keys.DOWNLOAD_RESULT.SHARING_PLATFORM ~>> "",
           Keys.DOWNLOAD_RESULT.PREVIEW_STATUS ~>> preview_status,
           Keys.DOWNLOAD_RESULT.PAGE_NAME ~>> currently_tab,
           Keys.DOWNLOAD_RESULT.DRM_VIDEO ~>> DrmVideo,
           Keys.DOWNLOAD_RESULT.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
           Keys.DOWNLOAD_RESULT.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.DOWNLOAD_RESULT.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.DOWNLOAD_RESULT.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
           Keys.DOWNLOAD_RESULT.TAB_NAME ~>> currently_tab,
           Keys.DOWNLOAD_RESULT.CAST_TO ~>> notAppplicable,
           Keys.DOWNLOAD_RESULT.INTRO_PRESENT ~>> skipIntroTime == "" ? false : true,
           Keys.DOWNLOAD_RESULT.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.DOWNLOAD_RESULT.INTERACTION_LABEL ~>> "",
           Keys.DOWNLOAD_RESULT.PROVIDER_ID ~>> notAppplicable,
           Keys.DOWNLOAD_RESULT.PROVIDER_NAME ~>> notAppplicable,
           Keys.DOWNLOAD_RESULT.DOWNLOAD_VIDEOS_QUALITY ~>> "",
           Keys.DOWNLOAD_RESULT.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
           Keys.DOWNLOAD_RESULT.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           ]
           analytics.track(Events.DOWNLOAD_RESULT, trackedProperties: parameter)
           
       }
    
    //MARK:- DownloadDelete.
    
    public func DownloadDelete(with item:DownloadItem)
       {
        var AssestSubtytpe = ""
        
        if item.assetType == "1" {
            AssestSubtytpe = "Episode"
        }else if item.assetType == "0"{
             AssestSubtytpe = "Movie"
        }
           
          let parameter : Set = [
           Keys.DOWNLOAD_DELETE.TITLE ~>> item.title == "" ? notAppplicable:item.title ?? notAppplicable ,
           Keys.DOWNLOAD_DELETE.CONTENT_NAME ~>> item.title == "" ? notAppplicable:item.title ?? notAppplicable ,
           Keys.DOWNLOAD_DELETE.SOURCE ~>> source,
           Keys.DOWNLOAD_DELETE.ELEMENT ~>> "Download Delete",
           Keys.DOWNLOAD_DELETE.BUTTON_TYPE ~>> "Download Delete Button",
           Keys.DOWNLOAD_DELETE.CONTENT_ID ~>> item.contentId ?? notAppplicable ,
           Keys.DOWNLOAD_DELETE.GENRE ~>> notAppplicable,
           Keys.DOWNLOAD_DELETE.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
           Keys.DOWNLOAD_DELETE.VIDEO_INITIATION_METHOD ~>> "",
           Keys.DOWNLOAD_DELETE.CONTENT_DURATION ~>> item.duration ?? 0,
           Keys.DOWNLOAD_DELETE.PUBLISHING_DATE ~>> notAppplicable,
           Keys.DOWNLOAD_DELETE.SERIES ~>> notAppplicable,
           Keys.DOWNLOAD_DELETE.EPISODE_NO ~>> item.episodeNumber ?? 0,
           Keys.DOWNLOAD_DELETE.SHARING_PLATFORM ~>> "",
           Keys.DOWNLOAD_DELETE.PREVIEW_STATUS ~>> preview_status,
           Keys.DOWNLOAD_DELETE.PAGE_NAME ~>> currently_tab,
           Keys.DOWNLOAD_DELETE.DRM_VIDEO ~>> notAppplicable,
           Keys.DOWNLOAD_DELETE.SUBTITLES ~>> notAppplicable,
           Keys.DOWNLOAD_DELETE.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
           Keys.DOWNLOAD_DELETE.AUDIO_LANGUAGE ~>> notAppplicable,
           Keys.DOWNLOAD_DELETE.SUBTITLE_LANGUAGE ~>> notAppplicable,
           Keys.DOWNLOAD_DELETE.TAB_NAME ~>> currently_tab,
           Keys.DOWNLOAD_DELETE.CAST_TO ~>> notAppplicable,
           Keys.DOWNLOAD_DELETE.INTRO_PRESENT ~>> skipIntroTime == "" ? false : true,
           Keys.DOWNLOAD_DELETE.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
           Keys.DOWNLOAD_DELETE.INTERACTION_LABEL ~>> "",
           Keys.DOWNLOAD_DELETE.PROVIDER_ID ~>> notAppplicable,
           Keys.DOWNLOAD_DELETE.PROVIDER_NAME ~>> notAppplicable,
           Keys.DOWNLOAD_DELETE.DOWNLOAD_VIDEOS_QUALITY ~>> "",
           Keys.DOWNLOAD_DELETE.CONTENT_SPECIFICATION ~>> notAppplicable,
           Keys.DOWNLOAD_DELETE.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
           Keys.DOWNLOAD_DELETE.TOP_CATEGORY ~>> AssestSubtytpe == "" ? notAppplicable:AssestSubtytpe,
           ]
           analytics.track(Events.DOWNLOAD_DELETE, trackedProperties: parameter)
           
       }
    
    
    //MARK:- DownloadContentPlay.
       
       public func DownloadPlayClick(with item:DownloadItem)
          {
              
//             let parameter : Set = [
//              Keys.DOWNLOAD_CLICK.TITLE ~>> item.title == "" ? notAppplicable:item.title ?? notAppplicable ,
//              Keys.DOWNLOAD_CLICK.SOURCE ~>> source,
//              Keys.DOWNLOAD_CLICK.ELEMENT ~>> "Download Play",
//              Keys.DOWNLOAD_CLICK.BUTTON_TYPE ~>> "Download Play Button",
//              Keys.DOWNLOAD_CLICK.CONTENT_ID ~>> item.contentId ?? notAppplicable ,
//              Keys.DOWNLOAD_CLICK.GENRE ~>> notAppplicable,
//              Keys.DOWNLOAD_CLICK.CHARACTERS ~>> notAppplicable,
//              Keys.DOWNLOAD_CLICK.VIDEO_INITIATION_METHOD ~>> notAppplicable,
//              Keys.DOWNLOAD_CLICK.CONTENT_DURATION ~>> item.duration ?? 0,
//              Keys.DOWNLOAD_CLICK.PUBLISHING_DATE ~>> notAppplicable,
//              Keys.DOWNLOAD_CLICK.SERIES ~>> notAppplicable ,
//              Keys.DOWNLOAD_CLICK.EPISODE_NO ~>> item.episodeNumber ?? 0,
//              Keys.DOWNLOAD_CLICK.SHARING_PLATFORM ~>> notAppplicable,
//              Keys.DOWNLOAD_CLICK.PREVIEW_STATUS ~>> preview_status,
//              Keys.DOWNLOAD_CLICK.PAGE_NAME ~>> currently_tab,
//              Keys.DOWNLOAD_CLICK.DRM_VIDEO ~>> notAppplicable,
//              Keys.DOWNLOAD_CLICK.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
//              Keys.DOWNLOAD_CLICK.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
//              Keys.DOWNLOAD_CLICK.AUDIO_LANGUAGE ~>> notAppplicable,
//              Keys.DOWNLOAD_CLICK.SUBTITLE_LANGUAGE ~>> notAppplicable,
//              Keys.DOWNLOAD_CLICK.TAB_NAME ~>> currently_tab,
//              Keys.DOWNLOAD_CLICK.CAST_TO ~>> notAppplicable,
//              Keys.DOWNLOAD_CLICK.INTRO_PRESENT ~>> skipIntroTime == "" ? false : true,
//              Keys.DOWNLOAD_CLICK.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
//              Keys.DOWNLOAD_CLICK.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
//              Keys.DOWNLOAD_CLICK.INTERACTION_LABEL ~>> "",
//              Keys.DOWNLOAD_CLICK.PROVIDER_ID ~>> notAppplicable,
//              Keys.DOWNLOAD_CLICK.PROVIDER_NAME ~>> notAppplicable,
//              Keys.DOWNLOAD_CLICK.PARENT_CONTROL_SETTING ~>> "",
//              Keys.DOWNLOAD_CLICK.STREAMING_VIDEOS_WIFI_ONLY ~>> "",
//              Keys.DOWNLOAD_CLICK.STREAMING_VIDEOS_QUALITY ~>> "",
//              Keys.DOWNLOAD_CLICK.DOWNLOAD_VIDEOS_WIFI_ONLY ~>> "",
//              Keys.DOWNLOAD_CLICK.DOWNLOAD_VIDEOS_QUALITY ~>> "",
//              Keys.DOWNLOAD_CLICK.CONTENT_SPECIFICATION ~>> "",
//              ]
//              analytics.track(Events.DOWNLOAD_CLICK, trackedProperties: parameter)
            
            analytics.track(Events.DOWNLOAD_PLAY, trackedProperties: Set<TrackedProperty>())
            analytics.track(Events.DOWNLOADED_VIDEO_PLAYED, trackedProperties: Set<TrackedProperty>())
              
          }
       //MARK:- PopUpLaunch.
          
    public func PopUpLaunch(with PopUpName:String)
    {
         let parameter : Set = [
                Keys.POPUP_LAUNCH.SOURCE ~>> source,
                       Keys.POPUP_LAUNCH.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
                       Keys.POPUP_LAUNCH.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
                       Keys.POPUP_LAUNCH.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
                       Keys.POPUP_LAUNCH.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
                       Keys.POPUP_LAUNCH.PAGE_NAME ~>> currently_tab,
                       Keys.POPUP_LAUNCH.DRM_VIDEO ~>> DrmVideo,
                       Keys.POPUP_LAUNCH.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
                       Keys.POPUP_LAUNCH.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
                       Keys.POPUP_LAUNCH.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
                       Keys.POPUP_LAUNCH.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
                       Keys.POPUP_LAUNCH.TAB_NAME ~>> currently_tab,
                       Keys.POPUP_LAUNCH.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
                       Keys.POPUP_LAUNCH.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
                       Keys.POPUP_LAUNCH.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
                       Keys.POPUP_LAUNCH.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
                       Keys.POPUP_LAUNCH.SERIES ~>> series == "" ? notAppplicable:series,
                       Keys.POPUP_LAUNCH.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
                       Keys.POPUP_LAUNCH.PLAYER_NAME ~>> "Kaltura",
                       Keys.POPUP_LAUNCH.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
                       Keys.POPUP_LAUNCH.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
                       Keys.POPUP_LAUNCH.CAROUSAL_NAME ~>> carousal_name,
                       Keys.POPUP_LAUNCH.CAROUSAL_ID ~>> carousal_id,
                       Keys.POPUP_LAUNCH.TRACKING_MODE ~>> "Online",
                       Keys.POPUP_LAUNCH.POP_UP_NAME ~>> PopUpName == "" ? notAppplicable:PopUpName,
                       Keys.POPUP_LAUNCH.POPUP_TYPE ~>> "native",
                       Keys.POPUP_LAUNCH.HORIZONTAL_INDEXstatic ~>> horizontal_index,
                       Keys.POPUP_LAUNCH.VERTICAL_INDEX ~>> vertical_index,
                ]
                analytics.track(Events.POPUP_LAUNCH, trackedProperties: parameter)
                
    }
    
    //MARK:- PopUpCTAPressed.
            
    public func PopUpCTApressed(with PopUpCtaName:String ,PopUpName:String)
      {
                let parameter : Set = [
                Keys.POP_UP_CTAS.SOURCE ~>> source,
                Keys.POP_UP_CTAS.ELEMENT ~>> PopUpCtaName == "" ? notAppplicable:PopUpCtaName,
                Keys.POP_UP_CTAS.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
                Keys.POP_UP_CTAS.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName ,
                Keys.POP_UP_CTAS.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
                Keys.POP_UP_CTAS.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
                Keys.POP_UP_CTAS.PAGE_NAME ~>> currently_tab,
                Keys.POP_UP_CTAS.DRM_VIDEO ~>> DrmVideo,
                Keys.POP_UP_CTAS.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
                Keys.POP_UP_CTAS.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
                Keys.POP_UP_CTAS.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
                Keys.POP_UP_CTAS.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
                  Keys.POP_UP_CTAS.TAB_NAME ~>> currently_tab,
                  Keys.POP_UP_CTAS.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
                  Keys.POP_UP_CTAS.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
                  Keys.POP_UP_CTAS.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
                  Keys.POP_UP_CTAS.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
                  Keys.POP_UP_CTAS.SERIES ~>> series == "" ? notAppplicable:series,
                  Keys.POP_UP_CTAS.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
                  Keys.POP_UP_CTAS.PLAYER_NAME ~>> "Kaltura",
                  Keys.POP_UP_CTAS.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
                  Keys.POP_UP_CTAS.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
                  Keys.POP_UP_CTAS.CAROUSAL_NAME ~>> carousal_name,
                  Keys.POP_UP_CTAS.CAROUSAL_ID ~>> carousal_id,
                  Keys.POP_UP_CTAS.TRACKING_MODE ~>> "Online",
                  Keys.POP_UP_CTAS.POP_UP_NAME ~>> PopUpName == "" ? notAppplicable:PopUpName,
                  Keys.POP_UP_CTAS.POP_UP_TYPE ~>> "native",
                  Keys.POP_UP_CTAS.HORIZONTAL_INDEX ~>> horizontal_index,
                  Keys.POP_UP_CTAS.VERTICAL_INDEX ~>> vertical_index,
                ]
            analytics.track(Events.POP_UP_CTAS, trackedProperties: parameter)
      }
    
    
    //MARK:- CTA's
            
    public func CTAs(with CTAType:String, CTaName:String)
    {
        let parameter : Set = [
            Keys.CTAS.SOURCE ~>> source,
            Keys.CTAS.ELEMENT ~>> CTaName,
            Keys.CTAS.PAGE_NAME ~>> currently_tab,
            Keys.CTAS.TAB_NAME ~>> currently_tab,
            Keys.CTAS.CAROUSAL_NAME ~>> carousal_name,
            Keys.CTAS.CAROUSAL_ID ~>> carousal_id,
            Keys.CTAS.TRACKING_MODE ~>> Reachability.isConnectedToNetwork() ? "Online" : "Offline",
            Keys.CTAS.POP_UP_TYPE ~>> "Native",
            Keys.CTAS.HORIZONTAL_INDEX ~>> horizontal_index,
            Keys.CTAS.VERTICAL_INDEX ~>> vertical_index,
            Keys.CTAS.BUTTON_TYPE ~>> CTAType,
            Keys.CTAS.POP_UP_NAME ~>> "",
            Keys.CTAS.POP_UP_TYPE ~>> "",
        ]
        analytics.track(Events.CTAS, trackedProperties: parameter)
    }
}
