//
//  TouchableButton.swift
//  Z5
//
//  Created by Abhi on 06/02/19.
//  Copyright © 2019 Abhi. All rights reserved.
//

import UIKit

enum SEEKBTN{
    case forward
    case reverse
}
public class TouchableButton: UIButton {
    
    var waitDuration: Double = 0.7   // change this for custom duration to reset after the sequential tap
    @objc public var valueChanged: ((_ value:Int, _ counter:Int) -> Void)?  // set this to handle press of button
    var minimumTouches: Int = 1      // set this to change number of minimum presses
    private var initialTimer: Timer?
    var counter = 0
    @objc public var pressed: ((_ value:Bool) -> Void)?
    
    @objc public var singleTouch: ((_ value:Bool) -> Void)?

    var seekBtn: SEEKBTN = .forward {
        didSet {
            let aFlag = seekBtn == .forward
            semanticContentAttribute = aFlag ? .forceRightToLeft : .forceLeftToRight
            contentHorizontalAlignment = aFlag ? .right : .left
        }
    }
    lazy var btnImage : UILabel = {
        let label = UILabel()
        label.font = UIFont(name:"ZEE5_Player", size : 20)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    lazy var btnLabel : UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name:"NotoSans", size : 16)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()
    
    lazy var stackView : UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2.0
        self.addSubview(stack)
        stack.isHidden = true
        stack.centerInParent(size: CGSize(width: 100, height: 50))
        stack.isUserInteractionEnabled = false
        return stack
    }()
    
    private var finalTouches:Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTarget()
    }
    
    @objc public convenience init(title: String?, imageName: String?,seekBtn: String) {
        self.init()
        btnImage.text = imageName
        btnLabel.text = ""
        if(seekBtn == "Forward")
        {
            setSeekBtn(seekBtn: .forward)
        }
        else
        {
            setSeekBtn(seekBtn: .reverse)

        }
        stackView.addArrangedSubview(btnImage)
        stackView.addArrangedSubview(btnLabel)
    }
    
    func setSeekBtn(seekBtn: SEEKBTN) {
        self.seekBtn = seekBtn
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTarget()
    }
    
    override public func layoutSubviews() {
        let maskLayer = CAShapeLayer()
        // to create rounded gradient
        if seekBtn == .forward{
            maskLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: self.frame.width/1.6, height: self.frame.height/1.6)).cgPath

        }else{
            maskLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: self.frame.width/1.6, height: self.frame.height/1.6)).cgPath

        }
        layer.mask = maskLayer
    }
    
    private func setTarget() {
            addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)
    }
    
    @objc private func buttonTouched() {
        let position = Int(Zee5PlayerPlugin.sharedInstance().getCurrentTime())
        let duration = Int(Zee5PlayerPlugin.sharedInstance().getDuration())
        if touches != 1{
            if seekBtn == .forward && touches <= (duration - position)/10 {
                counter += 10
            }else if seekBtn == .reverse && touches <= (position)/10{
                counter += 10
            }
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
            if touches >= minimumTouches {
                
                if touches != 1 {
        
                    self.backgroundColor = UIColor(white: 0.1, alpha: 0.6)
                    stackView.isHidden = false
                    if counter <= 10 {
                        btnLabel.text = "10 Seconds"
                    }else{
                        btnLabel.text = "\(counter - 10) Seconds"
                    }
                    pressed?(true)
                    // setting the gradient of the button on two or more taps

                }
                else
                {
                    singleTouch?(true)
                }
                timer?.invalidate()
                timer = Timer.scheduledTimer(timeInterval: waitDuration, target: self, selector: #selector(self.resetTap), userInfo: nil, repeats: false)

            }
        }
    }
    
}


public extension UIFont {
    
    @objc static func jbs_registerFont(withFilenameString filenameString: String, bundle: Bundle) {
        
        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil) else {
            return
        }
        
        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            return
        }
        
        guard let dataProvider = CGDataProvider(data: fontData) else {
            return
        }
        
        guard let font = CGFont(dataProvider) else {
            return
        }
        
        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
        }
    }
    
}
