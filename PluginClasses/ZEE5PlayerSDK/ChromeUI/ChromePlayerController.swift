//
//  ChromePlayerController.swift
//  Zee5DownloadSDK
//
//  Created by Abhishek Gour on 07/11/19.
//  Copyright © 2019 Logituit. All rights reserved.
//

import UIKit
import GoogleCast
import CoreMedia

class ChromePlayerController: UIViewController, GCKSessionManagerListener,GCKRemoteMediaClientListener, GCKUIMediaControllerDelegate {
    
    static let identifier = "ChromePlayerController"
    
    @IBOutlet weak var lblShowTitle: UILabel!
    @IBOutlet weak var lblEpisode: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var forwardbutton: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    
    var mediaClient:  GCKRemoteMediaClient!
    var sessionManager: GCKSessionManager!
    var timer: Timer?
    
    @IBOutlet weak var sliderPlayer: UISlider! {
        didSet {
            let image = UIImage(named: "sliderThumb")
            self.sliderPlayer.setThumbImage(image, for: .normal)
            self.sliderPlayer.setThumbImage(image, for: .highlighted)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sessionManager = GCKCastContext.sharedInstance().sessionManager
        self.mediaClient = self.sessionManager.currentSession?.remoteMediaClient
        self.sessionManager.add(self)
        
        if self.sessionManager.hasConnectedCastSession() {
            self.attach(to: sessionManager.currentCastSession!)
        }
        
        if self.sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.queueHasCurrentItem ?? false {
            let mediaInfo = self.sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.currentQueueItem?.mediaInformation
            guard let duration = mediaInfo?.metadata?.integer(forKey: "contentLength") else {return}
            self.sliderPlayer.maximumValue = Float(duration)
            self.lblEndTime.text = self.getTotalDuration(duration)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.stringFromTimeInterval), userInfo: nil, repeats: true)
        if self.sessionManager?.hasConnectedCastSession() ?? false{
            self.sessionManager.remove(self)
            self.mediaClient.remove(self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.timer?.invalidate()
    }
    
    @IBAction func actionMore(_ sender: UISwitch) {
        
    }
    
    @IBAction func actionPlay(_ sender: Any) {
        self.btnPlay.isSelected.toggle()
        
        if self.sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.currentQueueItem != nil {
            if self.sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.playerState.rawValue == 2 {
                self.sessionManager.currentCastSession?.remoteMediaClient?.pause()
                self.btnPlay.setImage(UIImage(named: "playIcon"), for: .normal)
            }
            else if self.sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.playerState.rawValue == 3 {
                self.sessionManager.currentCastSession?.remoteMediaClient?.play()
                self.btnPlay.setImage(UIImage(named: "pauseIcon"), for: .normal)
            }
        }
    }
    
    @IBAction func actionNext(_ sender: Any) {
        self.sessionManager.currentCastSession?.remoteMediaClient?.queueNextItem()
    }
    
    @IBAction func actionPrevious(_ sender: Any) {
        self.sessionManager.currentCastSession?.remoteMediaClient?.queuePreviousItem()
    }
    
    @IBAction func actionForward(_ sender: Any) {
        guard let currentDuration = self.sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.streamPosition else { return }
        let newTime = currentDuration + 10.0
        self.sessionManager.currentCastSession?.remoteMediaClient?.seek(toTimeInterval: TimeInterval(newTime))
    }
    
    @IBAction func actionBackward(_ sender: Any) {
        guard let currentDuration = self.sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.streamPosition else { return }
        let newTime = currentDuration - 10.0
        self.sessionManager.currentCastSession?.remoteMediaClient?.seek(toTimeInterval: TimeInterval(newTime))
    }
    
    @IBAction func actionSlider(_ sender: UISwitch) {
        let value = self.sliderPlayer.value
        self.sessionManager.currentCastSession?.remoteMediaClient?.seek(toTimeInterval: TimeInterval(value))
    }
    
    func attach(to castSession: GCKCastSession) {
        self.mediaClient = castSession.remoteMediaClient
        self.mediaClient.add(self)
    }
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        self.mediaClient = sessionManager.currentCastSession?.remoteMediaClient
    }
    
    @objc func stringFromTimeInterval(){
        guard let currentDuration = sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.streamPosition else { return }
        let time = NSInteger(currentDuration)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        DispatchQueue.main.async {
            self.lblStartTime.text = NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds) as String
            self.sliderPlayer.value = Float(time)

        if let time = Int(self.getTotalDuration(Int(currentDuration))) {
            let seconds = time % 60
            let minutes = (time / 60) % 60
            let hours = (time / 3600)
            
            DispatchQueue.main.async {
                self.lblStartTime.text = NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds) as String
                self.sliderPlayer.value = Float(time)
            }

        }
        }
    }
    
    func getTotalDuration(_ duration: Int) -> String {
        let seconds = duration % 60
        let minutes = (duration / 60) % 60
        let hours = duration / 3600
        return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds) as String
    }
}
