//
//  StreamTranslationsHelper.swift
//  Zee5PlayerPlugin
//
//  Created by Simon Borkin on 23.06.20.
//

import Foundation

fileprivate typealias StreamTranslationInfo = (title: String?, selected: String?, available: String?)

class StreamTranslationsView: UIStackView {
    @IBOutlet fileprivate var audioSelectionView: TranslationTrackSelectionView!
    @IBOutlet fileprivate var textSelectionView: TranslationTrackSelectionView!

    fileprivate let helper = StreamTranslationsHelper()
    
    func setupTranslations(playable: ZeePlayable?) {
        self.helper.setup(self, playable: playable)
        self.handleTracks()
    }
    
    fileprivate func handleTracks() {
        self.helper.handleAudioTracks(audioSelectionView: self.audioSelectionView)
        self.helper.handleTextTracks(textSelectionView: self.textSelectionView)
    }
}

fileprivate class StreamTranslationsHelper {
    fileprivate var playable: ZeePlayable!

    func setup(_ view: StreamTranslationsView, playable: ZeePlayable?) {
        guard let playable = playable else {
            view.isHidden = true
            return
        }
        
        self.playable = playable
    }
    
    func handleAudioTracks(audioSelectionView: TranslationTrackSelectionView) {
        let audioTracks = self.playable.audioTracks
        
        let title = StylesHelper.localizedText(for: "MoviesConsumption_MovieDetails_AudioLanguage_Text")
        
        let selected: String?
        if let firstTrack = audioTracks?.first {
            selected = firstTrack
        }
        else {
            selected = StylesHelper.localizedText(for: "MoviesConsumption_SubtitlesSelection_Off_Selection")
        }
        
        let available: String?
        if let audioTracks = audioTracks, audioTracks.count == 1 || audioTracks.count == 0  {
            available = "MoviesConsumption_MovieDetails_AvailableInOneLanguage_Text".localized(hashMap: [
                "count": "\(audioTracks.count)"
            ])
        }
        else {
            available = "MoviesConsumption_MovieDetails_AvailableInMultipleLanguages_Text".localized(hashMap: [
                "count": "\(audioTracks?.count ?? 0)"])
        }
        
        let info = StreamTranslationInfo(title, selected, available)
        fill(view: audioSelectionView, info)
        
        audioSelectionView.addGestureRecognizer(UITapGestureRecognizer(closure: { (gesture) in
            ZEE5PlayerManager.sharedInstance().getAudioLanguage()
        }))
    }
    
    func handleTextTracks(textSelectionView: TranslationTrackSelectionView) {
        let textTracks = self.playable.textTracks
        
        let title = StylesHelper.localizedText(for: "MoviesConsumption_MovieDetails_Subtitles_Text")
        
        let selected: String?
        if let firstTrack = textTracks?.first {
            selected = firstTrack
        }
        else {
            selected = StylesHelper.localizedText(for: "MoviesConsumption_SubtitlesSelection_Off_Selection")
        }
        
        let available: String?
        if let textTracks = textTracks, textTracks.count == 1 || textTracks.count == 0  {
            available = "MoviesConsumption_MovieDetails_AvailableInOneLanguage_Text".localized(hashMap: [
                "count": "\(textTracks.count)"
            ])
        }
        else {
            available = "MoviesConsumption_MovieDetails_AvailableInMultipleLanguages_Text".localized(hashMap: [
                "count": "\(textTracks?.count ?? 0)"])
        }
        
        let info = StreamTranslationInfo(title, selected, available)
        fill(view: textSelectionView, info)
        
        textSelectionView.addGestureRecognizer(UITapGestureRecognizer(closure: { (gesture) in
            ZEE5PlayerManager.sharedInstance().showSubtitleActionSheet()
        }))
    }
    
    func fill(view: TranslationTrackSelectionView, _ info: StreamTranslationInfo) {
        guard
            let title = info.title,
            let titleStyle = StylesHelper.style(for: "consumption_text_description"),
            let selected = info.selected,
            let selectedStyle = StylesHelper.style(for: "consumption_text_indicator"),
            let available = info.available,
            let availableStyle = StylesHelper.style(for: "consumption_visibility_text") else {
                return
        }
                 
        view.titleLabel.textColor = titleStyle.color
        view.titleLabel.font = titleStyle.font
        view.titleLabel.text = title
        
        view.selectedTrackLabel.textColor = selectedStyle.color
        view.selectedTrackLabel.font = selectedStyle.font
        view.selectedTrackLabel.text = selected
        
        view.availableTracksLabel.textColor = availableStyle.color
        view.availableTracksLabel.font = availableStyle.font
        view.availableTracksLabel.text = available
    }
}

class TranslationTrackSelectionView: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var selectedTrackLabel: UILabel!
    @IBOutlet var availableTracksLabel: UILabel!
    
    override func awakeAfter(using coder: NSCoder) -> Any? {
        guard self.subviews.count == 0 else {
            return self
        }
        
        let bundle = Bundle(for: type(of: self))
        let view = bundle.loadNibNamed("TranslationTrackSelectionView", owner: nil, options: nil)?.first
        
        return view
    }
}
