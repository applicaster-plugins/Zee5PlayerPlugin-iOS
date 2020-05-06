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
}

public class ActionBarView: UIView {
    public struct Button {
        public let image: UIImage
        public let selectedImage: UIImage?
        public let title: String
        public let font: UIFont
        public let textColor: UIColor
        public let custom: UIButton?
        public let action: (() -> Void)
    }
    
    fileprivate var stackView: UIStackView!
    
    public func addButton(_ button: Button) -> ActionBarUpdateHandler {
        return self.insertStackViewButton(button)
    }
    
    override public func awakeFromNib() {
        self.stackView = UIStackView()
        self.addSubview(self.stackView)
        
        self.backgroundColor = .clear
        
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.matchParent()

        self.stackView.axis = .horizontal
        self.stackView.alignment = .center
        self.stackView.distribution = .fillEqually
        self.stackView.spacing = 4
        self.stackView.backgroundColor = .clear
    }
    
    fileprivate func addSpacerView() {
        let spaceView = UIView()
        
        spaceView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spaceView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        spaceView.backgroundColor = .yellow
        
        self.stackView.addArrangedSubview(spaceView)
    }
    
    fileprivate func insertStackViewButton(_ button: Button) -> ActionBarUpdateHandler {
        let container: UIButton
        let innerViewsContainer: UIView
        
//        if let customButton = button.custom {
//            customButton.translatesAutoresizingMaskIntoConstraints = false
//
//            container = customButton
//            innerViewsContainer = UIView()
//            container.addSubview(innerViewsContainer)
//
//            innerViewsContainer.matchParent()
//        }
//        else {
            container = UIButton(type: .custom)
            innerViewsContainer = container
            
            container.setTapHandler {
                button.action()
            }
//        }
        
        self.stackView.addArrangedSubview(container)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        container.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        container.widthAnchor.constraint(equalToConstant: 60).isActive = true
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        container.backgroundColor = .clear
        
        let (imageView, label) = self.addInnerViews(container: innerViewsContainer, button: button)
                
        func setSelectedHandler(selected: Bool) {
            if selected, let selectedImage = button.selectedImage {
                imageView.image = selectedImage
            }
            else {
                imageView.image = button.image
            }
        }
        
        func setDisabledHandler(disabled: Bool) {
            container.isEnabled = !disabled
        }
        
        return ActionBarUpdateHandler(
            setSelected: setSelectedHandler,
            setDisabled: setDisabledHandler
        )
    }
    
    func addInnerViews(container: UIView, button: Button) -> (UIImageView, UILabel) {
        let imageView = UIImageView()
        container.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        imageView.image = button.image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        
        let label = UILabel()
        container.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        
        label.text = button.title
        label.textAlignment = .center
        label.font = button.font
        label.textColor = button.textColor
        label.backgroundColor = .clear
        
        return (imageView, label)
    }
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
