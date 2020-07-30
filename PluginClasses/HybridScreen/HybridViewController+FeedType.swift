//
//  HybridViewController+FeedType.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 22.06.20.
//

import Foundation

extension HybridViewController {
    func configureForType() {
        guard let playable = self.playable else {
            return
        }
        
        let type = playable.consumptionType
        
        self.infoLabel.text = InfoTextBuilder().build(type: type, playable: playable)
        self.infoLabel.isHidden = self.infoLabel.text == nil
        
        if type == .live || type == .news || type == .channel {
            self.streamTranslationsView.isHidden = true
        }
        else {
            self.streamTranslationsView.isHidden = false
            self.streamTranslationsView.setupTranslations(playable: self.playable)
        }
    }
}

class InfoTextBuilder {
    private var text: String? = nil
    
    func build(type: ConsumptionFeedType, playable: ZeePlayable) -> String? {
        switch type {
        case .movie, .trailer, .show, .original:
            add(type.rawValue)
            add(playable.releaseYear)
            addDuration(playable.duration)
            add(playable.genre)
            add(playable.age)

        case .episode:
            if let seasonDetails = playable.parentSeasonDetails, let totalEpisodes = seasonDetails.totalEpisodes {
                add("\(totalEpisodes) Episodes")
            }
            else {
                add(type.rawValue)
            }
            
            add(playable.releaseYear)
            add(playable.genre)
            add(playable.age)
            
        case .news:
            add(playable.owner)
            add(playable.genre)
            addDate(playable.releaseDate)
            addDuration(playable.duration)
        
        case .music:
            add("Videos")
            addDuration(playable.duration)
            add(playable.genre)
            add(playable.age)

        case .live, .channel:
            add("Live TV")
            add(playable.owner)
            
            break
            
        default:
            add(playable.primaryCategory)
            add(playable.releaseYear)
            add(playable.genre)
            add(playable.age)
        }
        
        return text
    }
    
    fileprivate func addDate(_ value: String?) {
        guard let value = value, !value.isEmptyOrWhitespace() else {
            return
        }
        
        add(formatDate(value: value))
    }

    fileprivate func addDuration(_ value: Int?) {
        guard let value = value, value > 0 else {
            return
        }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        
        add(formatter.string(from: TimeInterval(value)))
    }

    fileprivate func add(_ value: String?) {
        guard let value = value, !value.isEmptyOrWhitespace() else {
            return
        }
        
        if text == nil {
            text = String(value)
        }
        else {
            text! += " • \(value)"
        }
    }
    
    fileprivate func formatDate(value: String) -> String? {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let date = inputDateFormatter.date(from: value) else {
            return nil
        }
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "dd MMM"
        
        return outputDateFormatter.string(from: date)
    }
}
