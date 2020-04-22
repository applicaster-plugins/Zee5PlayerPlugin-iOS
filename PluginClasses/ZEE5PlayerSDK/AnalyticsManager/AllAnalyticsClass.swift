//
//  AllAnalyticsClass.swift
//  Zee5PlayerPlugin
//
//  Created by Tejas Todkar on 04/12/19.
//

import UIKit
import Zee5CoreSDK

public class AllAnalyticsClass: NSObject {

    let LotameClientid = "13772"      // *** Lotame Client ID****////

    public static let shared = AllAnalyticsClass()
    
    var contentName = ""
    var contentId = ""
    var realeseDate = ""
    var PlayerVersion = ""
    var series = ""
    var Subtitles = [Any]()
    var audiolanguage = [Any]()
    var Charecters = [Any]()
    var cast = [Any]()
    var genre = [Genres]()
    var duration: TimeInterval = 0
    var currentDuration: TimeInterval = 0
    var episodeNumber = 0
    var DrmVideo = false
    var notAppplicable = "N/A"
    var genereString = ""
    var assetSubtype = ""
    var Buisnesstype = ""
    var skipIntroTime = ""
    
    let Gender = analytics.getGender()   /// From Core SDK
    let Age = getAge()
    let displaylanguage = Zee5UserDefaultsManager .shared.getSelectedDisplayLanguage() ?? ""
    var consumptionFeedType: ConsumptionFeedType?
    

    public override init(){}
    public init(contentName: String, contentId: String, releaseDate: String, playerVersion: String,series: String, subtitles: [Any], audio:[Any], gen: [Genres], duration: TimeInterval, currentDuration: TimeInterval, episodeNumber: Int, isDrm: Bool,NotApplicable:String,generestring:String,Cast:[Any],assetsubtype:String,buisnessType:String,actors:[Any],skiptime:String) {
        
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
        
    }
    
    public func DataModelContent(with DataModel:CurrentItem)
    {
                   contentName = DataModel.channel_Name
                   contentId = DataModel.content_id
                   genre = DataModel.geners
                   duration = Zee5PlayerPlugin.sharedInstance().getDuration()
                   currentDuration = Zee5PlayerPlugin.sharedInstance().getCurrentTime()
                   series = DataModel.channel_Name  // TT  // For Live only we have to pass
                   episodeNumber = DataModel.episode_number
                   DrmVideo = DataModel.isDRM
                   Subtitles = DataModel.subTitles
                   realeseDate = DataModel.release_date
                   assetSubtype = DataModel.asset_subtype
                   Buisnesstype = DataModel.business_type
                   skipIntroTime = DataModel.skipintrotime
        
                   if DataModel.charecters.count>0{
                       Charecters  = DataModel.charecters
                    }
                   
                  let value = genre.map{$0.value}
                  genereString = value.joined(separator: ",")
                  print("** Genre **\(genereString)")
        
               if DataModel.audioLanguages.count>0{
                audiolanguage = DataModel.audioLanguages
                let audioString = DataModel.audioLanguages.map{$0}
                print(" string *** \(audioString)")
                }
                   PlayerVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "nil"
                  
    }
    
}

// MARK:- Ad Events Analytics

extension AllAnalyticsClass
{
    // MARK:- AdInitialize
    
    public func ADInitize(with data: NSDictionary , CustomTags:NSDictionary)
    {
     
        let parameter : Set = [
            Keys.AD_INITIALIZED.TITLE ~>> contentName == "" ? notAppplicable:contentName,
            Keys.AD_INITIALIZED.SOURCE ~>> notAppplicable ,   // TT It Should (n-1) Page Where it come from
            Keys.AD_INITIALIZED.AD_DURATION ~>> data.value(forKey: "duration") as? String ?? notAppplicable,
            Keys.AD_INITIALIZED.AD_CATEGORY ~>> data.value(forKey: "streamType") as? String ?? notAppplicable,
            Keys.AD_INITIALIZED.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
            Keys.AD_INITIALIZED.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
            Keys.AD_INITIALIZED.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
            Keys.AD_INITIALIZED.CHARACTERS ~>> Charecters.count > 0 ? Charecters.description:notAppplicable,
            Keys.AD_INITIALIZED.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
            Keys.AD_INITIALIZED.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
            Keys.AD_INITIALIZED.SERIES ~>> series == "" ? notAppplicable:series,
            Keys.AD_INITIALIZED.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
            Keys.AD_INITIALIZED.PREVIEW_STATUS ~>> "",                                                         // TT
            Keys.AD_INITIALIZED.PAGE_NAME ~>> notAppplicable,
            Keys.AD_INITIALIZED.DRM_VIDEO ~>> DrmVideo,
            Keys.AD_INITIALIZED.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
            Keys.AD_INITIALIZED.CONTENT_ORIGINAL_LANGUAGE ~>> "",                                                // TT
            Keys.AD_INITIALIZED.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.description:notAppplicable,
            Keys.AD_INITIALIZED.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.description : notAppplicable,
            Keys.AD_INITIALIZED.TAB_NAME ~>> notAppplicable,
            Keys.AD_INITIALIZED.CAST_TO ~>> notAppplicable,
            Keys.AD_INITIALIZED.TV_CATEGORY ~>> notAppplicable,
            Keys.AD_INITIALIZED.PROVIDER_ID ~>> notAppplicable,
            Keys.AD_INITIALIZED.PROVIDER_NAME ~>> notAppplicable,
            Keys.AD_INITIALIZED.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? 0:currentDuration,
            Keys.AD_INITIALIZED.PLAYER_NAME ~>> CustomTags.value(forKey: "playerName") as? String ?? "Kaltura Player",
            Keys.AD_INITIALIZED.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
            Keys.AD_INITIALIZED.AD_PROVIDER ~>> "",
            Keys.AD_INITIALIZED.AD_POSITION ~>> CustomTags.value(forKey: "c3.ad.position") as? String ?? "nil",
            Keys.AD_INITIALIZED.AD_CATEGORY ~>> "",
            Keys.AD_INITIALIZED.AD_LOCATION ~>> "",
            Keys.AD_INITIALIZED.AD_CUE_TIME ~>> "",
            Keys.AD_INITIALIZED.AD_DESTINATION_URL ~>> "",
            Keys.AD_INITIALIZED.CDN ~>> "",
            Keys.AD_INITIALIZED.DNS ~>> notAppplicable,
            Keys.AD_INITIALIZED.CAROUSAL_NAME ~>> notAppplicable,
            Keys.AD_INITIALIZED.CAROUSAL_ID ~>> notAppplicable,

        ]
        analytics.track(Events.AD_INITIALIZED, trackedProperties: parameter)
        
    }
    
    // MARK:- AdView
       
       public func ADView(with data: NSDictionary , CustomTags:NSDictionary)
       {
    
           let parameter : Set = [
               Keys.AD_VIEW.TITLE ~>> data.value(forKey: "assetName") as? String ?? notAppplicable,
               Keys.AD_VIEW.SOURCE ~>> data.value(forKey: "streamUrl") as? String ?? notAppplicable,
               Keys.AD_VIEW.AD_DURATION ~>> data.value(forKey: "duration") as? String ?? notAppplicable,
               Keys.AD_VIEW.AD_CATEGORY ~>> data.value(forKey: "streamType") as? String ?? notAppplicable,
               Keys.AD_VIEW.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
               Keys.AD_VIEW.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId ,
               Keys.AD_VIEW.GENRE ~>>  genereString  == "" ? notAppplicable : genereString,
               Keys.AD_VIEW.CHARACTERS ~>> Charecters.count > 0 ? Charecters.description:notAppplicable,                                                           // TT
               Keys.AD_VIEW.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
               Keys.AD_VIEW.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
               Keys.AD_VIEW.SERIES ~>> series == "" ? notAppplicable:series,
               Keys.AD_VIEW.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
               Keys.AD_VIEW.PREVIEW_STATUS ~>> "",                                                         // TT
               Keys.AD_VIEW.PAGE_NAME ~>> notAppplicable,
               Keys.AD_VIEW.DRM_VIDEO ~>> DrmVideo,
               Keys.AD_VIEW.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
               Keys.AD_VIEW.CONTENT_ORIGINAL_LANGUAGE ~>> "",                                                // TT
               Keys.AD_VIEW.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.description:notAppplicable,
               Keys.AD_VIEW.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.description : notAppplicable,
               Keys.AD_VIEW.TAB_NAME ~>> notAppplicable,
               Keys.AD_VIEW.CAST_TO ~>> notAppplicable,
               Keys.AD_VIEW.TV_CATEGORY ~>> notAppplicable,
               Keys.AD_VIEW.PROVIDER_ID ~>> notAppplicable,
               Keys.AD_VIEW.PROVIDER_NAME ~>> notAppplicable,
               Keys.AD_VIEW.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? 0:currentDuration,
               Keys.AD_VIEW.PLAYER_NAME ~>> CustomTags.value(forKey: "playerName") as? String ?? "Kaltura Player",
               Keys.AD_VIEW.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
               Keys.AD_VIEW.AD_PROVIDER ~>> "",
               Keys.AD_VIEW.AD_POSITION ~>> CustomTags.value(forKey: "c3.ad.position") as? String ?? "nil",
               Keys.AD_VIEW.AD_CATEGORY ~>> "",
               Keys.AD_VIEW.AD_LOCATION ~>> "",
               Keys.AD_VIEW.AD_CUE_TIME ~>> "",
               Keys.AD_VIEW.AD_DESTINATION_URL ~>> "",
               Keys.AD_VIEW.CDN ~>> "",
               Keys.AD_VIEW.DNS ~>> notAppplicable,
               Keys.AD_VIEW.CAROUSAL_NAME ~>> notAppplicable,
               Keys.AD_VIEW.CAROUSAL_ID ~>> notAppplicable,

           ]
           analytics.track(Events.AD_VIEW, trackedProperties: parameter)
           
       }
    
    
// MARK:- AdSkiped
    
    public func ADSkiped(with data: NSDictionary , CustomTags:NSDictionary)
       {
         
           let parameter : Set = [
               Keys.AD_SKIP.ELEMENT ~>> "Skip Add",
               Keys.AD_SKIP.SOURCE ~>> data.value(forKey: "streamUrl") as? String ?? notAppplicable,
               Keys.AD_SKIP.AD_DURATION ~>> data.value(forKey: "duration") as? String ?? notAppplicable,
               Keys.AD_SKIP.AD_CATEGORY ~>> data.value(forKey: "streamType") as? String ?? notAppplicable,
               Keys.AD_SKIP.BUTTON_TYPE ~>> "Button",
               Keys.AD_SKIP.PREVIEW_STATUS ~>> "",
               Keys.AD_SKIP.PAGE_NAME ~>> notAppplicable,
               Keys.AD_SKIP.DRM_VIDEO ~>> DrmVideo,
               Keys.AD_SKIP.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
               Keys.AD_SKIP.CONTENT_ORIGINAL_LANGUAGE ~>> "",
               Keys.AD_SKIP.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.description:notAppplicable,
               Keys.AD_SKIP.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.description : notAppplicable,
               Keys.AD_SKIP.TAB_NAME ~>> notAppplicable,
               Keys.AD_SKIP.CAST_TO ~>> notAppplicable,
               Keys.AD_SKIP.TV_CATEGORY ~>> notAppplicable,
               Keys.AD_SKIP.PROVIDER_ID ~>> notAppplicable,
               Keys.AD_SKIP.PROVIDER_NAME ~>> notAppplicable,
               Keys.AD_SKIP.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? 0:currentDuration,
               Keys.AD_SKIP.PLAYER_NAME ~>> CustomTags.value(forKey: "playerName") as? String ?? notAppplicable,
               Keys.AD_SKIP.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
               Keys.AD_SKIP.AD_PROVIDER ~>> "",
               Keys.AD_SKIP.AD_POSITION ~>> CustomTags.value(forKey: "c3.ad.position") as? String ?? notAppplicable,
               Keys.AD_SKIP.AD_CATEGORY ~>> "",
               Keys.AD_SKIP.AD_LOCATION ~>> "",
               Keys.AD_SKIP.AD_CUE_TIME ~>> "",
               Keys.AD_SKIP.AD_DESTINATION_URL ~>> "",
               Keys.AD_SKIP.CDN ~>> "",
               Keys.AD_SKIP.DNS ~>> notAppplicable,
               Keys.AD_SKIP.CAROUSAL_NAME ~>> notAppplicable,
               Keys.AD_SKIP.CAROUSAL_ID ~>> notAppplicable,

           ]
           analytics.track(Events.AD_SKIP, trackedProperties: parameter)
           
    }
    
  // MARK:- AdComplete
    
    public func ADComplete(with data: NSDictionary , CustomTags:NSDictionary)
          {
              print("Ad Dictionary\(data)")
              print("Ad Dictionary\(CustomTags)")
              
              
              let parameter : Set = [
                  Keys.AD_FORCED_EXIT.SOURCE ~>> data.value(forKey: "streamUrl") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.AD_DURATION ~>> data.value(forKey: "duration") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.AD_CATEGORY ~>> data.value(forKey: "streamType") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.TITLE ~>> data.value(forKey: "assetName") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
                  Keys.AD_FORCED_EXIT.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId,
                  Keys.AD_FORCED_EXIT.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
                  Keys.AD_FORCED_EXIT.CHARACTERS ~>> Charecters.count > 0 ? Charecters.description:notAppplicable,
                  Keys.AD_FORCED_EXIT.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
                  Keys.AD_FORCED_EXIT.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
                  Keys.AD_FORCED_EXIT.SERIES ~>> series == "" ? notAppplicable:series,
                  Keys.AD_FORCED_EXIT.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
                  Keys.AD_FORCED_EXIT.PREVIEW_STATUS ~>> "",
                  Keys.AD_FORCED_EXIT.PAGE_NAME ~>> notAppplicable,
                  Keys.AD_FORCED_EXIT.DRM_VIDEO ~>> DrmVideo,
                  Keys.AD_FORCED_EXIT.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
                  Keys.AD_FORCED_EXIT.CONTENT_ORIGINAL_LANGUAGE ~>> "",
                  Keys.AD_FORCED_EXIT.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.description:notAppplicable,
                  Keys.AD_FORCED_EXIT.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.description : notAppplicable,
                  Keys.AD_FORCED_EXIT.TAB_NAME ~>> notAppplicable,
                  Keys.AD_FORCED_EXIT.CAST_TO ~>> notAppplicable,
                  Keys.AD_FORCED_EXIT.TV_CATEGORY ~>> notAppplicable,
                  Keys.AD_FORCED_EXIT.PROVIDER_ID ~>> notAppplicable,
                  Keys.AD_FORCED_EXIT.PROVIDER_NAME ~>> notAppplicable,
                  Keys.AD_FORCED_EXIT.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? 0:currentDuration,
                  Keys.AD_FORCED_EXIT.PLAYER_NAME ~>> CustomTags.value(forKey: "playerName") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
                  Keys.AD_FORCED_EXIT.AD_PROVIDER ~>> "",
                  Keys.AD_FORCED_EXIT.AD_POSITION ~>> CustomTags.value(forKey: "c3.ad.position") as? String ?? notAppplicable,
                  Keys.AD_FORCED_EXIT.AD_LOCATION ~>> "",
                  Keys.AD_FORCED_EXIT.AD_CUE_TIME ~>> "",
                  Keys.AD_FORCED_EXIT.AD_DESTINATION_URL ~>> "",
                  Keys.AD_FORCED_EXIT.CDN ~>> "",
                  Keys.AD_FORCED_EXIT.DNS ~>> notAppplicable,
                  Keys.AD_FORCED_EXIT.CAROUSAL_NAME ~>> notAppplicable,
                  Keys.AD_FORCED_EXIT.CAROUSAL_ID ~>> notAppplicable,

              ]
            analytics.track(Events.AD_FORCED_EXIT, trackedProperties: parameter)
              
       }
    
     // MARK:- AdClicked
    
    public func ADClicked(with data: NSDictionary , CustomTags:NSDictionary)
       {
           print("Ad Dictionary\(data)")
           print("Ad Dictionary\(CustomTags)")
           
           
           let parameter : Set = [
               Keys.AD_CLICK.SOURCE ~>> data.value(forKey: "streamUrl") as? String ?? notAppplicable,
               Keys.AD_CLICK.TITLE ~>> data.value(forKey: "assetName") as? String ?? notAppplicable,
               Keys.AD_CLICK.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
               Keys.AD_CLICK.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId,
               Keys.AD_CLICK.GENRE ~>> genre.count>0 ? genre.description:notAppplicable,
               Keys.AD_CLICK.CHARACTERS ~>> Charecters.count > 0 ? Charecters.description:notAppplicable,
               Keys.AD_CLICK.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
               Keys.AD_CLICK.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
               Keys.AD_CLICK.SERIES ~>> series == "" ? notAppplicable:series,
               Keys.AD_CLICK.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
               Keys.AD_CLICK.PREVIEW_STATUS ~>> notAppplicable,
               Keys.AD_CLICK.PAGE_NAME ~>> notAppplicable,
               Keys.AD_CLICK.DRM_VIDEO ~>> DrmVideo,
               Keys.AD_CLICK.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
               Keys.AD_CLICK.CONTENT_ORIGINAL_LANGUAGE ~>> "",
               Keys.AD_CLICK.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.description:notAppplicable,
               Keys.AD_CLICK.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.description : notAppplicable,
               Keys.AD_CLICK.TAB_NAME ~>> notAppplicable,
               Keys.AD_CLICK.CAST_TO ~>> notAppplicable,
               Keys.AD_CLICK.TV_CATEGORY ~>> notAppplicable,
               Keys.AD_CLICK.PROVIDER_ID ~>> notAppplicable,
               Keys.AD_CLICK.PROVIDER_NAME ~>> notAppplicable,
               Keys.AD_CLICK.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? 0:currentDuration,
               Keys.AD_CLICK.PLAYER_NAME ~>> CustomTags.value(forKey: "playerName") as? String ?? notAppplicable,
               Keys.AD_CLICK.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
               Keys.AD_CLICK.AD_PROVIDER ~>> "",
               Keys.AD_CLICK.AD_POSITION ~>> CustomTags.value(forKey: "c3.ad.position") as? String ?? notAppplicable,
               Keys.AD_CLICK.AD_LOCATION ~>> "",
               Keys.AD_CLICK.AD_DURATION ~>> data.value(forKey: "duration") as? String ?? notAppplicable,
               Keys.AD_CLICK.AD_CATEGORY ~>> data.value(forKey: "streamType") as? String ?? notAppplicable,
               Keys.AD_CLICK.AD_CUE_TIME ~>> "",
               Keys.AD_CLICK.AD_DESTINATION_URL ~>> "",
               Keys.AD_CLICK.CDNstatic ~>> "",
               Keys.AD_CLICK.DNS ~>> notAppplicable,
               Keys.AD_CLICK.CAROUSAL_NAME ~>> notAppplicable,
               Keys.AD_CLICK.CAROUSAL_ID ~>> notAppplicable,

           ]
         analytics.track(Events.AD_CLICK, trackedProperties: parameter)
           
    }
    
    // MARK:- AdWatchDuration
    
    public func ADWatchedDuration(with data: NSDictionary , CustomTags:NSDictionary)
          {
              print("Ad Dictionary\(data)")
              print("Ad Dictionary\(CustomTags)")
              
              
              let parameter : Set = [
                  Keys.AD_WATCH_DURATION.SOURCE ~>> data.value(forKey: "streamUrl") as? String ?? "No Source",
                  Keys.AD_WATCH_DURATION.TITLE ~>> data.value(forKey: "assetName") as? String ?? "No Title",
                  Keys.AD_WATCH_DURATION.CONTENT_NAME ~>> contentName  == "" ? notAppplicable : contentName,
                  Keys.AD_WATCH_DURATION.CONTENT_ID ~>> contentId == "" ? notAppplicable:contentId,
                  Keys.AD_WATCH_DURATION.GENRE ~>> genereString  == "" ? notAppplicable : genereString,
                  Keys.AD_WATCH_DURATION.CHARACTERS ~>> Charecters.count > 0 ? Charecters.description:notAppplicable,
                  Keys.AD_WATCH_DURATION.CONTENT_DURATION ~>> duration == 0 ? 0:duration,
                  Keys.AD_WATCH_DURATION.PUBLISHING_DATE ~>> realeseDate == "" ? notAppplicable:realeseDate,
                  Keys.AD_WATCH_DURATION.SERIES ~>> series == "" ? notAppplicable:series,
                  Keys.AD_WATCH_DURATION.EPISODE_NO ~>> episodeNumber == 0 ? 0:episodeNumber,
                  Keys.AD_WATCH_DURATION.PREVIEW_STATUS ~>> "",
                  Keys.AD_WATCH_DURATION.PAGE_NAME ~>> "",
                  Keys.AD_WATCH_DURATION.DRM_VIDEO ~>> DrmVideo,
                  Keys.AD_WATCH_DURATION.SUBTITLES ~>> Subtitles.count > 0 ? true : false,
                  Keys.AD_WATCH_DURATION.CONTENT_ORIGINAL_LANGUAGE ~>> "",
                  Keys.AD_WATCH_DURATION.AUDIO_LANGUAGE ~>> audiolanguage.count > 0 ? audiolanguage.description:notAppplicable,
                  Keys.AD_WATCH_DURATION.SUBTITLE_LANGUAGE ~>> Subtitles.count > 0 ? Subtitles.description : notAppplicable,
                  Keys.AD_WATCH_DURATION.TAB_NAME ~>> notAppplicable,
                  Keys.AD_WATCH_DURATION.CAST_TO ~>> notAppplicable,
                  Keys.AD_WATCH_DURATION.TV_CATEGORY ~>> notAppplicable,
                  Keys.AD_WATCH_DURATION.PROVIDER_ID ~>> notAppplicable,
                  Keys.AD_WATCH_DURATION.PROVIDER_NAME ~>> notAppplicable,
                  Keys.AD_WATCH_DURATION.PLAYER_HEAD_POSITION ~>> currentDuration == 0 ? 0:currentDuration,
                  Keys.AD_WATCH_DURATION.PLAYER_NAME ~>> CustomTags.value(forKey: "playerName") as? String ?? notAppplicable,
                  Keys.AD_WATCH_DURATION.PLAYER_VERSION ~>> PlayerVersion == "" ? notAppplicable:PlayerVersion ,
                  Keys.AD_WATCH_DURATION.BUFFER_DURATION ~>> data.value(forKey: "adPosition") as? String ?? notAppplicable,
                  Keys.AD_WATCH_DURATION.WATCH_DURATION ~>> data.value(forKey: "adPosition") as? String ?? notAppplicable,
                  Keys.AD_WATCH_DURATION.CASTING_DURATION ~>> notAppplicable,
                  Keys.AD_WATCH_DURATION.AD_PROVIDER ~>> "",
                  Keys.AD_WATCH_DURATION.AD_POSITION ~>> CustomTags.value(forKey: "c3.ad.position") as? String ?? "nil",
                  Keys.AD_WATCH_DURATION.AD_LOCATION ~>> "",
                  Keys.AD_WATCH_DURATION.AD_DURATION ~>> data.value(forKey: "duration") as? String ?? notAppplicable,
                  Keys.AD_WATCH_DURATION.AD_CATEGORY ~>> data.value(forKey: "streamType") as? String ?? notAppplicable,
                  Keys.AD_WATCH_DURATION.AD_CUE_TIME ~>> "",
                  Keys.AD_WATCH_DURATION.AD_DESTINATION_URL ~>> notAppplicable,
                  Keys.AD_WATCH_DURATION.DNS ~>> notAppplicable,
                  Keys.AD_WATCH_DURATION.CAROUSAL_NAME ~>> notAppplicable,
                  Keys.AD_WATCH_DURATION.CAROUSAL_ID ~>> notAppplicable,

              ]
            analytics.track(Events.AD_WATCH_DURATION, trackedProperties: parameter)
              
       }
}


func getAge() -> String {
    guard let data = Zee5UserSettingsManager.shared.getUserSettingsModal() else {return ""}
      
    for settingDataModel in data {
           if settingDataModel.key == "age"
           {
               #if DEBUG
               print(settingDataModel.value!)
               #endif
            return (settingDataModel.value ?? "")
           }
       }
    return ""
}


extension AllAnalyticsClass
{
    
    
    
}
