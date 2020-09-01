//
//  TouchableButton.swift
//  Z5
//
//  Created by Abhi on 06/02/19.
//  Copyright © 2019 Abhi. All rights reserved.
//

import UIKit


public class TouchableButton: UIButton {
    fileprivate static let skipDuration = 10
    
    fileprivate var waitDuration: Double = 0.7 // change this for custom duration to reset after the sequential tap
    fileprivate var minimumTouches: Int = 1 // set this to change number of minimum presses
    fileprivate var initialTimer: Timer?
    fileprivate var counter = 0
    fileprivate var finalTouches:Int = 0

    @objc public var valueChanged: ((_ value:Int, _ counter:Int) -> Void)? // set this to handle press of button
    @objc public var pressed: ((_ value:Bool) -> Void)?
    @objc public var singleTouch: ((_ value:Bool) -> Void)?
    public var  singelton : SingletonClass?
    

    fileprivate lazy var arrowLabel : UILabel = {
        let label = UILabel()
        
        label.font = UIFont(name:"ZEE5_Player", size : 20)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    fileprivate lazy var timeLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = UIFont(name:"NotoSans", size : 14)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        
        return label
    }()
    
    fileprivate lazy var containerView : UIView = {
        let containerView = UIView()
        self.addSubview(containerView)
        
        containerView.fillCenteredInParent(height: 0)

        containerView.isHidden = true
        containerView.isUserInteractionEnabled = false
        
        return containerView
    }()
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        setTarget()
        singelton = SingletonClass .sharedManager() as? SingletonClass
        
        self.containerView.addSubview(self.arrowLabel)
        self.arrowLabel.anchorToTop()
        
        self.containerView.addSubview(self.timeLabel)
        self.timeLabel.anchorBelowOf(view: self.arrowLabel)
    }
    
    private func setTarget() {
        addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)
    }
    
    @objc private func buttonTouched() {
  
        let position = singelton!.isofflinePlayer ? Int(singelton!.offlinePlayerCurrentTime) : Int(Zee5PlayerPlugin.sharedInstance().getCurrentTime())
        let duration = singelton!.isofflinePlayer ? Int(singelton!.offlinePlayerDuration) :Int(Zee5PlayerPlugin.sharedInstance().getDuration())
        
        if touches != 1, self.checkTouch(duration: duration, position: position) {
            counter += TouchableButton.skipDuration
        }
        
        touches += 1
        finalTouches = touches
        initialTimer?.invalidate()
        initialTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.emptyTouchCount), userInfo: nil, repeats: false)
    }
    
    @objc func emptyTouchCount(){
        self.touches = 0
    }
    
    private var timer: Timer?
    
    @objc public func resetTap() {
    // Making number of touches zero after the sequential tap and button gradient clear
    // Based on final touch, return the call back to player
        valueChanged?(finalTouches,counter)
        self.touches = 0
        self.finalTouches = 0
        self.timeLabel.text = ""
        
        self.backgroundColor = UIColor.clear
        
        self.containerView.isHidden = true
        
        counter = 0
    }
    
    @objc public func resetViews() {
        self.backgroundColor = UIColor.clear
        self.containerView.isHidden = true
        counter = 0
    }
    
    var touches: Int = 0 {
        didSet {
            guard touches >= minimumTouches else {
                return
            }
                
            if touches != 1 {
                self.backgroundColor = UIColor(white: 0.1, alpha: 0.6)
                self.containerView.isHidden = false
                
                if counter <= 10 {
                    self.timeLabel.text = "10 Seconds"
                }
                else{
                    self.timeLabel.text = "\(counter - 10) Seconds"
                }
                
                pressed?(true)
            }
            else {
                singleTouch?(true)
            }
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: waitDuration, target: self, selector: #selector(self.resetTap), userInfo: nil, repeats: false)
        }
    }
    
    func checkTouch(duration: Int, position: Int) -> Bool {
        return false
    }
}

public class ForwardButton: TouchableButton {
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        semanticContentAttribute = .forceRightToLeft
        contentHorizontalAlignment = .right
        
        self.arrowLabel.text = "3" // the font converts this value to an image
    }
    
    override func checkTouch(duration: Int, position: Int) -> Bool {
        return touches <= (duration - position) / TouchableButton.skipDuration
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: self.frame.width/1.6, height: self.frame.height/1.6)).cgPath

        self.layer.mask = mask
    }
}

public class RewindButton: TouchableButton {
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        semanticContentAttribute = .forceLeftToRight
        contentHorizontalAlignment = .left
        
        self.arrowLabel.text = "N"  // the font converts this value to an image
    }
    
    override func checkTouch(duration: Int, position: Int) -> Bool {
        return touches <= position / TouchableButton.skipDuration
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: self.frame.width/1.6, height: self.frame.height/1.6)).cgPath

        self.layer.mask = mask
    }
}
