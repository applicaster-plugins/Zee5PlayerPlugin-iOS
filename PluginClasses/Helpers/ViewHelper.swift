//
//  ViewHelper.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 10.05.20.
//

import Foundation

@objc extension UIView {
    public func fillParent() {
        guard let parent = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
    }
    
    public func anchorCenteredToTop(size: CGSize, inset: CGFloat) {
        guard let parent = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraint(equalTo: parent.topAnchor, constant: inset).isActive = true
        self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        self.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
    }

    public func fillCenteredInParent(width: CGFloat) {
        guard let parent = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        self.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
    }
    
    public func fillCenteredInParent(height: CGFloat) {
        guard let parent = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        if height > 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        self.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
    }
    
    public func anchorToTop() {
        guard let parent = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(lessThanOrEqualTo: parent.bottomAnchor).isActive = true
    }
    
    public func anchorToRight(width: CGFloat) {
        guard let parent = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
    }
    
    public func anchorLeftOf(view: UIView) {
        guard let parent = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(lessThanOrEqualTo: view.leadingAnchor).isActive = true
    }
    
    public func anchorToTopLeft(inset: CGFloat, size: CGSize) {
        guard let parent = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        self.topAnchor.constraint(equalTo: parent.topAnchor, constant: inset).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: inset).isActive = true
    }
    
    public func anchorBelowOf(view: UIView) {
        guard let parent = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(lessThanOrEqualTo: parent.bottomAnchor).isActive = true
    }
    
    public func centerInParent(size: CGSize) {
        guard let parent = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        self.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
    }
    
    public func fillParentLeftOf(view: UIView) {
        guard let parent = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
}

public typealias UIButtonHandler = () -> Void

@objc extension UIButton {
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
    
    public func setTapHandler(handler: @escaping UIButtonHandler) {
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
