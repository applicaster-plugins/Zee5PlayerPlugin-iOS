//
//  MiniPlayerContainerView.swift
//  Pods
//
//  Created by Miri on 23/12/2018.
//

import Foundation
import ZappPlugins

public protocol miniPlayerProtocol {
    func openHyBridViewController()
    func stopPlayer()
}

class MiniPlayerContainerView: UIView {

    @IBOutlet weak var playerView: UIView?
//    var playerViewController: Zee5PlayerViewController?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var channelNameLabel: UILabel?
    @IBOutlet weak var lineView: UIView?

    public var delegate: miniPlayerProtocol!
    var chromecastView:UIView?
    var panGestureRecognizer: UIPanGestureRecognizer?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    deinit {
        removePanGestureAction()
        NotificationCenter.default.removeObserver(self)
    }

    func commonInit() {
        //Observe single tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openHyBridViewController))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)

        //Observe close action only when chromecast is disabled
        if !ZAAppConnector.sharedInstance().chromecastDelegate.isSynced() {
            addPanGestureAction()
        }

        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(stop),
                    name: NSNotification.Name.APPlayerDidStop,
                    object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(chromecastSessionWilStart),
            name: NSNotification.Name(rawValue: "ChromecastSessionWillStart"),
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(chromecastSessionDidEnd),
            name: NSNotification.Name(rawValue: "ChromecastSessionDidEnd"),
            object: nil)
    }

    @objc public func openHyBridViewController() {
        self.delegate.openHyBridViewController()
    }

    @objc public func setStyles(playerViewController: Zee5PlayerViewController?, pluginStyles: [String : Any]?) {
        guard let playerVC = playerViewController else {
            return
        }

        let currentItem = playerVC.playerController.currentItem

        if let item = currentItem,
            item.isLive() == true,
            let channelNameLabel = self.channelNameLabel,
            let program = playerVC.playerController.currentItem as? APProgramProtocol {
                channelNameLabel.text = program.channelId
            StylesHelper.setFontforLabel(label: channelNameLabel, fontNameKey: "video_name_sticky_font_name", fontSizeKey: "video_name_sticky_font_size", from: pluginStyles)
            StylesHelper.setColorforLabel(label: channelNameLabel, key: "video_name_sticky_color", from: pluginStyles)
        } else if let lineView = self.lineView {
            lineView.removeAllSubviews()
        }

        if let nameLabel = self.nameLabel,
            let name = playerVC.playerController.currentItem.playableName() {
             nameLabel.text = name
            StylesHelper.setFontforLabel(label: nameLabel, fontNameKey: "video_name_sticky_font_name", fontSizeKey: "video_name_sticky_font_size", from: pluginStyles)
            StylesHelper.setColorforLabel(label: nameLabel, key: "video_name_sticky_color", from: pluginStyles)
        }

        if let lineView = self.lineView {
            StylesHelper.setColorforView(view: lineView, key: "video_name_sticky_color", from: pluginStyles)
        }
    }

    @objc func stop() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.APPlayerDidStop, object:nil)

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "APApplicasterPlayerMiniCloseNotification"), object: nil)
        self.removeFromSuperview()
    }

    var originalPosition: CGPoint?
    var currentPositionTouched: CGPoint?


    //MARK: - Close Gesture Actions

    @objc func addPanGestureAction() {
        if self.panGestureRecognizer == nil {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
            self.addGestureRecognizer(panGestureRecognizer)
            self.panGestureRecognizer = panGestureRecognizer
        }
    }

    @objc func removePanGestureAction() {
        if let panGestureRecognizer = self.panGestureRecognizer {
            self.removeGestureRecognizer(panGestureRecognizer)
            self.panGestureRecognizer = nil
        }
    }

    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: self)

        if panGesture.state == .began {
            originalPosition = self.center
            currentPositionTouched = panGesture.location(in: self)
        } else if panGesture.state == .changed {
            self.frame.origin = CGPoint(
                x: translation.x,
                y: self.frame.origin.y
            )
        } else if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: self)
            if velocity.y < 0 {
                self.openHyBridViewController()
            }
            else if abs(velocity.x) >= UIScreen.main.bounds.width/2 {
                UIView.animate(withDuration: 0.2
                    , animations: {
                        self.frame.origin = CGPoint(
                            x: (velocity.x > 0) ? self.frame.size.width : -self.frame.size.width,
                            y: self.frame.origin.y
                        )
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.delegate.stopPlayer()
                        self.stop()
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.center = self.originalPosition!
                })
            }
        }
    }

    //MARK: - Chromecast
    @objc func chromecastSessionWilStart() {
        removePanGestureAction()
    }

    @objc func chromecastSessionDidEnd() {
        addPanGestureAction()
    }


}
