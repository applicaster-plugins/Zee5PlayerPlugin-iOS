//
//  HybridCollectionViewCell.swift
//  Zee5PlayerPlugin
//
//  Created by Miri on 25/12/2018.
//

import Foundation

class HybridCollectionViewCell : UICollectionViewCell {

    @IBOutlet weak var itemImageView: APImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subTitleLabel: UILabel?
    @IBOutlet weak var dividerView: UIView?

    var atomEntry: APAtomEntryProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func setAtomEntry(atomEntry:APAtomEntryProtocol?, pluginStyles: [String : Any]?) {
        if let atomEntry = atomEntry {
            self.atomEntry = atomEntry
            if let title = atomEntry.title,
                let titleLabel = titleLabel {
                titleLabel.text = title
                StylesHelper.setFontforLabel(label: titleLabel, fontNameKey: "show_name_related_player_font_name", fontSizeKey: "show_name_related_player_font_size", from: pluginStyles)
                StylesHelper.setColorforLabel(label: titleLabel, key: "show_name_related_player_color", from: pluginStyles)
            }
            if let summary = atomEntry.summary,
                let subTitleLabel = subTitleLabel {
                subTitleLabel.text = summary
                StylesHelper.setFontforLabel(label: subTitleLabel, fontNameKey: "show_description_related_player_font_name", fontSizeKey: "show_description_related_player_font_size", from: pluginStyles)
                StylesHelper.setColorforLabel(label: subTitleLabel, key: "show_description_related_player_color", from: pluginStyles)
            }

            if let mediaGroups = atomEntry.mediaGroups {
                for mediaGroup in mediaGroups {
                    if let mediaGroup = mediaGroup as? APAtomMediaGroup {
                        var image: String? = nil
                        if let mediaItem = mediaGroup.mediaItemStringURL(forKey: "image_base_1x1") {
                            image = mediaItem
                        }
                        else if let mediaItem = mediaGroup.mediaItemStringURL(forKey: "image_base") {
                            image = mediaItem
                        }

                        if let imageName = image {
                            if let url = URL(string: imageName) {
                                self.itemImageView?.setImageWith(url, placeholderImage: Zee5ResourceHelper.imageNamed("placeholder_special_2"))
                            }
                        }
                    }
                }
            }
            if let dividerView = dividerView {
                StylesHelper.setColorforView(view: dividerView, key: "divider_player_color", from: pluginStyles)
            }
        }
    }
}
