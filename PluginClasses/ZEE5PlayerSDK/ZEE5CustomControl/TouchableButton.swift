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

    fileprivate lazy var btnImage : UILabel = {
        let label = UILabel()
        
        label.font = UIFont(name:"ZEE5_Player", size : 20)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    fileprivate lazy var btnLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = UIFont(name:"NotoSans", size : 16)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        
        return label
    }()
    
    fileprivate lazy var stackView : UIStackView = {
        let stack = UIStackView()
        
        stack.axis = .vertical
        stack.spacing = 2.0
        
        self.addSubview(stack)
        
        stack.isHidden = true
        
        stack.centerInParent(size: CGSize(width: 100, height: 50))
        
        stack.isUserInteractionEnabled = false
        
        return stack
    }()
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        setTarget()
        
        self.stackView.addArrangedSubview(self.btnImage)
        self.stackView.addArrangedSubview(self.btnLabel)
    }
    
    private func setTarget() {
        addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)
    }
    
    @objc private func buttonTouched() {
        let position = Int(Zee5PlayerPlugin.sharedInstance().getCurrentTime())
        let duration = Int(Zee5PlayerPlugin.sharedInstance().getDuration())
        
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
        self.btnLabel.text = ""
        
        self.backgroundColor = UIColor.clear
        
        self.stackView.isHidden = true
        
        counter = 0
    }
    
    @objc public func resetViews() {
        self.backgroundColor = UIColor.clear
        self.stackView.isHidden = true
        counter = 0
    }
    
    var touches: Int = 0 {
        didSet {
            guard touches >= minimumTouches else {
                return
            }
                
            if touches != 1 {
                self.backgroundColor = UIColor(white: 0.1, alpha: 0.6)
                stackView.isHidden = false
                
                if counter <= 10 {
                    btnLabel.text = "10 Seconds"
                }
                else{
                    btnLabel.text = "\(counter - 10) Seconds"
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
        
        self.btnImage.text = "3"
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
        
        self.btnImage.text = "N"
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
