//
//  HybridCollectionViewHeaderCell.swift
//  Zee5PlayerPlugin
//
//  Created by Miri on 25/12/2018.
//

import Foundation

class HybridCollectionViewOnDemandHeaderCell : UICollectionReusableView {

    public var model: OnDemand?

    // Info View
    @IBOutlet weak var lineView: UIView?
    @IBOutlet weak var showNameLabel: UILabel?
    @IBOutlet weak var longTitleLabel: UILabel?
    @IBOutlet weak var longDescriptionLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var dividerView: UIView?

    // Recommendation Header
    @IBOutlet weak var recommendationTitleLabel: UILabel?

    func set(model:OnDemand?, pluginStyles: [String : Any]? ) {
        guard let model = model else {
            return
        }
        self.model = model
        self.infoPlayerViewConfiguration(with: pluginStyles)
    }

    // Info View
    func infoPlayerViewConfiguration(with pluginStyles: [String : Any]?) {
        if let lineView = lineView {
            StylesHelper.setColorforView(view: lineView, key: "brand_line_live_player_color", from: pluginStyles)
        }

        if let model = self.model {
            print("model.showName \(model.showName)")
            print("model \(model)")

            print("model.showName \(model.showName)")
            print("model \(model)")

            if let showNameLabel = showNameLabel,
                let name = model.showName {
                showNameLabel.text = name
                StylesHelper.setFontforLabel(label: showNameLabel, fontNameKey: "show_name_vod_player_font_name", fontSizeKey: "show_name_vod_player_font_size", from: pluginStyles)
                StylesHelper.setColorforLabel(label: showNameLabel, key: "show_name_vod_player_color", from: pluginStyles)
            }

            if let longTitleLabel = longTitleLabel,
                let title = model.longTitle {
                longTitleLabel.text = title
                StylesHelper.setFontforLabel(label: longTitleLabel, fontNameKey: "chapter_name_vod_player_font_name", fontSizeKey: "chapter_name_vod_player_font_size", from: pluginStyles)
                StylesHelper.setColorforLabel(label: longTitleLabel, key: "chapter_name_vod_player_color", from: pluginStyles)
            }

            if let longDescriptionLabel = longDescriptionLabel,
                let description = model.longDescription {
                longDescriptionLabel.text = description
                StylesHelper.setFontforLabel(label: longDescriptionLabel, fontNameKey: "chapter_description_vod_player_font_name", fontSizeKey: "chapter_description_vod_player_font_size", from: pluginStyles)
                StylesHelper.setColorforLabel(label: longDescriptionLabel, key: "chapter_description_vod_player_color", from: pluginStyles)
            }

            if let dateLabel = dateLabel,
                let publishedDate = model.publishDate {

                if let date = APAtomPipesParser.parseAtomDate(publishedDate) {
                    let dateFormat = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
                    dateLabel.text = String(format: "%@",dateFormat.getAsString(withFormat: "dd/MM/yyyy"))

                }
                StylesHelper.setFontforLabel(label: dateLabel, fontNameKey: "date_vod_player_font_name", fontSizeKey: "date_vod_player_font_size", from: pluginStyles)
                StylesHelper.setColorforLabel(label: dateLabel, key: "date_vod_player_color", from: pluginStyles)
            }

            if let recommendationTitleLabel = recommendationTitleLabel {
                StylesHelper.setFontforLabel(label: recommendationTitleLabel, fontNameKey: "more_shows_player_font_name", fontSizeKey: "more_shows_player_font_size", from: pluginStyles)
                StylesHelper.setColorforLabel(label: recommendationTitleLabel, key: "more_shows_player_color", from: pluginStyles)
            }

            if let dividerView = dividerView {
                StylesHelper.setColorforView(view: dividerView, key: "divider_player_color", from: pluginStyles)
            }
        }
    }


}
