//
//  SleepModeView.swift
//  Pods
//
//  Created by Miri on 23/12/2018.
//

import Foundation

public protocol sleepModeProtocol {
    func sleepModeConfiguration(minutes: Int)
}

class SleepModeView: UIView {
    
    @IBOutlet weak var touchEventView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet var buttonsViewCollection: [UIButton]?
    @IBOutlet weak var closeButton: UIButton?
    @IBOutlet weak var dividerView: UIView?

    public var delegate: sleepModeProtocol!
    var intervalArray: [String]?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector (touchEventViewTuched (_:)))
        self.touchEventView.addGestureRecognizer(gesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func set(configuration:NSDictionary?, pluginStyles: [String : Any]?) {
        StylesHelper.setColorforView(view: self.mainView, key: "sleep_mode_bg_color", from: pluginStyles)

        if let dividerView = dividerView {
            StylesHelper.setColorforView(view: dividerView, key: "sleep_mode_bottom_divider_color", from: pluginStyles)
        }
        
        if let configuration = configuration {
            if let title = configuration["sleep_mode_title"] as? String,
                let titleLabel = titleLabel{
                titleLabel.text = title
                StylesHelper.setFontforLabel(label: titleLabel, fontNameKey: "action_text_sleep_mode_font_name", fontSizeKey: "action_text_sleep_mode_font_size", from: pluginStyles)
                StylesHelper.setColorforLabel(label: titleLabel, key: "action_text_sleep_mode_color", from: pluginStyles)
            }
            if let closeButtonTitle = configuration["sleep_mode_close_title"] as? String,
                let closeButton = closeButton {
                closeButton.setTitle(closeButtonTitle, for: .normal)
                StylesHelper.setFontforButton(button: closeButton, fontNameKey: "close_text_sleep_mode_font_name", fontSizeKey: "close_text_sleep_mode_font_size", from: pluginStyles)
                StylesHelper.setColorforButton(button: closeButton, key: "close_text_sleep_mode_color", from: pluginStyles)
            }
            if let interval = configuration["sleep_mode_interval"] as? String,
                let buttonsCollection = self.buttonsViewCollection {
                let intervalArray = interval.components(separatedBy: ",")
                for index in 0...buttonsCollection.count-1 {
                    self.intervalArray = intervalArray
                    let button: UIButton = buttonsCollection[index]
                    button.layer.cornerRadius = 30
                    button.clipsToBounds = true
                    button.titleLabel?.textAlignment = .center
                    StylesHelper.setColorforView(view: button, key: "button_color_sleep_mode_color", from: pluginStyles)
                    StylesHelper.setFontforButton(button: button, fontNameKey: "time_sleep_mode_font_name", fontSizeKey: "time_sleep_mode_font_size", from: pluginStyles)
                    StylesHelper.setColorforButton(button: button, key: "time_sleep_mode_color", from: pluginStyles)
                    if index != 0 {
                         button.setTitle(String(format: "%@\n%@", intervalArray[index-1], "דקות") , for: .normal)
                    }
                }
            }
        }
    }
    
    func close() {
        UIView.animate(withDuration: 0.3, animations: {
            self.touchEventView.alpha = 0.01
            self.mainView.center.y += self.frame.height
        }) { (success) in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func timeButtonClick(sender: UIButton) {
        self.close()
        guard let intervalArray = self.intervalArray,
            sender.tag > 0,
            let minutesStr = intervalArray[sender.tag - 1] as String?,
            let minutes = Int(minutesStr) else {
                self.delegate.sleepModeConfiguration(minutes:0)
            return
        }
        self.delegate.sleepModeConfiguration(minutes:minutes*60)
        
    }
    
    @IBAction func closeButtonClick(sender: UIButton) {
        self.close()
    }
    
    //MARK: - Main view touch event
    @objc func touchEventViewTuched(_ sender:UITapGestureRecognizer){
        self.close()
    }
}
