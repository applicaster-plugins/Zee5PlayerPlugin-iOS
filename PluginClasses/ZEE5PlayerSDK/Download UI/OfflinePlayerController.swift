//
//  OfflinePlayerController.swift
//  Zee5DownloadSDK
//
//  Created by Abhishek on 06/12/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit
import PlayKit
import Alamofire
import Zee5CoreSDK

protocol OfflineVideoDurationDelegate: class {
    func updateVideoDuration(item: DownloadItem?, duration: Int)
}

@objc public class OfflinePlayerController: UIViewController {

    static let identifier = "OfflinePlayerController"
    
    
     weak var delegate: OfflineVideoDurationDelegate?
    
    @IBOutlet weak var replayBtnOutlet: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var viewSlider: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblTotalDuration: UILabel!
    @IBOutlet weak var viewPlayer: PlayerView!
    @IBOutlet weak var parentalView: ParentalView!
    
    @IBOutlet weak var rewindOutlet: RewindButton!
    @IBOutlet weak var forwardOutlet: ForwardButton!
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
    public var playerOffline: Player!
    private var isControlsVisible = false
    private var isSeekStarted = false
    private var videoPlayingDuration = 0
    private let reachability = NetworkReachabilityManager()
    private let bundle = Bundle(for: OfflinePlayerController.self)
    public var ParentalPin = ""
    public var playbackRate = "1X"
    public var Agerating = ""
    public var seekCounter = 0
    public var isparentalPin:Bool?
    public var singleton : SingletonClass?
    
    
    private var availableTracks: PKTracks? {
        didSet {
            self.checkMenuOptionState()
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        singleton = SingletonClass .sharedManager() as? SingletonClass
        UIFont .jbs_registerFont(withFilenameString: "ZEE5_Player", bundle: bundle)
        self.NotificationObserver()
        self.checkParentalSet()
        self.replayBtnOutlet.isHidden = true;
        
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        self.configurePlayer(with: self.selectedUrl)
    }
    
    override public var shouldAutorotate: Bool {
        return true
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    @IBAction func playerViewTapped(_ sender: UITapGestureRecognizer) {
        self.isControlsVisible.toggle()
        self.hideUnHindeTopView(isHidden: self.isControlsVisible)
    }
    
    @IBAction func actionBack(_ sender: Any) {
        playerOffline.stop()
        playerOffline.destroy()
        self.singleton?.isofflinePlayer = false
        ZEE5PlayerManager.sharedInstance().selectedplaybackRateOffline = "1X"
        ZEE5PlayerManager.sharedInstance().isOfflineContent = false
        self.dismissViewController(withAnimation: true)
        self.singleton?.offlinePlayerCurrentTime = 0
        self.singleton?.offlinePlayerDuration = 0
    }
    @IBAction func replayAction(_ sender: Any) {
        playerOffline.seek(to: 0)
        self.play()
        playerControlsHidden(isHidden: false)
       }
    
    @objc func hideUnHindeTopView(isHidden: Bool) {
        if replayBtnOutlet.isHidden == false {
            return;
        }
        self.btnPlay.isHidden = isHidden
        self.btnBack.isHidden = isHidden
        self.viewSlider.isHidden = isHidden
        self.lblContentTitle.isHidden = isHidden
        self.btnMenu.isHidden = isHidden
        self.checkMenuOptionState()
        if isHidden == false {
             DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                if self?.viewPlayer != nil{
                self?.hideUnHindeTopView(isHidden: true)
            }
        }
    }
}
    func checkMenuOptionState() {
//        if self.availableTracks?.audioTracks?.count ?? 0 > 1 || self.availableTracks?.textTracks?.count ?? 0 > 1 {
//            self.btnMenu.isHidden = false
//        }
//        else {
//            self.btnMenu.isHidden = true
//        }
        // self.btnMenu.isHidden = false
    }
    
    func NotificationObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.RemoveView(_:)), name: NSNotification.Name(rawValue: "ParentalPin"), object: nil)
        
    NotificationCenter.default.addObserver(self, selector: #selector(KeypadShow), name:UIResponder.keyboardDidShowNotification, object: nil)
        
     NotificationCenter.default.addObserver(self, selector: #selector(KeypadHide), name:UIResponder.keyboardDidHideNotification, object: nil)
        
    NotificationCenter.default.addObserver(self, selector: #selector(RemoveSubView), name:NSNotification.Name(rawValue: "RemoveSubView"), object: nil)
        
    NotificationCenter.default.addObserver(self, selector: #selector(wentBackground), name: UIApplication.willResignActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(wentForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func RemoveNotification() {
        NotificationCenter.default .removeObserver(self, name: NSNotification.Name(rawValue: "ParentalPin"), object: nil)
         NotificationCenter.default .removeObserver(self, name:UIResponder.keyboardDidShowNotification, object: nil)
         NotificationCenter.default .removeObserver(self, name:UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default .removeObserver(self, name: NSNotification.Name(rawValue: "RemoveSubView"), object: nil)
        NotificationCenter.default .removeObserver(self, name:UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default .removeObserver(self, name:UIApplication.willResignActiveNotification, object: nil)
       }
    
    @objc func RemoveSubView() {
        parentalView.removeFromSuperview()
        parentalView = nil
       }
    @objc func KeypadShow() {
        parentalView.top_parentalView?.constant = 100
        UIView .animate(withDuration: 0.3, animations: {
            self.parentalView .layoutIfNeeded()
        })
    }
    @objc func KeypadHide() {
        if parentalView != nil {
            parentalView.top_parentalView?.constant = 0
        UIView .animate(withDuration: 0.3, animations: {
                              self.parentalView .layoutIfNeeded()
                          })
        }
    }
    @objc private func wentBackground() {
          if self.view.window != nil {
            self.pause()
          }
      }
      
      @objc private func wentForeground() {
          if self.view.window != nil {
            self .play()
          }
      }
    @objc func RemoveView(_ notification:NSNotification) {
        let userPIn = notification.object as! String
        if parentalView != nil {
            if userPIn == ParentalPin {
                isparentalPin = false
                self.btnPlay.isSelected = true;
                self.play()
                parentalView.removeFromSuperview()
            }else if userPIn == "ForgotPIN"{
                NotificationCenter.default .removeObserver(self, name:UIResponder.keyboardDidShowNotification, object: nil)
                parentalView.removeFromSuperview()
            }
            else{
                Zee5ToastView .showToastAboveKeyboard(withMessage: "Please Enter Correct Pin!")
            }
        }
        
    }
    func checkParentalSet() {
            if let data = Zee5UserSettingsManager.shared.getUserSettingsModal(){
            for settingDataModel in data {
                if settingDataModel.key == "parental_control"{
                    if let dict = convertToDictionary(from: settingDataModel.value!) {
                        Agerating = dict["age_rating"] ?? ""
                        ParentalPin = dict["pin"] ?? ""
                        break
                    }
                  }
                }
                if ParentalPin != "" && Agerating != "" {
                    parentalLogic()
                }else{
                     isparentalPin = false
                }
            }
    }

    func parentalLogic() {
        if let Age = selectedVideo?.Agerating {
            if Agerating == "UA" {
                if Age == "U" {
                    isparentalPin = false
                }else{
                    isparentalPin = true
                }
            }else if Agerating == "U"{
                isparentalPin = true
            }
        }
    }
    
    func convertToDictionary(from text: String) -> [String: String]? {
        guard let data = text.data(using: .utf8) else { return nil }
        let anyResult = try? JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: String]
    }

      func parentalControlshow (){
        self.btnPlay.isSelected = false
        prepareParentalView()
        self.view .addSubview(parentalView)
    }

      func prepareParentalView(){
        if parentalView == nil {
            parentalView = bundle.loadNibNamed("ParentalView", owner: self, options: nil)?.first as! UIView as? ParentalView
        }else{
            parentalView .removeFromSuperview()
        }
        parentalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentalView.frame = UIScreen.main.bounds
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
                    if playingDuration == selectedVideo?.duration {
                       self.playerOffline.seek(to: TimeInterval(0))
                       self.sliderDuration.setValue(Float(0), animated: true)
                       return
                    }
                    self.playerOffline.seek(to: TimeInterval(playingDuration))
                    self.sliderDuration.setValue(Float(playingDuration), animated: true)
                }
            }
            catch {
                ZeeUtility.utility.console("error: getVideoDurationFromServer: \(error.localizedDescription)")
            }
        }
    }
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !replayBtnOutlet.isHidden {
            self.videoPlayingDuration = 0
        }
        
        self.updateVideoDurationToServer()
        self.playerOffline.stop()
        self.RemoveNotification()
        
        viewPlayer.removeFromSuperview()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
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
            self.play()
            
            self.addPlayerObserver()
            
            self.forwardAndRewindActions()
        }
    }
    
    func addPlayerObserver() {
        
        self.playerOffline.addObserver(self, event: PlayerEvent.canPlay) { [weak self] (event) in
            guard let self = self else { return }
            self.play()
            
            self.getOfflineVideoPlayedDuration()
            if self.isparentalPin  == true {
                self.pause()
                self.parentalControlshow()
            }else{
                self.btnPlay.isSelected = true
            }
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
            self.singleton?.offlinePlayerCurrentTime = self.getCurrentTime()
            self.singleton?.offlinePlayerDuration = self.getDuration()
            if (ZEE5PlayerManager.sharedInstance().selectedplaybackRateOffline != "1X" && ZEE5PlayerManager.sharedInstance().selectedplaybackRateOffline != "" && self.playbackRate == "1X") {
                self.playbackRate = ZEE5PlayerManager.sharedInstance().selectedplaybackRateOffline
                self.btnPlay.isSelected = true
            }
        }
        
        self.playerOffline.addObserver(self, event: PlayerEvent.tracksAvailable) { [weak self] (event) in
            guard let self = self else { return }
            self.availableTracks = event.tracks
            self.playerOffline.removeObserver(self, event: PlayerEvent.tracksAvailable)
        }
        self.playerOffline.addObserver(self, event: PlayerEvent.ended) { [weak self] (event) in
            guard let self = self else { return }
            self.playerControlsHidden(isHidden: true)
        }
        self.playerOffline.addObserver(self, event: PlayerEvent.playing) {[weak self] (event) in
            self?.singleton?.isofflinePlayer = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                if self?.viewPlayer != nil{
                self?.hideUnHindeTopView(isHidden: true)
            }
        }
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
        
        self.playerOffline.addObserver(self, event: PlayerEvent.error) { (event) in

        }
    }
    
    func playerControlsHidden(isHidden: Bool) {
        self.btnPlay.isHidden = isHidden
        self.replayBtnOutlet.isHidden = !isHidden
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
        weak var weakSelf = self
        
        self.forwardOutlet.singleTouch = { touch in
            weakSelf?.forwardOutlet.resetViews()
            weakSelf?.playerViewTapped(UITapGestureRecognizer())
        }
        
        self.forwardOutlet.valueChanged = { (totaltouch, counter) in
            if totaltouch > 1 {
                if self.isparentalPin == true {
                    self.parentalControlshow()
                    return
                }
                self.seekCounter = counter
                if counter == 0 {
                    self.seekCounter = 10
                }
                weakSelf?.forwardContent(with: TimeInterval(self.seekCounter))
            }
        }
        
        self.rewindOutlet.singleTouch = { touch in
            weakSelf?.rewindOutlet.resetViews()
            weakSelf?.playerViewTapped(UITapGestureRecognizer())
        }
        
        self.rewindOutlet.valueChanged = { (totaltouch, counter) in
            if totaltouch > 1 {
                if self.isparentalPin == true {
                    self.parentalControlshow()
                    return
                }
                self.seekCounter = counter
                if counter == 0 {
                    self.seekCounter = 10
                }
                weakSelf?.rewindContent(with: TimeInterval(self.seekCounter))
            }
        }
    }
    
    func forwardContent(with value: TimeInterval) {
        let currentTime = self.playerOffline.currentTime
        var seekValue = currentTime + value
        seekValue = seekValue > self.playerOffline.duration ? self.playerOffline.duration : seekValue
        self.seekCounter = 0
        self.playerOffline.seek(to: seekValue)
    }
    
    func rewindContent(with value: TimeInterval) {
        let currentTime = self.playerOffline.currentTime
        var seekValue = currentTime - value
        seekValue = seekValue < 0 ? 0 : seekValue
        self.seekCounter = 0
        self.playerOffline.seek(to: seekValue)
    }
    
    func bringControlsToTop() {
        self.viewPlayer.bringSubviewToFront(self.btnBack)
        self.viewPlayer.bringSubviewToFront(self.btnMenu)
        self.viewPlayer.bringSubviewToFront(self.viewSlider)
        self.viewPlayer.bringSubviewToFront(self.btnPlay)
        self.viewPlayer.bringSubviewToFront(self.replayBtnOutlet)
    }
}

// MARK:- Player Controls
extension OfflinePlayerController {

    @IBAction func actionSlider(_ sender: UISlider) {
        if isparentalPin == true{
            self.sliderDuration.setValue(Float(videoPlayingDuration), animated: true)
            self.parentalControlshow()
            return
        }
        self.isSeekStarted = true
        self.playerOffline.seek(to: TimeInterval(sender.value))
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.isSeekStarted = false
        }
    }
    
    @IBAction func actionPlayPause(_ sender: UIButton) {
        if btnPlay.isSelected == true {
            btnPlay.isSelected = false
            self.pause()
        }
        else {
            if isparentalPin == true {
                checkParentalSet()
                if isparentalPin == true {
                    self.parentalControlshow()
                    return
                }else{
                }
            }
            btnPlay.isSelected = true
            self .play()
        }
    }
    
    func play()  {
        self.playbackRate = "1X"
        ZEE5PlayerManager.sharedInstance().selectedplaybackRateOffline = "1X"
        self.playerOffline.play()
    }
    func pause() {
        self.playbackRate = "1X"
        ZEE5PlayerManager.sharedInstance().selectedplaybackRateOffline = "1X"
        self.playerOffline.pause()
    }
   public  func getDuration() -> TimeInterval {
        return self.playerOffline.duration
    }
   public  func getCurrentTime() -> TimeInterval {
    return self.playerOffline.currentTime
    }
    
    @IBAction func actionMoreClicked(_ sender: UIButton) {
        if isparentalPin == true{
            self.parentalControlshow()
            return
        }
        if let audioTracks = self.availableTracks?.audioTracks,
            let textTracks = self.availableTracks?.textTracks {
            ZEE5PlayerManager.sharedInstance().moreOption(forOfflineContentAudio: audioTracks, text: textTracks, with: self.playerOffline)
        }else{
            ZEE5PlayerManager.sharedInstance().moreOption(forOfflineContentAudio:[Track](), text: [Track](), with: self.playerOffline)
        }
    
    }
}
