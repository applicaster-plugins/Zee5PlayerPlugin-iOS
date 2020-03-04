//
//  HybridCollectionViewFooterCell.swift
//  Zee5PlayerPlugin
//
//  Created by Miri on 25/12/2018.
//

import Foundation

public protocol hybridCollectionViewFooter {
    func loadMoreRelatedContent()
}

class HybridCollectionViewFooterCell : UICollectionReusableView {

    @IBOutlet weak var moreButton: UIButton?
    public var delegate: hybridCollectionViewFooter!

    public func setData(title:String?, pluginStyles: [String : Any]?) {
        if let moreButton = moreButton,
            let title = title {
            moreButton.setTitle(title, for: .normal)
            moreButton.setTitle(title, for: .highlighted)

            StylesHelper.setFontforButton(button: moreButton, fontNameKey: "footer_text_font_name", fontSizeKey: "footer_text_font_size", from: pluginStyles)
            StylesHelper.setColorforButton(button: moreButton, key: "footer_text_color", from: pluginStyles)
        }

    }

    @IBAction func moreButtonClick(sender: UIButton) {
        self.delegate.loadMoreRelatedContent()
    }

}
