//
//  AllAnalyticsClass.swift
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 04/12/19.
//

import UIKit
import Zee5CoreSDK
import ZappSDK

public class AllAnalyticsClass: NSObject{
    let LotameClientid = "13772"      // *** Lotame Client ID****////

    public static let shared = AllAnalyticsClass()
    
    var contentName = ""
    var contentId = ""
    var seasonId = ""
    var TvShowId = ""
    var realeseDate = ""
    var PlayerVersion = ""
    var series = ""
    var Subtitles = [String]()
    var audiolanguage = [String]()
    var contentlanguages = [String]()
    var Charecters = [String]()
    var cast = [String]()
    var genre = [Genres]()
    var duration = 0
    var currentDuration:TimeInterval = 0
    var episodeNumber = 0
    var DrmVideo = false
    var notAppplicable = "N/A"
    var genereString = ""
    var assetSubtype = ""
    var Buisnesstype = ""
    var skipIntroTime = ""
    var Imageurl = ""
    var TvShowimagUrl = ""
    var videoStarttime = 0
    var TvshowChannelName = ""
    var CurrentAudioLanguage = ""
    var AdDict = NSDictionary()
    var AdTag = NSDictionary()
    var firstFramecontentId = ""
    var firstClickcontentId = ""

    
    let Gender = analytics.getGender()   /// From Core SDK
    let Age = getAge()
    let displaylanguage = Zee5UserDefaultsManager .shared.getSelectedDisplayLanguage() ?? ""
    var consumptionFeedType: ConsumptionFeedType?
    

    public override init(){}

    public init(contentName: String, contentId: String, releaseDate: String, playerVersion: String,series: String, subtitles: [String], audio:[String], gen: [Genres], duration: Int, currentDuration: TimeInterval, episodeNumber: Int, isDrm: Bool,NotApplicable:String,generestring:String,Cast:[String],assetsubtype:String,buisnessType:String,actors:[String],skiptime:String,language:[String],image:String,Tvshowimgurl:String,Starttime:String,seasonID:String,tvshowid:String,addict:NSDictionary,adtag:NSDictionary,tvchannelname:String) {

        
        self.contentId = contentId
        self.contentName = contentName
        self.realeseDate = releaseDate
        self.PlayerVersion = playerVersion
        self.series = series
        self.Subtitles = subtitles
        self.audiolanguage = audio
        self.genre = gen
        self.duration = duration
        self.currentDuration = currentDuration
        self.episodeNumber = episodeNumber
        self.DrmVideo = isDrm
        self.notAppplicable = NotApplicable
        self.genereString = generestring
        self.cast = Cast
        self.assetSubtype = assetsubtype
        self.Buisnesstype = buisnessType
        self.Charecters = actors
        self.skipIntroTime = skiptime
        self.contentlanguages = language
        self.Imageurl = image
        self.TvShowimagUrl = Tvshowimgurl
        self.seasonId = seasonID
        self.TvShowId = tvshowid
        self.AdDict = addict
        self.AdTag = adtag
        self.TvshowChannelName = tvchannelname
        
    }
    
    public func DataModelContent(with DataModel:CurrentItem)
    {
                   contentName = DataModel.channel_Name
                   contentId = DataModel.content_id
                   genre = DataModel.geners
                   duration = DataModel.duration
                   currentDuration = Zee5PlayerPlugin.sharedInstance().getCurrentTime()
                   series = DataModel.channel_Name  
                   episodeNumber = DataModel.episode_number
                   DrmVideo = DataModel.isDRM
                   Subtitles = DataModel.subTitles as! [String]
                   realeseDate = DataModel.release_date
                   assetSubtype = DataModel.asset_subtype
                   Buisnesstype = DataModel.business_type
                   skipIntroTime = DataModel.skipintrotime
                   contentlanguages = DataModel.language as! [String]
                   Imageurl = DataModel.imageUrl
                   TvShowimagUrl = DataModel.tvShowImgurl
                   seasonId = DataModel.seasonId
                   TvShowId = DataModel.showId
                   TvshowChannelName = DataModel.showchannelName
                   audiolanguage .removeAll()
                   if DataModel.charecters.count>0{
                    Charecters  = DataModel.charecters as! [String]
                    }
                  let value = genre.map{$0.value}
                  genereString = value.joined(separator: ",")
        
               if DataModel.audioLanguages.count>0{
                for Audio in DataModel.audioLanguages {
                    let AudioStr = Utility .getLanguageString(fromId: Audio as! String)
                  audiolanguage .append(AudioStr)
                   }
               }
                   PlayerVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "nil"
                  
    }
    
    public func ADsDataModelContent(with dict:NSDictionary, tags:NSDictionary ){
    AdTag = tags
    AdDict = dict
}
}
// MARK:- Ad Events Analytics

extension AllAnalyticsClass
{
    // MARK:- AdInitialize
    
    public func ADInitize(with data: NSDictionary , CustomTags:NSDictionary)
    {
        currentDuration = Zee5PlayerPlugin.sharedInstance().getCurrentTime()
        
        let parameter : Set = [
            Keys.AD_INITIALIZED.TITLE ~>> contentName == "" ? notAppplicable:contentName,
            Keys.AD_INITIALIZED.SOURCE ~>> source , 
            Keys.AD_INITIALIZED.AD_DURATION ~>> data.value(forKey: "duration") as? String ?? notAppplicable,
            Keys.AD_INITIALIZED.AD_CATEGORY ~>> data.value(forKey: "streamType") as? String ?? notAppplicable,
            Keys.AD_INITIALIZED.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
            Keys.AD_INITIALIZED.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.AD_INITIALIZED.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.AD_INITIALIZED.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
            Keys.AD_INITIALIZED.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
            Keys.AD_INITIALIZED.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
            Keys.AD_INITIALIZED.SERIES ~>> series == "" ? notAppplicable:series,
            Keys.AD_INITIALIZED.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
            Keys.AD_INITIALIZED.PREVIEW_STATUS ~>> preview_status,
            Keys.AD_INITIALIZED.PAGE_NAME ~>> currently_tab,
            Keys.AD_INITIALIZED.DRM_VIDEO ~>> DrmVideo,
            Keys.AD_INITIALIZED.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
            Keys.AD_INITIALIZED.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.AD_INITIALIZED.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.AD_INITIALIZED.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
            Keys.AD_INITIALIZED.TAB_NAME ~>> currently_tab,
            Keys.AD_INITIALIZED.CAST_TO ~>> notAppplicable,
            Keys.AD_INITIALIZED.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
            Keys.AD_INITIALIZED.PLAYER_HEAD_POSITION ~>> videoStarttime == 0 ? "0":String(videoStarttime),
            Keys.AD_INITIALIZED.PLAYER_HEAD_START_POSITION ~>> videoStarttime == 0 ? "0":String(videoStarttime),
            Keys.AD_INITIALIZED.PLAYER_HEAD_END_POSITION ~>> duration == 0 ? "0":String(duration),
            Keys.AD_INITIALIZED.PLAYER_NAME ~>> CustomTags.value(forKey: "playerName") as? String ?? "Kaltura Player",
            Keys.AD_INITIALIZED.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
            Keys.AD_INITIALIZED.AD_PROVIDER ~>> "IMA",
            Keys.AD_INITIALIZED.PROVIDER_ID ~>> data.value(forKey: "adId") as? String ?? notAppplicable,
            Keys.AD_INITIALIZED.PROVIDER_NAME ~>> "IMA",
            Keys.AD_INITIALIZED.AD_POSITION ~>> CustomTags.value(forKey: "c3.ad.position") as? String ?? "nil",
            Keys.AD_INITIALIZED.AD_LOCATION ~>> "Instream",
            Keys.AD_INITIALIZED.AD_CUE_TIME ~>> currentDuration == 0 ? 0:currentDuration,
            Keys.AD_INITIALIZED.AD_DESTINATION_URL ~>> "https://www.zee5.com/",
            Keys.AD_INITIALIZED.AD_ID ~>> data.value(forKey: "adId") as? String ?? notAppplicable,
            Keys.AD_INITIALIZED.AD_TITLE ~>> data.value(forKey: "assetName") as? String ?? notAppplicable,
            Keys.AD_INITIALIZED.CDN ~>> notAppplicable,
            Keys.AD_INITIALIZED.DNS ~>> notAppplicable,
            Keys.AD_INITIALIZED.CAROUSAL_NAME ~>> carousal_name,
            Keys.AD_INITIALIZED.CAROUSAL_ID ~>> carousal_id,
            Keys.AD_INITIALIZED.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
            Keys.AD_INITIALIZED.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
            Keys.AD_INITIALIZED.HORIZONTAL_INDEX ~>> horizontal_index == "" ? notAppplicable:horizontal_index,
            Keys.AD_INITIALIZED.VERTICAL_INDEX ~>> vertical_index == "" ? notAppplicable:vertical_index,

        ]
        analytics.track(Events.AD_INITIALIZED, trackedProperties: parameter)
        
    }
    
    // MARK:- AdView
       public func ADView()
       {
    
        currentDuration = Zee5PlayerPlugin.sharedInstance().getCurrentTime()
           let parameter : Set = [
               Keys.AD_VIEW.TITLE ~>> AdDict.value(forKey: "assetName") as? String ?? notAppplicable,
               Keys.AD_VIEW.SOURCE ~>> AdDict.value(forKey: "streamUrl") as? String ?? notAppplicable,
               Keys.AD_VIEW.AD_DURATION ~>> AdDict.value(forKey: "duration") as? String ?? notAppplicable,
               Keys.AD_VIEW.AD_CATEGORY ~>> AdDict.value(forKey: "streamType") as? String ?? notAppplicable,
               Keys.AD_VIEW.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
               Keys.AD_VIEW.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
               Keys.AD_VIEW.GENRE ~>>  genereString  == "" ? notAppplicable : genereString,
               Keys.AD_VIEW.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
               Keys.AD_VIEW.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable: Buisnesstype,
               Keys.AD_VIEW.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
               Keys.AD_VIEW.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
               Keys.AD_VIEW.SERIES ~>> series == "" ? notAppplicable:series,
               Keys.AD_VIEW.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
               Keys.AD_VIEW.PREVIEW_STATUS ~>> preview_status,
               Keys.AD_VIEW.PAGE_NAME ~>> currently_tab,
               Keys.AD_VIEW.DRM_VIDEO ~>> DrmVideo,
               Keys.AD_VIEW.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
               Keys.AD_VIEW.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.AD_VIEW.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.AD_VIEW.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
               Keys.AD_VIEW.TAB_NAME ~>> currently_tab,
               Keys.AD_VIEW.CAST_TO ~>> notAppplicable,
               Keys.AD_VIEW.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
               Keys.AD_VIEW.PROVIDER_ID ~>> AdDict.value(forKey: "adId") as? String ?? notAppplicable,
               Keys.AD_VIEW.PROVIDER_NAME ~>> "IMA",
               Keys.AD_VIEW.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
               Keys.AD_VIEW.PLAYER_NAME ~>> AdTag.value(forKey: "playerName") as? String ?? "Kaltura Player",
               Keys.AD_VIEW.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
               Keys.AD_VIEW.AD_PROVIDER ~>> "IMA",
               Keys.AD_VIEW.AD_POSITION ~>> AdTag.value(forKey: "c3.ad.position") as? String ?? "nil",
               Keys.AD_VIEW.AD_TYPE ~>> AdTag.value(forKey: "c3.ad.position") as? String ?? "nil",
               Keys.AD_VIEW.AD_LOCATION ~>> "Instream",
               Keys.AD_VIEW.AD_CUE_TIME ~>> currentDuration == 0 ? 0:currentDuration,
               Keys.AD_VIEW.AD_DESTINATION_URL ~>> "https://www.zee5.com/",
               Keys.AD_VIEW.AD_ID ~>> AdDict.value(forKey: "adId") as? String ?? notAppplicable,
               Keys.AD_VIEW.AD_TITLE ~>> AdDict.value(forKey: "assetName") as? String ?? notAppplicable,
               Keys.AD_VIEW.CDN ~>> "",
               Keys.AD_VIEW.DNS ~>> notAppplicable,
               Keys.AD_VIEW.CAROUSAL_NAME ~>> carousal_name,
               Keys.AD_VIEW.CAROUSAL_ID ~>> carousal_id,
               Keys.AD_VIEW.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
               Keys.AD_VIEW.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
               Keys.AD_VIEW.SHOW_ID ~>> TvShowId == "" ? notAppplicable:TvShowId ,
               Keys.AD_VIEW.SEASON_ID ~>>  seasonId == "" ? notAppplicable:seasonId ,
               Keys.AD_VIEW.AD_PERCENT_COMPLETE ~>>  "0" ,
               Keys.AD_VIEW.HORIZONTAL_INDEX ~>> horizontal_index == "" ? notAppplicable:horizontal_index,
               Keys.AD_VIEW.VERTICAL_INDEX ~>> vertical_index == "" ? notAppplicable:vertical_index,
            
           ]
           analytics.track(Events.AD_VIEW, trackedProperties: parameter)
           
       }
    
    // MARK:- AdView 3
       public func ADView3()
       {

           let parameter : Set = [
            Keys.AD_VIEW_3.AD_TYPE ~>> AdTag.value(forKey: "c3.ad.position") as? String ?? notAppplicable,
            Keys.AD_VIEW_3.AD_TYPE ~>> AdTag.value(forKey: "c3.ad.position") as? String ?? notAppplicable,
            Keys.AD_VIEW_3.SOURCE ~>> AdDict.value(forKey: "streamUrl") as? String ?? notAppplicable,
            Keys.AD_VIEW_3.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
            Keys.AD_VIEW_3.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.AD_VIEW_3.GENRE ~>>  genereString  == "" ? notAppplicable : genereString,
             Keys.AD_VIEW_3.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
            Keys.AD_VIEW_3.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.AD_VIEW_3.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
            Keys.AD_VIEW_3.SHOW_ID ~>> TvShowId == "" ? notAppplicable:TvShowId ,
            Keys.AD_VIEW_3.SEASON_ID ~>>  seasonId == "" ? notAppplicable:seasonId ,
           ]
           analytics.track(Events.AD_VIEW_3, trackedProperties: parameter)

       }
    
    // MARK:- AdView 5
       public func ADView5()
       {

           let parameter : Set = [
            Keys.AD_VIEW_5.AD_TYPE ~>> AdTag.value(forKey: "c3.ad.position") as? String ?? notAppplicable,
            Keys.AD_VIEW_5.AD_TYPE ~>> AdTag.value(forKey: "c3.ad.position") as? String ?? notAppplicable,
            Keys.AD_VIEW_5.SOURCE ~>> AdDict.value(forKey: "streamUrl") as? String ?? notAppplicable,
            Keys.AD_VIEW_5.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
            Keys.AD_VIEW_5.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.AD_VIEW_5.GENRE ~>>  genereString  == "" ? notAppplicable : genereString,
             Keys.AD_VIEW_5.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
            Keys.AD_VIEW_5.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
            Keys.AD_VIEW_5.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
            Keys.AD_VIEW_5.SHOW_ID ~>> TvShowId == "" ? notAppplicable:TvShowId ,
            Keys.AD_VIEW_5.SEASON_ID ~>>  seasonId == "" ? notAppplicable:seasonId ,
           ]
           analytics.track(Events.AD_VIEW_5, trackedProperties: parameter)
       }
  
    // MARK:- AdView 10
    public func ADView10()
    {

        let parameter : Set = [
         Keys.AD_VIEW_10.AD_TYPE ~>> AdTag.value(forKey: "c3.ad.position") as? String ?? notAppplicable,
         Keys.AD_VIEW_10.SOURCE ~>> AdDict.value(forKey: "streamUrl") as? String ?? notAppplicable,
         Keys.AD_VIEW_10.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
         Keys.AD_VIEW_10.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
         Keys.AD_VIEW_10.GENRE ~>>  genereString  == "" ? notAppplicable : genereString,
          Keys.AD_VIEW_10.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
         Keys.AD_VIEW_10.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
         Keys.AD_VIEW_10.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
         Keys.AD_VIEW_10.SHOW_ID ~>> TvShowId == "" ? notAppplicable:TvShowId ,
         Keys.AD_VIEW_10.SEASON_ID ~>>  seasonId == "" ? notAppplicable:seasonId ,
        ]
        analytics.track(Events.AD_VIEW_10, trackedProperties: parameter)
    }
    
    
// MARK:- AdSkiped
    
    public func ADSkiped()
       {
        currentDuration = Zee5PlayerPlugin.sharedInstance().getCurrentTime()
        
           let parameter : Set = [
               Keys.AD_SKIP.ELEMENT ~>> "Skip Add",
               Keys.AD_SKIP.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
               Keys.AD_SKIP.GENRE ~>>  genereString  == "" ? notAppplicable : genereString,
               Keys.AD_SKIP.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
               Keys.AD_SKIP.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
               Keys.AD_SKIP.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
                Keys.AD_SKIP.SERIES ~>> series == "" ? notAppplicable:series,
               Keys.AD_SKIP.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
               Keys.AD_SKIP.SOURCE ~>> AdDict.value(forKey: "streamUrl") as? String ?? notAppplicable,
               Keys.AD_SKIP.AD_DURATION ~>> AdDict.value(forKey: "duration") as? String ?? notAppplicable,
               Keys.AD_SKIP.AD_CATEGORY ~>> AdDict.value(forKey: "streamType") as? String ?? notAppplicable,
               Keys.AD_SKIP.BUTTON_TYPE ~>> "Button",
               Keys.AD_SKIP.PREVIEW_STATUS ~>> preview_status,
               Keys.AD_SKIP.PAGE_NAME ~>> currently_tab,
               Keys.AD_SKIP.DRM_VIDEO ~>> DrmVideo,
               Keys.AD_SKIP.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
               Keys.AD_SKIP.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.AD_SKIP.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.AD_SKIP.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
               Keys.AD_SKIP.TAB_NAME ~>> currently_tab,
               Keys.AD_SKIP.CAST_TO ~>> notAppplicable,
               Keys.AD_SKIP.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
               Keys.AD_SKIP.PROVIDER_ID ~>> AdDict.value(forKey: "adId") as? String ?? notAppplicable,
               Keys.AD_SKIP.PROVIDER_NAME ~>> "IMA",
               Keys.AD_SKIP.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
               Keys.AD_SKIP.PLAYER_NAME ~>> AdTag.value(forKey: "playerName") as? String ?? notAppplicable,
               Keys.AD_SKIP.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
               Keys.AD_SKIP.AD_PROVIDER ~>> "IMA",
               Keys.AD_SKIP.AD_POSITION ~>> AdTag.value(forKey: "c3.ad.position") as? String ?? notAppplicable,
               Keys.AD_SKIP.AD_LOCATION ~>> "Instream",
               Keys.AD_SKIP.AD_CUE_TIME ~>> currentDuration == 0 ? 0:currentDuration,
               Keys.AD_SKIP.AD_DESTINATION_URL ~>> "https://www.zee5.com/",
               Keys.AD_SKIP.AD_ID ~>> AdDict.value(forKey: "adId") as? String ?? notAppplicable,
               Keys.AD_SKIP.AD_TITLE ~>> AdDict.value(forKey: "assetName") as? String ?? notAppplicable,
               Keys.AD_SKIP.CDN ~>> "",
               Keys.AD_SKIP.DNS ~>> notAppplicable,
               Keys.AD_SKIP.CAROUSAL_ID ~>> carousal_id,
               Keys.AD_SKIP.CAROUSAL_NAME ~>> carousal_name,
               Keys.AD_SKIP.CONTENT_NAME ~>> contentName == "" ? notAppplicable:contentName,
               Keys.AD_SKIP.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
               Keys.AD_SKIP.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
               Keys.AD_SKIP.HORIZONTAL_INDEX ~>> horizontal_index == "" ? notAppplicable:horizontal_index,
               Keys.AD_SKIP.VERTICAL_INDEX ~>> vertical_index == "" ? notAppplicable:vertical_index,

           ]
           analytics.track(Events.AD_SKIP, trackedProperties: parameter)
           
    }
    
  // MARK:- AdComplete
    public func ADComplete()
          {
             let parameter : Set = [
               Keys.AD_VIEW_COMPLETE.AD_TYPE ~>> AdTag.value(forKey: "c3.ad.position") as? String ?? notAppplicable,
               Keys.AD_VIEW_COMPLETE.AD_TYPE ~>> AdTag.value(forKey: "c3.ad.position") as? String ?? notAppplicable,
               Keys.AD_VIEW_COMPLETE.SOURCE ~>> AdDict.value(forKey: "streamUrl") as? String ?? notAppplicable,
               Keys.AD_VIEW_COMPLETE.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
               Keys.AD_VIEW_COMPLETE.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
               Keys.AD_VIEW_COMPLETE.GENRE ~>>  genereString  == "" ? notAppplicable : genereString,
                Keys.AD_VIEW_COMPLETE.CONTENT_TYPE ~>> Buisnesstype == "" ? notAppplicable:Buisnesstype,
               Keys.AD_VIEW_COMPLETE.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.AD_VIEW_COMPLETE.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
               Keys.AD_VIEW_COMPLETE.SHOW_ID ~>> TvShowId == "" ? notAppplicable:TvShowId ,
               Keys.AD_VIEW_COMPLETE.SEASON_ID ~>>  seasonId == "" ? notAppplicable:seasonId ,
              ]
              analytics.track(Events.AD_VIEW_COMPLETE, trackedProperties: parameter)
       }
    
     // MARK:- AdClicked
    
    public func ADClicked()
       {
        currentDuration = Zee5PlayerPlugin.sharedInstance().getCurrentTime()
           let parameter : Set = [
               Keys.AD_CLICK.SOURCE ~>> AdDict.value(forKey: "streamUrl") as? String ?? notAppplicable,
               Keys.AD_CLICK.TITLE ~>> AdDict.value(forKey: "assetName") as? String ?? notAppplicable,
               Keys.AD_CLICK.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
               Keys.AD_CLICK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId,
               Keys.AD_CLICK.GENRE ~>> genre.count>0 ? genre.description:notAppplicable,
               Keys.AD_CLICK.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
               Keys.AD_CLICK.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
               Keys.AD_CLICK.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
               Keys.AD_CLICK.SERIES ~>> series == "" ? notAppplicable:series,
               Keys.AD_CLICK.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
               Keys.AD_CLICK.PREVIEW_STATUS ~>> preview_status,
               Keys.AD_CLICK.PAGE_NAME ~>> currently_tab,
               Keys.AD_CLICK.DRM_VIDEO ~>> DrmVideo,
               Keys.AD_CLICK.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
               Keys.AD_CLICK.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.AD_CLICK.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
               Keys.AD_CLICK.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
               Keys.AD_CLICK.TAB_NAME ~>> currently_tab,
               Keys.AD_CLICK.CAST_TO ~>> notAppplicable,
               Keys.AD_CLICK.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
               Keys.AD_CLICK.PROVIDER_ID ~>> AdDict.value(forKey: "adId") as? String ?? notAppplicable,
               Keys.AD_CLICK.PROVIDER_NAME ~>> "IMA",
               Keys.AD_CLICK.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
               Keys.AD_CLICK.PLAYER_NAME ~>> AdTag.value(forKey: "playerName") as? String ?? notAppplicable,
               Keys.AD_CLICK.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
               Keys.AD_CLICK.AD_PROVIDER ~>> "IMA",
               Keys.AD_CLICK.AD_POSITION ~>> AdTag.value(forKey: "c3.ad.position") as? String ?? notAppplicable,
               Keys.AD_CLICK.AD_LOCATION ~>> "Instream",
               Keys.AD_CLICK.AD_DURATION ~>> AdDict.value(forKey: "duration") as? String ?? notAppplicable,
               Keys.AD_CLICK.AD_CATEGORY ~>> AdDict.value(forKey: "streamType") as? String ?? notAppplicable,
               Keys.AD_CLICK.AD_ID ~>> AdDict.value(forKey: "adId") as? String ?? notAppplicable,
               Keys.AD_CLICK.AD_TITLE ~>> AdDict.value(forKey: "assetName") as? String ?? notAppplicable,
               Keys.AD_CLICK.AD_CUE_TIME ~>> currentDuration == 0 ? 0:currentDuration,
               Keys.AD_CLICK.AD_DESTINATION_URL ~>> "https://www.zee5.com/",
               Keys.AD_CLICK.CDNstatic ~>> "",
               Keys.AD_CLICK.DNS ~>> notAppplicable,
               Keys.AD_CLICK.CAROUSAL_NAME ~>> carousal_name,
               Keys.AD_CLICK.CAROUSAL_ID ~>> carousal_id,
               Keys.AD_CLICK.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
               Keys.AD_CLICK.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
               Keys.AD_CLICK.HORIZONTAL_INDEX ~>> horizontal_index == "" ? notAppplicable:horizontal_index,
               Keys.AD_CLICK.VERTICAL_INDEX ~>> vertical_index == "" ? notAppplicable:vertical_index,

           ]
         analytics.track(Events.AD_CLICK, trackedProperties: parameter)
           
    }
    
    // MARK:- AdWatchDuration
    
    public func ADWatchedDuration()
          {
            currentDuration = Zee5PlayerPlugin.sharedInstance().getCurrentTime()
              let parameter : Set = [
                  Keys.AD_WATCH_DURATION.SOURCE ~>> AdDict.value(forKey: "streamUrl") as? String ?? "No Source",
                  Keys.AD_WATCH_DURATION.TITLE ~>> AdDict.value(forKey: "assetName") as? String ?? "No Title",
                  Keys.AD_WATCH_DURATION.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
                  Keys.AD_WATCH_DURATION.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId,
                  Keys.AD_WATCH_DURATION.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
                  Keys.AD_WATCH_DURATION.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
                  Keys.AD_WATCH_DURATION.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
                  Keys.AD_WATCH_DURATION.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
                  Keys.AD_WATCH_DURATION.SERIES ~>> series == "" ? notAppplicable:series,
                  Keys.AD_WATCH_DURATION.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
                  Keys.AD_WATCH_DURATION.PREVIEW_STATUS ~>> preview_status,
                  Keys.AD_WATCH_DURATION.PAGE_NAME ~>> currently_tab,
                  Keys.AD_WATCH_DURATION.DRM_VIDEO ~>> DrmVideo,
                  Keys.AD_WATCH_DURATION.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
                  Keys.AD_WATCH_DURATION.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
                  Keys.AD_WATCH_DURATION.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
                  Keys.AD_WATCH_DURATION.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
                  Keys.AD_WATCH_DURATION.TAB_NAME ~>> currently_tab,
                  Keys.AD_WATCH_DURATION.CAST_TO ~>> notAppplicable,
                  Keys.AD_WATCH_DURATION.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
                  Keys.AD_WATCH_DURATION.PROVIDER_ID ~>> AdDict.value(forKey: "adId") as? String ?? notAppplicable,
                  Keys.AD_WATCH_DURATION.PROVIDER_NAME ~>> "IMA",
                  Keys.AD_WATCH_DURATION.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
                  Keys.AD_WATCH_DURATION.PLAYER_NAME ~>> AdTag.value(forKey: "playerName") as? String ?? notAppplicable,
                  Keys.AD_WATCH_DURATION.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
                  Keys.AD_WATCH_DURATION.BUFFER_DURATION ~>> AdDict.value(forKey: "adPosition") as? String ?? notAppplicable,
                  Keys.AD_WATCH_DURATION.WATCH_DURATION ~>> AdDict.value(forKey: "adPosition") as? String ?? notAppplicable,
                  Keys.AD_WATCH_DURATION.CASTING_DURATION ~>> notAppplicable,
                  Keys.AD_WATCH_DURATION.AD_PROVIDER ~>> "IMA",
                  Keys.AD_WATCH_DURATION.AD_POSITION ~>> AdTag.value(forKey: "c3.ad.position") as? String ?? "nil",
                  Keys.AD_WATCH_DURATION.AD_LOCATION ~>> "Instream",
                  Keys.AD_WATCH_DURATION.AD_DURATION ~>> AdDict.value(forKey: "duration") as? String ?? notAppplicable,
                  Keys.AD_WATCH_DURATION.AD_CATEGORY ~>> AdDict.value(forKey: "streamType") as? String ?? notAppplicable,
                  Keys.AD_WATCH_DURATION.AD_ID ~>> AdDict.value(forKey: "adId") as? String ?? notAppplicable,
                  Keys.AD_WATCH_DURATION.AD_TITLE ~>> AdDict.value(forKey: "assetName") as? String ?? notAppplicable,
                  Keys.AD_WATCH_DURATION.AD_CUE_TIME ~>> currentDuration == 0 ? 0:currentDuration,
                  Keys.AD_WATCH_DURATION.AD_DESTINATION_URL ~>> "https://www.zee5.com/",
                  Keys.AD_WATCH_DURATION.DNS ~>> notAppplicable,
                  Keys.AD_WATCH_DURATION.CAROUSAL_NAME ~>> carousal_name,
                  Keys.AD_WATCH_DURATION.CAROUSAL_ID ~>> carousal_id,
                  Keys.AD_WATCH_DURATION.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
                  Keys.AD_WATCH_DURATION.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
                  Keys.AD_WATCH_DURATION.HORIZONTAL_INDEX ~>> horizontal_index == "" ? notAppplicable:horizontal_index,
                  Keys.AD_WATCH_DURATION.VERTICAL_INDEX ~>> vertical_index == "" ? notAppplicable:vertical_index,

              ]
            analytics.track(Events.AD_WATCH_DURATION, trackedProperties: parameter)
              
       }
    
    // MARK:- AdForcedExit
    public func ADforcedExit()
          {
            currentDuration = Zee5PlayerPlugin.sharedInstance().getCurrentTime()
              let parameter : Set = [
                  Keys.AD_FORCED_EXIT.SOURCE ~>> AdDict.value(forKey: "streamUrl") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.AD_DURATION ~>> AdDict.value(forKey: "duration") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.AD_CATEGORY ~>> AdDict.value(forKey: "streamType") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.TITLE ~>> AdDict.value(forKey: "assetName") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
                  Keys.AD_FORCED_EXIT.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId,
                  Keys.AD_FORCED_EXIT.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
                  Keys.AD_FORCED_EXIT.CHARACTERS ~>> Charecters.count > 0 ? Charecters.joined(separator: ","):notAppplicable,
                  Keys.AD_FORCED_EXIT.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
                  Keys.AD_FORCED_EXIT.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
                  Keys.AD_FORCED_EXIT.SERIES ~>> series == "" ? notAppplicable:series,
                  Keys.AD_FORCED_EXIT.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
                  Keys.AD_FORCED_EXIT.PREVIEW_STATUS ~>> preview_status,
                  Keys.AD_FORCED_EXIT.PAGE_NAME ~>> currently_tab,
                  Keys.AD_FORCED_EXIT.DRM_VIDEO ~>> DrmVideo,
                  Keys.AD_FORCED_EXIT.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
                  Keys.AD_FORCED_EXIT.CONTENT_ORIGINAL_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
                  Keys.AD_FORCED_EXIT.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.joined(separator: ","):notAppplicable,
                  Keys.AD_FORCED_EXIT.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.joined(separator: ",") : notAppplicable,
                  Keys.AD_FORCED_EXIT.TAB_NAME ~>> currently_tab,
                  Keys.AD_FORCED_EXIT.CAST_TO ~>> notAppplicable,
                  Keys.AD_FORCED_EXIT.TV_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,
                  Keys.AD_FORCED_EXIT.PROVIDER_ID ~>> AdDict.value(forKey: "adId") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.PROVIDER_NAME ~>> "IMA",
                  Keys.AD_FORCED_EXIT.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? "0":String(currentDuration),
                  Keys.AD_FORCED_EXIT.PLAYER_NAME ~>> AdTag.value(forKey: "playerName") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
                  Keys.AD_FORCED_EXIT.AD_PROVIDER ~>> "IMA",
                  Keys.AD_FORCED_EXIT.AD_POSITION ~>> AdTag.value(forKey: "c3.ad.position") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.AD_ID ~>> AdDict.value(forKey: "adId") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.AD_TITLE ~>> AdDict.value(forKey: "assetName") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.AD_LOCATION ~>> "Instream",
                  Keys.AD_FORCED_EXIT.AD_CUE_TIME ~>>  currentDuration == 0 ? 0:currentDuration,
                  Keys.AD_FORCED_EXIT.AD_DESTINATION_URL ~>> "https://www.zee5.com/",
                  Keys.AD_FORCED_EXIT.CDN ~>> "",
                  Keys.AD_FORCED_EXIT.DNS ~>> notAppplicable,
                  Keys.AD_FORCED_EXIT.CAROUSAL_NAME ~>> carousal_name,
                  Keys.AD_FORCED_EXIT.CAROUSAL_ID ~>> carousal_id,
                  Keys.AD_FORCED_EXIT.CHANNEL_NAME ~>> TvshowChannelName == "" ? notAppplicable:TvshowChannelName,
                  Keys.AD_FORCED_EXIT.TOP_CATEGORY ~>> assetSubtype == "" ? notAppplicable:assetSubtype,

              ]
            analytics.track(Events.AD_FORCED_EXIT, trackedProperties: parameter)
       }
    
    // MARK:- Screen_view Event
      public func ScreenViewEvent()
    {
        analytics.track(Events.SCREEN_VIEW, trackedProperties: Set<TrackedProperty>())
    }
}

func getAge() -> String {
    guard let data = Zee5UserSettingsManager.shared.getUserSettingsModal() else {return ""}
      
    for settingDataModel in data {
           if settingDataModel.key == "age"
           {
            return (settingDataModel.value ?? "NA")
           }
       }
    return "N/A"
}


extension AllAnalyticsClass
{
    
     public func getVideoStartTime(Time:NSInteger){
        videoStarttime = Time
    }
    
    public func getcurrentAudio(Audio:String){
        CurrentAudioLanguage = Audio
    }
    
}
