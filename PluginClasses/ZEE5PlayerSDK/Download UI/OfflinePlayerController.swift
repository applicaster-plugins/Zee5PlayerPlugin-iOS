//
//  OfflinePlayerController.swift
//  Zee5DownloadSDK
//
//  Created by Abhishek on 06/12/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit
import PlayKit

protocol OfflineVideoDurationDelegate: class {
    func updateVideoDuration(item: DownloadItem?, duration: Int)
}

class OfflinePlayerController: UIViewController {

    static let identifier = "OfflinePlayerController"
    
    public weak var delegate: OfflineVideoDurationDelegate?
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var viewSlider: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblTotalDuration: UILabel!
    @IBOutlet weak var viewPlayer: PlayerView!
    
    @IBOutlet weak var lblContentTitle: UILabel! {
        didSet {
            self.lblContentTitle.text = self.selectedVideo?.title
        }
    }
    
    @IBOutlet weak var sliderDuration: Zee5Slider! {
        didSet {
            self.sliderDuration.showTooltip = true
            let bundle = Bundle(for: DownloadRootController.self)
            if #available(iOS 13.0, *) {
                let image = UIImage(named: "Thumb", in: bundle, compatibleWith: nil)
                self.sliderDuration.setThumbImage(image, for: .normal)
                self.sliderDuration.setThumbImage(image, for: .highlighted)
            } else {
                // Fallback on earlier versions
                let image = UIImage(named: "Thumb", in: bundle, compatibleWith: nil)
                self.sliderDuration.setThumbImage(image, for: .normal)
                self.sliderDuration.setThumbImage(image, for: .highlighted)
            }
        }
    }
    
    public var selectedUrl: URL?
    public var selectedVideo: DownloadItem?
    private var playerOffline: Player!
    private var isControlsVisible = false
    private var isSeekStarted = false
    private var forwardButton: TouchableButton!
    private var rewindButton: TouchableButton!
    private var videoPlayingDuration = 0
    
    private var availableTracks: PKTracks? {
        didSet {
            self.checkMenuOptionState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        //
        self.configurePlayer(with: self.selectedUrl)
    }
    
    @IBAction func playerViewTapped(_ sender: UITapGestureRecognizer) {
        self.isControlsVisible.toggle()
        self.hideUnHindeTopView(isHidden: self.isControlsVisible)
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.dismissViewController(withAnimation: true);
    }
    
    func hideUnHindeTopView(isHidden: Bool) {
        self.btnPlay.isHidden = isHidden
        self.btnBack.isHidden = isHidden
        self.viewSlider.isHidden = isHidden
        self.lblContentTitle.isHidden = isHidden
        self.checkMenuOptionState()
    }
    
    func checkMenuOptionState() {
        if self.availableTracks?.audioTracks?.count ?? 0 > 1 || self.availableTracks?.textTracks?.count ?? 0 > 1 {
            self.btnMenu.isHidden = false
        }
        else {
            self.btnMenu.isHidden = true
        }
    }
    
    func updateVideoDurationToServer() {
        if let id = self.selectedVideo?.contentId {
            do {
                try Zee5DownloadManager.shared.updateOfflinePlayingDuration(contentId: id, seconds: self.videoPlayingDuration)
                
                self.delegate?.updateVideoDuration(item: self.selectedVideo, duration: self.videoPlayingDuration)
            }
            catch {
                ZeeUtility.utility.console("error: updateVideoDurationToServer: \(error.localizedDescription)")
            }
        }
    }
    
    func getOfflineVideoPlayedDuration() {
        if let id = self.selectedVideo?.contentId {
            do {
                if let playingDuration = try Zee5DownloadManager.shared.getVideoPlayedDuration(contentId: id) {
                    self.playerOffline.seek(to: TimeInterval(playingDuration))
                    self.sliderDuration.setValue(Float(playingDuration), animated: true)
                }
            }
            catch {
                ZeeUtility.utility.console("error: getVideoDurationFromServer: \(error.localizedDescription)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.updateVideoDurationToServer()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if self.isMovingFromParent == true {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    @objc func canRotate() -> Void {}
    
    deinit {
        self.playerOffline.destroy()
    }
}

extension OfflinePlayerController {
    
    func configurePlayer(with contentUrl: URL?) {
        if let url = contentUrl {
            self.viewPlayer.frame = UIScreen.main.bounds
            self.playerOffline = PlayKitManager.shared.loadPlayer(pluginConfig: nil)
            self.playerOffline?.view = self.viewPlayer
            let mediaEntry = LocalAssetsManager.managerWithDefaultDataStore().createLocalMediaEntry(for: "OfflinePlayerId", localURL: url)
            self.playerOffline.prepare(MediaConfig(mediaEntry: mediaEntry))
            self.playerOffline.play()
            
            self.addPlayerObserver()
            
            self.forwardButton = TouchableButton(title: "Forward", imageName: "3", seekBtn: "Forward")
            self.rewindButton = TouchableButton(title: "Rewind", imageName: "N", seekBtn: "Rewind")
            
            self.forwardAndRewindActions()
        }
    }
    
    func addPlayerObserver() {
        
        self.playerOffline.addObserver(self, event: PlayerEvent.canPlay) { [weak self] (event) in
            guard let self = self else { return }
            self.playerOffline.play()
            
            self.getOfflineVideoPlayedDuration()
        }
        
        self.playerOffline.addObserver(self, event: PlayerEvent.playheadUpdate) { [weak self] (event) in
            guard let self = self else { return }
            let floored =  floor(event.currentTime?.doubleValue ?? 0)
            let seconds = Float(floored)
            
            let totalTime = Int(self.playerOffline.duration)
            
            if self.sliderDuration.isTracking == false && self.isSeekStarted == false {
                self.sliderDuration.value = seconds
            }
            self.sliderDuration.maximumValue = Float(self.playerOffline.duration)
            self.lblCurrentTime.text = self.getDuration(currentDuraton: Int(seconds), total: totalTime)
            self.lblTotalDuration.text = self.getDuration(currentDuraton: totalTime, total: totalTime)
            
            self.videoPlayingDuration = Int(seconds)
        }
        
        self.playerOffline.addObserver(self, event: PlayerEvent.tracksAvailable) { [weak self] (event) in
            guard let self = self else { return }
            self.availableTracks = event.tracks
            self.playerOffline.removeObserver(self, event: PlayerEvent.tracksAvailable)
        }
        
        self.playerOffline.addObserver(self, event: PlayerEvent.textTrackChanged) { (event) in
            if let title = event.selectedTrack?.title {
                ZEE5PlayerManager.sharedInstance().selectedSubtitle = title
            }
        }
        
        self.playerOffline.addObserver(self, event: PlayerEvent.audioTrackChanged) { (event) in
            if let title = event.selectedTrack?.title {
                ZEE5PlayerManager.sharedInstance().selectedLangauge = title
            }
        }
    }
    
    func getDuration(currentDuraton: Int, total totalDuraton: Int) -> String? {
        let seconds = currentDuraton % 60
        let minutes = (currentDuraton / 60) % 60
        let hours = currentDuraton / 3600
        
        if hours == 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        }
        else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}

extension OfflinePlayerController {
    
    func forwardAndRewindActions() {
        let value: TimeInterval = 10
        weak var weakSelf = self
        let frame = UIScreen .main.bounds
        
        self.forwardButton.frame = .init(x: frame.size.height - 200, y: 0, width: 200, height: frame.size.width)
        self.viewPlayer.addSubview(self.forwardButton)
        
        self.forwardButton.singleTouch = { touch in
            weakSelf?.forwardButton.resetViews()
            weakSelf?.playerViewTapped(UITapGestureRecognizer())
        }
    
        self.forwardButton.pressed = { pressed in
            weakSelf?.forwardContent(with: value)
        }
        
        //
        self.rewindButton.frame = .init(x: 0, y: 0, width: 200, height: self.viewPlayer.frame.height)
        self.viewPlayer.addSubview(self.rewindButton)
        
        self.rewindButton.singleTouch = { touch in
            weakSelf?.rewindButton.resetViews()
            weakSelf?.playerViewTapped(UITapGestureRecognizer())
        }
        
        self.rewindButton.pressed = { pressed in
            weakSelf?.rewindContent(with: value)
        }
        
        ///
        self.bringControlsToTop()
    }
    
    func forwardContent(with value: TimeInterval) {
        let currentTime = self.playerOffline.currentTime
        var seekValue = currentTime + value
        seekValue = seekValue > self.playerOffline.duration ? self.playerOffline.duration : seekValue
        self.playerOffline.seek(to: seekValue)
    }
    
    func rewindContent(with value: TimeInterval) {
        let currentTime = self.playerOffline.currentTime
        var seekValue = currentTime - value
        seekValue = seekValue < 0 ? 0 : seekValue
        self.playerOffline.seek(to: seekValue)
    }
    
    func bringControlsToTop() {
        self.viewPlayer.bringSubviewToFront(self.btnBack)
        self.viewPlayer.bringSubviewToFront(self.btnMenu)
        self.viewPlayer.bringSubviewToFront(self.viewSlider)
        self.viewPlayer.bringSubviewToFront(self.btnPlay)
    }
}

// MARK:- Player Controls
extension OfflinePlayerController {

    @IBAction func actionSlider(_ sender: UISlider) {
        self.isSeekStarted = true
        self.playerOffline.seek(to: TimeInterval(sender.value))
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.isSeekStarted = false
        }
    }
    
    @IBAction func actionPlayPause(_ sender: UIButton) {
        if sender.isSelected == true {
            self.playerOffline.play()
        }
        else {
            self.playerOffline.pause()
        }
        sender.isSelected.toggle()
    }
    
    @IBAction func actionMoreClicked(_ sender: UIButton) {
        if let audioTracks = self.availableTracks?.audioTracks,
            let textTracks = self.availableTracks?.textTracks {
            
            ZEE5PlayerManager.sharedInstance().moreOption(forOfflineContentAudio: audioTracks, text: textTracks, with: self.playerOffline)
        }
    }
}
