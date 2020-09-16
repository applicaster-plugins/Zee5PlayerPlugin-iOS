//
//  AnalyticEngine.swift
//  ZEE5PlayerSDK
//
//  Created by Abbas's Mac Mini on 22/08/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

import Foundation
import ConvivaSDK
import LotameDMP



var VideWatchInt = 0

public class AnalyticEngine: NSObject {
    @objc public static let shared = AnalyticEngine()

    var lastPlayerOrientation: ZeeAnalyticsPlayerOrientation?

    @objc public enum ZeeAnalyticsPlayerOrientation: Int  {
        case portrait
        case landscape
        
        func name() -> String {
            switch self {
            case .portrait:
                return "Portrait"
            case .landscape:
                return "Landscape"
            default:
                return ""
            }
        }
    }
    
    @objc public static func playerOrientationName(for value: ZeeAnalyticsPlayerOrientation) -> String {
        return value.name()
    }
    
    @objc public func startLotameAnalytics(with duration: String, quartileValue: String)
    {
        AllAnalyticsClass.shared.LotameAnalyticsData(with: duration, Quartilevalue: quartileValue)
    }
    
    @objc public func VideoStartTime(with time:NSInteger)
    {
        AllAnalyticsClass.shared.getVideoStartTime(Time: time)
    }
    @objc public func AudioLanguage(with Audio:String)
    {
        AllAnalyticsClass.shared.getcurrentAudio(Audio: Audio)
    }

   //MARK:- Conviva Player analytics
    
    @objc public func initializeConvivaAnalytics(customerKey: String, gatewayUrl: String) {
        do {
            switch ZEE5PlayerSDK.getConvivaEnvironment() {
            case Staging:
                try ConvivaAnalytics.shared.inititializeConvivaForTesting(testCustomerKey: customerKey, touchStoneUrl: gatewayUrl)
            case Production:
                try ConvivaAnalytics.shared.initializeConviva(customerKey: customerKey)
            default:
               break
            }
            ZeeUtility.utility.console("|||*** Conviva Initialized Successfully ***|||")
        }
        catch {
            ZeeUtility.utility.console("initializeConvivaAnalytics Error: \(error.localizedDescription)")
        }
    }
    
    @objc public func setupConvivaSession(with data: NSDictionary)
    {
        ConvivaAnalytics.shared.createConvivaSession(with: data)
        
        // Setup player interface
        ConvivaAnalytics.shared.setupPlayerInterface()
    }
    
    @objc public func setupConvivvaErrorMsg(with Error: NSString, COSeverity:NSInteger)
    {
        ConvivaAnalytics.shared.ReportErrorConviva(with: Error, Severity: COSeverity)
    }
    
    @objc public func updateUserStatus(event: convivaUserWait){
        ConvivaAnalytics.shared.userWaitPlayback(Event: event)
    }
    
    @objc public func updatePlayerState(state:ZEEConvivaPlayerState.RawValue)
    {
        ConvivaAnalytics.shared.reportPlayerState(currentState: state)  
    }
    
    @objc public func updateVideoBitrate(with value: Int64) {
        ConvivaAnalytics.shared.reportPlayerBitrate(bitrate: value)
    }
    
    @objc public func setSeekStartTime(duration: Int64) {
        ConvivaAnalytics.shared.SeekStarted(SeekStart: duration)
    }
    
    @objc public func setSeekEndTime(duration: Int64)
    {
        ConvivaAnalytics.shared.SeekEnded(SeekEnd: duration)
    }
    
    @objc public func cleanupVideoSesssion()
    {
        ConvivaAnalytics.shared.cleanupSession()
        VideWatchInt = 0
    }
    
    @objc public func updateMetadata(with data: NSDictionary)
    {
        ConvivaAnalytics.shared.updateContentMetadata(with: data)
    }
    
    @objc public func setupConvivaAdSession(with data: NSDictionary, customTags: NSDictionary)
    {
        ConvivaAnalytics.shared.createConvivaAdSession(with: data, tags: customTags)
    }
    @objc public func EndAdbreak()
    {
         ConvivaAnalytics.shared.EndAdSession()
    }

    // MARK:- Mixpanel Player Events
    
    @objc public func CurrentItemData(with data: CurrentItem)
    {
        AllAnalyticsClass.shared.DataModelContent(with: data)
    }
    @objc public func VideoPlayAnalytics()
       {
        AllAnalyticsClass.shared.VideoViewEvent()
      
       }
    @objc public func AutoSeekAnalytics(with Direction: NSString, Starttime :NSInteger, Endtime :NSInteger)
      {
        AllAnalyticsClass.shared.AutoseekChanged(with: Direction, EndValue: Endtime, startvalue: Starttime)
      }
    
    @objc public func ReplayVideo()
      {
            AllAnalyticsClass.shared.ReplayVideoEvent()
      }
    
    @objc public func skipIntroAnalytics(with skipstartTime: NSString, SkipendTime: NSString)
      {
        AllAnalyticsClass.shared.SkipIntoVideo(with: skipstartTime, SkipendTime: SkipendTime)
      }
    
    @objc public func skipRecapAnalytics(with skipstartTime: NSString, SkipendTime: NSString)
      {
           AllAnalyticsClass.shared.SkipRecapVideo(with: skipstartTime, SkipendTime: SkipendTime)
      }
    
    @objc public func watchCreditsAnalytics(with StartTime: NSString)
      {
        AllAnalyticsClass.shared.watchCredit(with: StartTime)
      }
    
    @objc public func playerPauseAnalytics()
     {
         AllAnalyticsClass.shared.PauseEvent()
     }
    @objc public func playerResumeAnalytics()
     {
        AllAnalyticsClass.shared.PlayResumeEvent()
     }
    @objc public func seekValueChangeAnalytics(with Direction: NSString, Starttime :NSInteger, EndTime :NSInteger)
     {
         AllAnalyticsClass.shared.Seekbar_ChangeEvent(with: Direction, StartTime: Starttime, EndTime: EndTime)
     }
    @objc public func playerbufferStartAnalytics()
     {
         AllAnalyticsClass.shared.BufferStartEvent()
     }
    @objc public func playerbufferEndAnalytics(with BufferEnd: Int)
     {
        AllAnalyticsClass.shared.BufferENDEvent(with: BufferEnd)
     }
    
    @objc public func playerOrientationChanged(to orientation: ZeeAnalyticsPlayerOrientation) {
        guard let lastPlayerOrientation = self.lastPlayerOrientation, lastPlayerOrientation != orientation else {
            self.lastPlayerOrientation = orientation
            return
        }
        
        AllAnalyticsClass.shared.playerOrientationChanged(from: lastPlayerOrientation.name(), to: orientation.name())
        self.lastPlayerOrientation = orientation
    }
    
    @objc public func VideoExitAnalytics()
     {
         AllAnalyticsClass.shared.VideoExit()
     }
    @objc public func PopUpLaunch(with PopUpName:String){
        AllAnalyticsClass.shared.PopUpLaunch(with: PopUpName)
    }
    @objc public func PopUpCTAPressed(with PopUpName:String , POpUpCTAName:String){
        AllAnalyticsClass.shared.PopUpCTApressed(with: POpUpCTAName, PopUpName: PopUpName)
      }
    
    @objc public func PlayBackError (with ErrorMessage:String)
    {
        AllAnalyticsClass.shared.PlayBackError(with: ErrorMessage)
    }

    @objc public func audiolangChangeAnalytics (with oldAudio: String, newAudio: String ,Mode:String )
     {
        AllAnalyticsClass.shared.AudiochangeEvent(with: oldAudio, New: newAudio, TrackingMode: Mode)
     }
    
    @objc public func subtitlelangChangeAnalytics (with oldSubtitle: String, newSubtitle: String ,Mode:String)
     {
          AllAnalyticsClass.shared.SubtitleLangChangeEvent(with: oldSubtitle, New: newSubtitle, TrackingMode: Mode)
     }
    
    @objc public func castingStartedAnalytics (with CastTo:String)
    {
        AllAnalyticsClass.shared.CastingStartEvent(with: CastTo)
    }

    @objc public func castingEndAnalytics (with CastTo:String)
    {
         AllAnalyticsClass.shared.CastingEndEvent(with: CastTo)
    }
    
    @objc public func videoWatchDurationAnalytic ()
    {
        AllAnalyticsClass.shared.VideoWatchDuration()
    }
    
    
    @objc public func playerCTA (with Element: String)
       {
        AllAnalyticsClass.shared.PlayerBtnPressed(with: Element)
       }
    @objc public func CTAs (with Ctatype: String , ctaname:String)
    {
        AllAnalyticsClass.shared.CTAs(with: Ctatype, CTaName: ctaname)
    }
    
    @objc public func screenViewEvent()
       {
           AllAnalyticsClass.shared.ScreenViewEvent()
       }
       
     // MARK:- For Downlaod Anlytics Events
    
    @objc public func downloadStart (with Quality:String)
    {
        AllAnalyticsClass.shared.DownloadStart(with: Quality)
    }
    
    public func downloadCompleteOrFail (with item: DownloadItem)
    {
        AllAnalyticsClass.shared.DownloadCompleteOrFail(with: item)
    }
    
    public func downloadDelete (with item: DownloadItem)
       {
           AllAnalyticsClass.shared.DownloadDelete(with: item)
       }
    
    public func downloadPlayClick (with item:DownloadItem)
    {
        AllAnalyticsClass.shared.DownloadPlayClick(with: item)
    }
    @objc public func DownloadCTAClicked ()
    {
        AllAnalyticsClass.shared.DownloadCTAclicked()
    }

    
    
     // MARK:- Mixpanel Ad Events
    
    @objc public func SetupMixpanelAnalytics(with data: NSDictionary, tags: NSDictionary)
    {
        AllAnalyticsClass.shared.ADInitize(with: data, CustomTags: tags)
        AllAnalyticsClass.shared.ADsDataModelContent(with: data, tags: tags)
    }
    
    @objc public func AdSkipedAnlytics()
    {
        AllAnalyticsClass.shared.ADSkiped()
        AllAnalyticsClass.shared.ADComplete()
    }
    @objc public func AdCompleteAnalytics()
    {
        AllAnalyticsClass.shared.ADComplete()
    }
    @objc public func AdClickedAnalytics()
    {
        AllAnalyticsClass.shared.ADClicked()
    }
    @objc public func AdWatchDurationAnalytics()
    {
        AllAnalyticsClass.shared.ADWatchedDuration()
    }
    @objc public func AdViewAnalytics()
    {
        AllAnalyticsClass.shared.ADView()
    }
    @objc public func AdViewNumber(AdNo : NSInteger)
       {
        if AdNo == 3 {
            AllAnalyticsClass .shared .ADView3()
        }else if AdNo == 5{
             AllAnalyticsClass .shared .ADView5()
        }else if AdNo == 10{
             AllAnalyticsClass .shared .ADView10()
        }else{
        }
       }
   
    
}
