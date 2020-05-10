//
//  Utility.swift
//  DemoProject
//
//  Created by Abbas's Mac Mini on 13/09/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

struct AppFont {
    private init() {}
    
    static func regular(size: CGFloat) -> UIFont {
        return UIFont(name: "NotoSans-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func light(size: CGFloat) -> UIFont {
        return UIFont(name: "NotoSans-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func medium(size: CGFloat) -> UIFont {
        return UIFont(name: "NotoSans-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func semibold(size: CGFloat) -> UIFont {
        return UIFont(name: "NotoSans-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func bold(size: CGFloat) -> UIFont {
        return UIFont(name: "NotoSans-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
}

struct AppColor {
    private init() {}
    
    static let gray = UIColor.init(hex: "2c0b2d")
    static let white = UIColor.init(hex: "cfc3ca")
    static let pink = UIColor.init(hex: "ff0091")
    static let lightGray = UIColor.init(hex: "d8d8d8")
    static let progressGray = UIColor.init(hex: "979797")
    static let aquaGreen = UIColor.init(hex: "20adb0")
    
    static let gradient = [UIColor.init(hex: "ed0032]"), UIColor.init(hex: "b300cf")]
}

struct AppNotification {
    private init() {}
    
    static let remindLater = Notification.Name("NotificationRemindMeLater")
    static let renewNow = Notification.Name("NotificationRenewNow")
    static let cancelNewEpisode = Notification.Name("NotificationCancelNewEpisode")
    static let downloadNewEpisode = Notification.Name("NotificationDownloadNewEpisode")
    
    static let videoDetail = Notification.Name("NotificationContentDetailObject")
    static let editDownload = Notification.Name("NotificationEditDownloadItem")
    static let stateUpdate = Notification.Name("NotificationStateUpdate")
    static let downloadedItemProgress = Notification.Name("NotificationDownloadedItemProgress")
    static let downloadedItemState = Notification.Name("NotificationDownloadedItemState")
}

struct DownloadedItemKeys {
    static let id = "id"
    static let state = "state"
    static let downloadedBytes = "downloadedBytes"
    static let estimatedBytes = "estimatedBytes"
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
       let hex: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
       let scanner = Scanner(string: hex)
       if (hex.hasPrefix("#")) {
         scanner.scanLocation = 1
       }
       var color: UInt32 = 0
       scanner.scanHexInt32(&color)
       let mask = 0x000000FF
       let r = Int(color >> 16) & mask
       let g = Int(color >> 8) & mask
       let b = Int(color) & mask
       let red = CGFloat(r) / 255.0
       let green = CGFloat(g) / 255.0
       let blue = CGFloat(b) / 255.0
       self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

extension UIView {

    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: UIScreen.main.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.frame = UIScreen.main.bounds
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func applyGradient(withColors colors: [UIColor]) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = .zero
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        
        if let topLayer = self.layer.sublayers?.first, topLayer is CAGradientLayer {
            topLayer.removeFromSuperlayer()
        }
        
        self.layer.cornerRadius = self.frame.size.height / 2
        self.layer.masksToBounds = true

        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension CALayer {
    
    func applyGradientBorder(withColors colors: [UIColor], radius: CGFloat) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =  CGRect(origin: CGPoint.zero, size: self.bounds.size)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1)
        gradientLayer.colors = colors.map({$0.cgColor})

        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius).cgPath
        
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = shapeLayer

        self.addSublayer(gradientLayer)
    }
}

extension UITableView {
    
    func setEmptyStateView(over controller: UIViewController) {
        let bundle = Bundle(for: DownloadRootController.self)
        guard let emptyView = bundle.loadNibNamed(EmptyView.identifier, owner: self, options: nil)?.first as? EmptyView else { return }
        emptyView.frame = self.frame
        emptyView.currentView = controller
        self.backgroundView = emptyView
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

extension UIImageView {
    
    func setImage(with str: String?) {
        if let str = str, let url = URL(string: str) {
            
            let bundle = Bundle(for: DownloadRootController.self)
            if #available(iOS 13.0, *) {
                let img = UIImage(named: "placeholder", in: bundle, with: nil)
                self.sd_setImage(with: url, placeholderImage: img)
            } else {
                // Fallback on earlier versions
                let img = UIImage(named: "placeholder", in: bundle, compatibleWith: nil)
                self.sd_setImage(with: url, placeholderImage: img)
            }
        }
    }
}

extension UIDevice {
    func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    //MARK: Get String Value
    var totalDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var freeDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var usedDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var totalDiskSpaceInMB:String {
        return MBFormatter(totalDiskSpaceInBytes)
    }
    
    var freeDiskSpaceInMB:String {
        return MBFormatter(freeDiskSpaceInBytes)
    }
    
    var usedDiskSpaceInMB:String {
        return MBFormatter(usedDiskSpaceInBytes)
    }
    
    // MARK: Get raw value
    var totalDiskSpaceInBytes:Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }
    
    var freeDiskSpaceInBytes:Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    
    var usedDiskSpaceInBytes:Int64 {
        return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }
}
