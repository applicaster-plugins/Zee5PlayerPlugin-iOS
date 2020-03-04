//
//  HybridCollectionViewLiveHeaderCell.swift
//  Zee5PlayerPlugin
//
//  Created by Miri on 25/12/2018.
//

import Foundation

class HybridCollectionViewLiveHeaderCell : UICollectionReusableView {

    public var model: Live?
    public var recommendationModel: Live?

    // Info View
    @IBOutlet weak var lineView: UIView?
    @IBOutlet weak var liveLabel: UILabel?
    @IBOutlet weak var liveView: UIView?
    @IBOutlet weak var channelNameLabel: UILabel?
    @IBOutlet weak var programNameLabel: UILabel?

    // Program view
    @IBOutlet weak var infoProgramView: UIView?
    @IBOutlet weak var nextProgramTitleLabel: UILabel?
    @IBOutlet weak var nextProgramNameLabel: UILabel?
    @IBOutlet weak var nextProgramTimeLabel: UILabel?

    // Recommendation Header
    @IBOutlet weak var recommendationTitleLabel: UILabel?
    @IBOutlet weak var dividerView: UIView?

    func set(model:Live?, pluginStyles: [String : Any]?) {
        guard let model = model else {
            return
        }

        self.model = model
        self.infoPlayerViewConfiguration(with: pluginStyles)
        // configuration for digital radio mode
        if self.model?.isDigitalRadio == true {
            self.configurationForDigitalRadio(with: pluginStyles)
        }
        else {
            self.programViewConfiguration(with: pluginStyles)
        }
        self.headerViewConfiguration(with: pluginStyles)
    }

    // Info View

    func infoPlayerViewConfiguration(with pluginStyles: [String : Any]?) {
        if let lineView = self.lineView {
            lineView.backgroundColor = UIColor.white
        }

        if let model = self.model,
            let channelNameLabel = self.channelNameLabel,
            let title = model.name {
            channelNameLabel.text = title
            StylesHelper.setFontforLabel(label: channelNameLabel, fontNameKey: "station_name_live_player_font_name", fontSizeKey: "station_name_live_player_font_size", from: pluginStyles)
            StylesHelper.setColorforLabel(label: channelNameLabel, key: "station_name_live_player_color", from: pluginStyles)
        }

        // Needs to take the default color from zapp
        var liveColorString = "#008F9FFF"
        if let model = self.model,
            let colorString = model.brandColor {
            liveColorString = colorString
        }

        if let liveLabel = self.liveLabel {
            StylesHelper.setFontforLabel(label: liveLabel, fontNameKey: "indicator_live_player_font_name", fontSizeKey: "ndicator_live_player_font_size", from: pluginStyles)
            StylesHelper.setColorforLabel(label: liveLabel, key: "indicator_live_player_color", from: pluginStyles)
        }

        if let liveView = self.liveView {
            liveView.backgroundColor = self.hexStringToUIColor(hex: liveColorString)
        }

        if let lineView = lineView {
            StylesHelper.setColorforView(view: lineView, key: "brand_line_live_player_color", from: pluginStyles)
        }
    }

    func programViewConfiguration(with pluginStyles: [String : Any]?) {

        if let model = self.model {
            if let nextProgramTitleLabel = self.nextProgramTitleLabel {
                nextProgramTitleLabel.text = model.nextProgramTitle
                StylesHelper.setFontforLabel(label: nextProgramTitleLabel, fontNameKey: "next_text_live_player_font_name", fontSizeKey: "next_text_live_player_font_size", from: pluginStyles)
                StylesHelper.setColorforLabel(label: nextProgramTitleLabel, key: "next_text_live_player_color", from: pluginStyles)
            }


            if let programs = model.programs,
                programs.count > 0 {
                let currentProgram: Program = programs[0]
                if let programNameLabel = self.programNameLabel,
                    let programName = currentProgram.title {
                    programNameLabel.text = programName
                    StylesHelper.setFontforLabel(label: programNameLabel, fontNameKey: "show_name_live_player_font_name", fontSizeKey: "show_name_live_player_font_size", from: pluginStyles)
                    StylesHelper.setColorforLabel(label: programNameLabel, key: "show_name_live_player_color", from: pluginStyles)
                }
                let nextProgram: Program = programs[1]
                if let nextProgramNameLabel = self.nextProgramNameLabel {
                    nextProgramNameLabel.text = nextProgram.title
                    StylesHelper.setFontforLabel(label: nextProgramNameLabel, fontNameKey: "show_name_next_live_player_font_name", fontSizeKey: "show_name_next_live_player_font_size", from: pluginStyles)
                    StylesHelper.setColorforLabel(label: nextProgramNameLabel, key: "show_name_next_live_player_color", from: pluginStyles)
                }

                if let startTime = nextProgram.startTime,
                    let endTime = nextProgram.endTime,
                    let nextProgramTimeLabel = self.nextProgramTimeLabel {
                    print("startTime \(startTime)")
                    print("endTime \(endTime)")

                    let startTimeDate = NSDate(timeIntervalSince1970: TimeInterval(startTime))
                    let endTimeDate = NSDate(timeIntervalSince1970: TimeInterval(endTime))

                    nextProgramTimeLabel.text = String(format: "%@ - %@", endTimeDate.getTimeAsString() ,startTimeDate.getTimeAsString())

                    StylesHelper.setFontforLabel(label: nextProgramTimeLabel, fontNameKey: "hour_next_live_player_font_name", fontSizeKey: "hour_next_live_player_font_size", from: pluginStyles)
                    StylesHelper.setColorforLabel(label: nextProgramTimeLabel, key: "hour_next_live_player_color", from: pluginStyles)
                }
            }
        }
    }

    func configurationForDigitalRadio(with pluginStyles: [String : Any]?) {
        if let model = self.model,
            let programNameLabel = self.programNameLabel,
            let title = model.entryTitle{
            programNameLabel.text = title
            StylesHelper.setFontforLabel(label: programNameLabel, fontNameKey: "show_name_live_player_font_name", fontSizeKey: "show_name_live_player_font_size", from: pluginStyles)
            StylesHelper.setColorforLabel(label: programNameLabel, key: "show_name_live_player_color", from: pluginStyles)
        }
    }

    func headerViewConfiguration(with pluginStyles: [String : Any]?) {
        if let recommendationTitleLabel = recommendationTitleLabel {
            StylesHelper.setFontforLabel(label: recommendationTitleLabel, fontNameKey: "more_shows_player_font_name", fontSizeKey: "more_shows_player_font_size", from: pluginStyles)
            StylesHelper.setColorforLabel(label: recommendationTitleLabel, key: "more_shows_player_color", from: pluginStyles)
        }

        if let dividerView = dividerView {
            StylesHelper.setColorforView(view: dividerView, key: "divider_player_color", from: pluginStyles)
        }
    }

    //MARK - Helpers

    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}
