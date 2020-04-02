//
//  HybridViewTitleSubtitleCell.swift
//  Zee5PlayerPlugin
//
//  Created by Miri Klysa on 02/04/20.
//

import Foundation
import UIKit

class HybridViewTitleSubtitleCell: UICollectionViewCell {
    
    
    //MARK: IBOutlets
    
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    
    
    //MARK: props
    
    open var data: (title: String?, subtitle: String?, description: String?) {
        willSet(value) {
            titleLabel.text = (value.title != nil ? value.title! : String()) + (value.subtitle != nil ? value.subtitle! : String())
            subtitleLabel.text = value.description
        }
    }
    
    //init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createUIElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: create UI elements
    
    private func createUIElements() {
        
        titleLabel = UILabel()
        subtitleLabel = UILabel()
        
        titleLabel.numberOfLines = 2
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.numberOfLines = 2
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.adjustsFontSizeToFitWidth = true
        
        let containerView: UIView = UIView.init(frame: .zero)
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 0).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 0).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        containerView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        containerView.addSubview(subtitleLabel)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }
}
