//
//  ActionBarViewController.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 26.04.20.
//  Copyright © 2020 Miri. All rights reserved.
//

import Foundation

import ZappPlugins

public struct ActionBarUpdateHandler {
    public let setSelected: ((_ selected: Bool) -> Void)
    public let setDisabled: ((_ disabled: Bool) -> Void)
    public let setInProgress: ((_ view: UIView?) -> Void)
}

public class ActionBarView: UIView {
    public struct ButtonData {
        public let image: UIImage
        public let selectedImage: UIImage?
        public let title: String
        public let font: UIFont
        public let textColor: UIColor
        public let isFiller: Bool
        public let custom: UIButton?
        public let action: (() -> Void)
    }
    
    fileprivate var fixedSpaceView: UIView!
    fileprivate var stackView: UIStackView!
    
    public func addButton(_ buttonData: ButtonData) -> ActionBarUpdateHandler {
        return self.insertStackViewButton(buttonData)
    }
    
    public func resetButtons() {
        self.stackView.removeAllSubviews()
        self.fixedSpaceView.removeAllSubviews()
    }
    
    override public func awakeFromNib() {
        self.backgroundColor = UIColor.white.withAlphaComponent(0.04)

        self.fixedSpaceView = UIView()
        self.addSubview(self.fixedSpaceView)

        self.fixedSpaceView.anchorToRight(width: 100)
        self.fixedSpaceView.backgroundColor = .clear

        self.stackView = UIStackView()
        self.addSubview(self.stackView)
        
        self.stackView.anchorLeftOf(view: self.fixedSpaceView)
        
        self.stackView.axis = .horizontal
        self.stackView.alignment = .fill
        self.stackView.distribution = .fillEqually
        self.stackView.spacing = 0
        self.stackView.backgroundColor = .clear
    }
    
    fileprivate func insertStackViewButton(_ buttonData: ButtonData) -> ActionBarUpdateHandler {
        let container = ButtonViewContainer()
        
        if let customButton = buttonData.custom {
            customButton.removeAllSubviews()
            customButton.removeConstraints(customButton.constraints)
            
            customButton.backgroundColor = .clear
            
            container.button = customButton
            container.button.isHidden = true
        }
        else {
            container.button = UIButton(type: .custom)
            
            container.button.setTapHandler {
                if container.progressView == nil {
                    buttonData.action()
                }
            }
        }
        
        container.button.translatesAutoresizingMaskIntoConstraints = false
        
        container.innerViewsContainer = UIView()
        container.button.addSubview(container.innerViewsContainer)

        container.innerViewsContainer.translatesAutoresizingMaskIntoConstraints = false

        container.innerViewsContainer.backgroundColor = .clear
        container.innerViewsContainer.isUserInteractionEnabled = false
        
        if buttonData.isFiller {
            self.fixedSpaceView.addSubview(container.button)
            
            container.button.fillParent()
            container.innerViewsContainer.fillParent()

            container.button.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        }
        else {
            self.stackView.addArrangedSubview(container.button)
            
            let widthConstraint = container.button.widthAnchor.constraint(equalToConstant: 75)
            widthConstraint.priority = UILayoutPriority(rawValue: 999)
            widthConstraint.isActive = true
            
            container.innerViewsContainer.fillCenteredInParent(width: 55)
                        
            container.button.backgroundColor = .clear
        }
        
        let (imageView, label) = self.addInnerViews(container: container.innerViewsContainer, buttonData: buttonData)
                
        func setSelectedHandler(selected: Bool) {
            if selected, let selectedImage = buttonData.selectedImage {
                imageView.image = selectedImage
            }
            else {
                imageView.image = buttonData.image
            }
        }
        
        func setDisabledHandler(disabled: Bool) {
            container.button.isEnabled = !disabled
        }
        
        func setInProgressHandler(progressView: UIView?) {
            if let oldProgressView = container.progressView {
                oldProgressView.removeFromSuperview()
                container.progressView = nil
            }
            
            if let progressView = progressView {
                container.innerViewsContainer.isHidden = true
                container.button.addSubview(progressView)
                
                progressView.fillParent()
                
                container.progressView = progressView
            }
            else {
                container.innerViewsContainer.isHidden = false
            }
        }
        
        return ActionBarUpdateHandler(
            setSelected: setSelectedHandler,
            setDisabled: setDisabledHandler,
            setInProgress: setInProgressHandler
        )
    }
    
    func addInnerViews(container: UIView, buttonData: ButtonData) -> (UIImageView, UILabel) {
        let imageView = UIImageView()
        container.addSubview(imageView)
        
        imageView.anchorCenteredToTop(size: CGSize(width: 20, height: 16), inset: 13)
        
        imageView.image = buttonData.image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        
        let label = UILabel()
        container.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2).isActive = true
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        
        label.text = buttonData.title
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = buttonData.textColor
        label.numberOfLines = 2
        label.backgroundColor = .clear
        
        return (imageView, label)
    }
}

class ButtonViewContainer {
    var button: UIButton!
    var innerViewsContainer: UIView!
    var progressView: UIView?
}

typealias UIButtonHandler = () -> Void

extension UIButton {
    private struct AssociatedKeys {
        static var handler = "handler"
    }
    
    private var handler: UIButtonHandler? {
        get {
            guard let handler = objc_getAssociatedObject(self, &AssociatedKeys.handler) as? UIButtonHandler else {
                return nil
            }
            
            return handler
        }
        set(newValue) {
            guard let newValue = newValue else {
                return
            }
            
            objc_setAssociatedObject(self, &AssociatedKeys.handler, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setTapHandler(handler: @escaping UIButtonHandler) {
        self.handler = handler
        self.addTarget(self, action: #selector(UIButton.handleTap), for: .touchUpInside)
    }
    
    @objc func handleTap() {
        guard let handler = handler else {
            return
        }
        
        handler()
    }
}
