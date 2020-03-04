//
//  Zee5AnalyticsManager.swift
//  Zee5PlayerPlugin
//
//  Created by Miri on 08/08/2019.
//

import Foundation
import ApplicasterSDK
import AVFoundation

@objc public class Zee5AnalyticsManager: NSObject {

    @objc public static let shared = Zee5AnalyticsManager()

    enum ParametersName:String {
        case category = "category"
        case action = "action"
        case lable = "lable"
        case time = "time"
        case location = "location"
        case duration = "duration"
        case pageHeadline = "pageHeadline"
        case programName = "programName"
        case pageType = "pageType"
        case station = "station"
        case itemId = "itemId"
    }


    enum EventNameType:String {
        case pressPlay = "לחיצה על play להפעלה"
        case pressPause = "לחיצה על pause"
        case progress = "התקדמות [%]"
        case resume = "חידוש נגינה"
        case pressExtendScreen = "לחיצה על הגדלת מסך"
        case share = "שיתוף"
    }

    @objc public enum ActionType:Int {
        case play = 0
        case pause
        case progress
        case resume
        case moveToFullScreen
        case share

        func name() -> String {
            switch self {
            case .play:
                return "play"
            case .pause:
                return "pause"
            case .progress:
                return "progress"
            case .resume:
                return "resume"
            case .moveToFullScreen:
                return "moveToFullScreen"
            case .share:
                return "share"
            }
        }
    }

    public enum CategoryType:String {
        case tv = "tv"
        case radio = "radio"
    }


    public enum PageType:String {
        case live = "live program"
        case recorded = "recorded program"
    }


    @objc public enum PlayerType:Int {
        case miniPlayer = 0
        case regularPlayer
        case backgroundPlayer

        func name() -> String {
            switch self {
            case .miniPlayer:
                return "נגן צף"
            case .regularPlayer:
                return "נגן רגיל"
            case .backgroundPlayer:
                return "נגן רקע"
            }
        }
    }

    @objc public enum ItemType:Int {
        case native = 0
        case chromecast
        case youtube

        func name() -> String {
            switch self {
            case .native:
                return "בינת"
            case .chromecast:
                return "chromecast"
            case .youtube:
                return "youtube"
            }
        }
    }

    private var startDate: Date?
    private var sumDuration: Int64 = 0

    struct Event {
        var eventNameType: String?
        var category:String?
        var action: String?
        var time: NSDate?
        var location: CGFloat?
        var duration: Int64?
        var label: String?
        var pageHeadline: String?
        var programName: String?
        var pageType: String?
        var station: String?
        var itemId: String?
        var playerType: String?
        var itemType: String?
    }

    // MARK: - Initialization
    private override init() {
        super.init()
    }

    func playerEnter() {
        if startDate == nil {
            startDate = Date()
        }
    }

    func playerExit() {
        startDate = nil
        sumDuration = 0
    }

    public func pauseButtonClicked() {
        if let startDate = startDate {
            let duration = (Int64)(NSDate().seconds(after: startDate))
            sumDuration = sumDuration + duration
        }
        startDate = nil
    }

    public func resumeButtonClicked() {
        startDate = Date()
    }

    @objc public func sendEvent(action: ActionType, playerType: PlayerType, itemType: ItemType, zee5Player: zee5PlayerViewController?) -> Void {

        guard let player = zee5Player else {
            return
        }

        guard let playable = player.playerController.currentItem else {
            return
        }

        var event = Event()

        switch action {
        case .play:
            event.eventNameType = EventNameType.pressPlay.rawValue
        case .pause:
            event.eventNameType = EventNameType.pressPause.rawValue
        case .progress:
            event.eventNameType = EventNameType.progress.rawValue
        case .resume:
            event.eventNameType = EventNameType.resume.rawValue
        case .moveToFullScreen:
            event.eventNameType = EventNameType.pressExtendScreen.rawValue
        case .share:
            event.eventNameType = EventNameType.share.rawValue
        }

        if playable.isAudioOnly == true {
            event.category = CategoryType.radio.rawValue
        }
        else {
            event.category = CategoryType.tv.rawValue
        }
        event.action = action.name()
        event.time = NSDate()  //Now

        if let playbackDuration = playable.playbackDuration {
             event.location = CGFloat(player.playerController.currentPlaybackTime) / CGFloat(playbackDuration)
        }
        if let startDate = startDate {
            event.duration = (Int64)(NSDate().seconds(after: startDate)) + sumDuration
        }
        else {
            event.duration = sumDuration
        }
        event.label = playable.playableName()
        event.pageHeadline = "" // from where do take it?

        if let liveModel = player.currentZee5PlableModel as? Live {
            event.programName = liveModel.currentProgram?.title
            event.station = liveModel.name
        }
        else if let onDemandModel = player.currentZee5PlableModel as? OnDemand {
            event.programName = onDemandModel.showName
            event.station = "" // from where do take it?
        }
        event.pageType = player.isLive() ? PageType.live.rawValue : PageType.recorded.rawValue

        event.itemId = playable.identifier as String?
        event.playerType = playerType.name()
        event.itemType = itemType.name()

        sendAnalytics(event: event)
    }


    private func sendAnalytics(event: Event){

//        if let eventName = event.action {
//            let params: [String : AnyHashable] = [ParametersName.category.rawValue : event.category as AnyHashable,
//                                                  ParametersName.action.rawValue : event.action as AnyHashable,
//                                                  ParametersName.time.rawValue : event.time?.getTimeAsString(),
//                                                  ParametersName.location.rawValue : percentFormatter(parcent: roundPercent(parcent: event.location)),
//                                                  ParametersName.duration.rawValue : durationFormatter(durationInSec: event.duration),
//                                                  ParametersName.lable.rawValue : event.label,
//                                                  ParametersName.pageHeadline.rawValue : event.pageHeadline,
//                                                  ParametersName.programName.rawValue : event.programName,
//                                                  ParametersName.pageType.rawValue : event.pageType,
//                                                  ParametersName.station.rawValue : event.station,
//                                                  ParametersName.itemId.rawValue : event.itemId]
//
//            APAnalyticsManager.shared.trackEvent(name: eventName, parameters: params, timed: true)
//        }

    }

    private func durationFormatter(durationInSec: Int64?) -> String { // HH:MM:SS

        guard let durationInSec = durationInSec else {
            return "0.0"
        }
        let hours = durationInSec / 60 / 60
        let minuets = durationInSec / 60 % 60
        let seconds = durationInSec % 60

        return String(format: "%02d:%02d:%02d", hours, minuets, seconds)
    }

    private func roundPercent(parcent: CGFloat?) -> CGFloat {
        guard let parcent = parcent else {
            return 0
        }
        return round(parcent * 10) / 10
    }

    private func percentFormatter(parcent: CGFloat?) -> String {
        /// Needs to fix the problem with CGFloat/Double


        //        if let parcent = parcent,
        //            parcent > 0 {
        //            print("parcent \(parcent)")
        //            print("parcent \(Int(parcent * 100))")
        //
        //            return String(format: "%2d%%", Int(parcent * 100))
        //        }
        //        else {
        return "0%"
        //        }
    }

}
