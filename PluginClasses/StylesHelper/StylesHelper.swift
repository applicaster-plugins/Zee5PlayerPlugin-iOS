//
//  StylesHelper.swift
//  Zee5HomeScreen
//
//  Created by Miri on 04/03/2019.
//  Copyright © 2019 Applicaster Ltd. All rights reserved.
//
import Foundation

@objc class StylesHelper: NSObject {

    //Color
    @objc public static func setColorforLabel(label: UILabel, key:String, from dictionary:[String : Any]?) {
        if let dictionary = dictionary,
            let argbString = dictionary[key] as? String,
            !argbString.isEmptyOrWhitespace() {
            let color = UIColor(argbHexString: argbString)
            label.textColor = color
        }
    }

    @objc public static func setColorforButton(button: UIButton, key:String, from dictionary:[String : Any]?) {
        if let dictionary = dictionary,
            let argbString = dictionary[key] as? String,
            !argbString.isEmptyOrWhitespace() {
            let color = UIColor(argbHexString: argbString)
            button.setTitleColor(color, for: .normal)

        }
    }

    @objc public static func setColorforView(view: UIView, key:String, from dictionary:[String : Any]?) {
        if let dictionary = dictionary,
            let argbString = dictionary[key] as? String,
            !argbString.isEmptyOrWhitespace() {
            let color = UIColor(argbHexString: argbString)
            view.backgroundColor = color
        }
    }

    // Font
    @objc public static func setFontforLabel(label: UILabel, fontNameKey:String, fontSizeKey:String, from dictionary:[String : Any]?) {
        var font = UIFont.systemFont(ofSize: 10)
        if let dictionary = dictionary,
            let fontName = dictionary[fontNameKey] as? String,
            let fontSizeString = dictionary[fontSizeKey] as? String,
            let fontSize = CGFloat(fontSizeString),
            let tempFont = UIFont(name: fontName, size: fontSize) {
            font = tempFont
        }
        label.font = font
    }

    @objc public static func setFontforButton(button: UIButton, fontNameKey:String, fontSizeKey:String, from dictionary:[String : Any]?) {
        var font = UIFont.systemFont(ofSize: 10)
        if let dictionary = dictionary,
            let fontName = dictionary[fontNameKey] as? String,
            let fontSizeString = dictionary[fontSizeKey] as? String,
            let fontSize = CGFloat(fontSizeString),
            let tempFont = UIFont(name: fontName, size: fontSize) {
            font = tempFont
        }
        button.titleLabel?.font = font
    }
}
