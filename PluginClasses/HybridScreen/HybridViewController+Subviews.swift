//
//  HybridViewController+Buttons.swift
//  Alamofire
//
//  Created by Miri on 31/03/2020.
//
    
import Foundation
import ZappPlugins
import ZappSDK
import UIKit
import Zee5CoreSDK
import ZeeHomeScreen

extension HybridViewController {
        
        // MARK: setup
        
        func setupButtons() {
            guard let buttonViewCollection = self.buttonsViewCollection else {
                return
            }

            buttonViewCollection.forEach { (button) in
                if let tmpButton = button as? CAButton {
                    tmpButton.removeTarget(tmpButton, action: #selector(CAButton.handleElementAction(_:)), for: .touchUpInside)
                    switch tmpButton.tag {
                    case ItemTag.Button.consumptionMoreLessDescriptionButton:
                        let arrowImage = ZAAppConnector.sharedInstance().image(forAsset: "consumption_arrow_down")
                        tmpButton.setImage(arrowImage, for: .normal)
                        tmpButton.imageEdgeInsets.top = 45
                        itemDescriptionLabel!.numberOfLines = 2
                        tmpButton.addTarget(self, action: #selector(consumptionMoreLessDescriptionButtonAction(_:)), for: .touchUpInside)
                        
                    default:
                        break
                    }
                }
            }
        }
        
        func setupLabels() {
            guard
                let labelsViewCollection = self.labelsCollection,
                let playable = self.playable else {
                    return
            }
            
            labelsViewCollection.forEach { (label) in
                switch label.tag {
                case ItemTag.Label.storyLineLabel:
                    label.text = "Upcoming_Body_StoryLine_Text".localized(hashMap: [:])
                    
                case ItemTag.Label.releasingOnLabel:
                    var releasingString: String = "Upcoming_Body_ReleasingOn_Text".localized(hashMap: ["release_date": String()]) + ""
                    
                    guard let date = playable.releaseYear, !date.isEmptyOrWhitespace() else {
                        label.text = releasingString
                        return
                    }
                    
                    var releaseString: String?
                    //create date from string
                    let dateFormatter = DateFormatter.init()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    let releaseDate: Date = dateFormatter.date(from: date)!
                    dateFormatter.dateFormat = "dd MMMM"
                    
                    releaseString = dateFormatter.string(from: releaseDate)
                    
                    releasingString = releasingString + (releaseString ?? String())
                    label.text = releasingString
                    
                case ItemTag.Label.numberTagLabel:
                    guard let numberText = playable.numberTag else {
                        return
                    }
                    
                    label.text = "\(numberText)"
                case ItemTag.Label.consumptionTitleLabel:
                    label.text = playable.title
                    label.isHidden = label.text == nil
                    
                case ItemTag.Label.consumptionIMDBRatingLabel:
                    guard
                        playable.consumptionType != .live,
                        let rating = playable.rating else {
                            label.isHidden = true
                            return
                    }
                    
                    label.text = rating
                    label.layer.cornerRadius = 3
                    label.isHidden = false
         
                case ItemTag.Label.consumptionAvailableInLabel:
                    label.text = "MoviesConsumption_MovieDetails_AvailableVideoTechnology_Text".localized(hashMap: ["video_technology": String()])
                
                case ItemTag.Label.consumptionDescriptionLabel:
                    let descriptionStyle = stylesFor(key: "consumption_text_description")
                    label.textColor = descriptionStyle.color
                    label.font = descriptionStyle.font

                case ItemTag.Label.consumptionCastLabel:
                    label.text = "     " + "MoviesConsumption_MovieDetails_Cast_Link".localized(hashMap: [:])
                    
                case ItemTag.Label.consumptionCreatorsLabel:
                    label.text = "     " + "MoviesConsumption_MovieDetails_Creators_Text".localized(hashMap: [:])
                    
                default:
                    break
                }
            }
        }
        
        func setupViews() {
            self.handleRelatedContent()
            
            guard
                let viewsViewCollection = self.viewCollection,
                let playable = self.playable else {
                    return
            }
            
            PartnerAppHelper.setup(self.partnerAppView)
            
            viewsViewCollection.forEach { (view) in
                if let actionBarView = view as? ActionBarView {
                    ActionBarHelper.setup(playable: playable, actionBarView: actionBarView)
                    return
                }
                                
                switch view.tag {
                case ItemTag.View.premiumBanner:
                    guard let bannerView = view as? PremiumBanner else {
                        return
                    }
                    if Singleton.isPremiumBanner == false {
                        return
                    }
                    bannerView.backgroundColor = .clear
                    bannerView.setupBanner(playable: playable)

                case ItemTag.View.adsBanner:
                    guard let bannerView = view as? AdBanner else {
                        return
                    }
                    
                    bannerView.backgroundColor = .clear
                    bannerView.setupAds(playable: playable)

                case ItemTag.View.consumptionCastCollection, ItemTag.View.consumptionCreatorCollection:
                    if let tmpView = view as? UICollectionView {
                        tmpView.delegate = self
                        tmpView.dataSource = self
                        
                        tmpView.register(HybridViewTitleSubtitleCell.self, forCellWithReuseIdentifier: "HybridViewTitleSubtitleCell")
                        
                        setupDataSources()
                        tmpView.reloadData()
                    }
                    
                case ItemTag.View.consumptionCastCollectionStackView, ItemTag.View.consumptionCreatorCollectionStackView:
                    setupDataSources()
                    
                    switch view.tag {
                    case ItemTag.View.consumptionCastCollectionStackView:
                        //remove cast collection view from the stack view if it is empty
                        if castDataSource == nil || castDataSource?.count == 0 {
                            (view as! UIStackView).removeFromSuperview()
                        }
                        
                    case ItemTag.View.consumptionCreatorCollectionStackView:
                        //remove creators collection view from the stack view if it is empty
                        if creatorsDataSource == nil || creatorsDataSource?.count == 0 {
                            (view as! UIStackView).removeFromSuperview()
                        }
                    default: break
                    }
                    
                case ItemTag.View.consumptionButtonsView:
                    guard let buttonsBackgroundStyle = ZAAppConnector.sharedInstance().layoutsStylesDelegate.styleParams?(byStyleName: "consumption_bg_buttons"),
                        let color = buttonsBackgroundStyle["color"] as? UIColor else {
                            return
                    }
                    (view as! UIStackView).addBackground(color: color)
                    
                default:
                    break
                }
            }
        }
        
        //MARK:
        
        private func stylesFor(key: String) -> (font: UIFont, color: UIColor) {
            return StylesHelper.style(for: key) ?? (font: UIFont.systemFont(ofSize: 14), color: UIColor.white)
        }
        
        @objc func consumptionMoreLessDescriptionButtonAction(_ sender: CAButton) {
            sender.isSelected = !sender.isSelected
            sender.setImage(ZAAppConnector.sharedInstance().image(forAsset: sender.isSelected ? "consumption_arrow_up" : "consumption_arrow_down"), for: [.normal, .selected])
            
            self.itemDescriptionLabel.numberOfLines = sender.isSelected ? 0 : 2
            self.itemDescriptionLabel.setNeedsLayout()
            self.itemDescriptionLabel.layoutIfNeeded()
            
            self.mainCollectionViewController?.invalidateLayout()
        }
    
    private func handleRelatedContent() {
        func resetMetadataContainer() {
            if self.metadataViewContainer.superview != self.mainCollectionViewContainer {
                self.mainCollectionViewContainer.addSubview(self.metadataViewContainer)
                
                self.metadataViewContainer.anchorToTop()
            }
        }
        
        guard
            let playable = self.playable,
            let contentId = playable.contentId else {
                resetMetadataContainer()
                return
        }
        
        let queryItems = [
            URLQueryItem(name: "type", value: "RelatedContent"),
            URLQueryItem(name: "id", value: contentId),
            URLQueryItem(name: "feed_type", value: String(describing: playable.consumptionType))
        ]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "zee5"
        urlComponents.host = "fetchData"
        urlComponents.queryItems = queryItems

        guard
            let url = urlComponents.url?.absoluteString,
            let atomFeed = APAtomFeed(url: url) else {
                resetMetadataContainer()
                return
        }
        
        if let mainCollectionViewController = self.mainCollectionViewController {
            mainCollectionViewController.removeFromParent()
        }
        
        self.mainCollectionViewContainer.removeAllSubviews()
        
        let mainCollectionViewController = StaticViewCollectionViewController()
        self.mainCollectionViewController = mainCollectionViewController
        
        self.metadataViewContainer.removeFromSuperview()
        
        mainCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addChild(mainCollectionViewController)
        self.mainCollectionViewContainer.addSubview(mainCollectionViewController.view)
        
        mainCollectionViewController.view.fillParent()
        mainCollectionViewController.didMove(toParent: self)
        
        mainCollectionViewController.view.backgroundColor = .clear
        mainCollectionViewController.load(atomFeed, staticView: self.metadataViewContainer)
    }
}

    //MARK: extension
    
    extension HybridViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            switch collectionView.tag {
            case ItemTag.View.consumptionCastCollection:
                return castDataSource?.count ?? 0
            case ItemTag.View.consumptionCreatorCollection:
                return creatorsDataSource?.count ?? 0
            default:
                break
            }
            return 0
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HybridViewTitleSubtitleCell", for: indexPath) as? HybridViewTitleSubtitleCell else {
                    return UICollectionViewCell()
            }
            
            var dataSource: [(title: String?, subtitle: String?, description: String?)]?
            var textAlignment: NSTextAlignment!
            
            switch collectionView.tag {
            case ItemTag.View.consumptionCastCollection:
                dataSource = castDataSource
                textAlignment = .left
            case ItemTag.View.consumptionCreatorCollection:
                dataSource = creatorsDataSource
                textAlignment = .left
            default:
                break
            }
            
            if dataSource != nil {
                let model = dataSource![indexPath.row]
                
                cell.data = model
                cell.titleLabel.textAlignment = textAlignment
                cell.subtitleLabel.textAlignment = textAlignment
                
                let descriptionStyle = stylesFor(key: "consumption_text_description")
                let indicatorStyle = stylesFor(key: "consumption_text_indicator")

                switch collectionView.tag {
                case ItemTag.View.consumptionCastCollection, ItemTag.View.consumptionCreatorCollection:
                    cell.titleLabel.textColor = descriptionStyle.color
                    cell.titleLabel.font = descriptionStyle.font
                    cell.subtitleLabel.textColor = indicatorStyle.color
                    cell.subtitleLabel.font = indicatorStyle.font
                    cell.titleLabel.text = model.title
                    cell.subtitleLabel.text = model.description
                default:
                    break
                }
            }
            
            cell.backgroundColor = .clear
            
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            let screen = UIScreen.main.bounds.width
            switch collectionView.tag {
            case ItemTag.View.consumptionCastCollection:
                return CGSize(width: screen/3, height: collectionView.frame.size.height)
            case ItemTag.View.consumptionCreatorCollection:
                return CGSize(width: screen/3, height: collectionView.frame.size.height)
            default: break
            }
            return CGSize.zero
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 2
        }
        
        func collectionView(_ collectionView: UICollectionView, layout
            collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 2
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        }
    }
    
    extension ZAAppConnector {
        func image(forAsset asset: String?) -> UIImage? {
            guard let asset = asset else {
                return nil
            }
            
            if let image = UIImage(named: asset) {
                return image
            }
            else { return nil }
        }
    }
    
    extension UIStackView {
        func addBackground(color: UIColor) {
            let subView = UIView(frame: bounds)
            subView.backgroundColor = color
            subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            insertSubview(subView, at: 0)
        }
}
