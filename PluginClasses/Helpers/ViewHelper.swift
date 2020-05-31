//
//  ViewHelper.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 10.05.20.
//

import Foundation

extension UIView {
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
    
    public func anchorCenteredToTop(size: CGSize) {
        guard let parent = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        self.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
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
}
