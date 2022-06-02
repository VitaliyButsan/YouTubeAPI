//
//  PlayerViewModel.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 18.05.2022.
//

import RxCocoa
import RxSwift

class PlayerViewModel {
    
    // MARK: - Properties
    
    var duration = 0.0
    var videos = [PlaylistItem]()
    var previousPlayerOpenedState = ShowPlayerState.close
    var currentVideo = BehaviorRelay(value: PlaylistItem.placeholder)
    
    let isPlayerOpened = BehaviorRelay<ShowPlayerState>(value: .close)
    let yOffset = BehaviorRelay<CGFloat>(value: 0.0)
    let didLayoutSubviewsSubject = PublishRelay<Void>()
    
    let videoTitle = BehaviorRelay(value: "")
    let videoViewCounter = BehaviorRelay(value: "")
    
    let currentTime = BehaviorRelay(value: 0.0)
    let currentTimeFormatted = BehaviorRelay(value: "")
    
    let remainTime = BehaviorRelay(value: 0.0)
    let remainTimeFormatted = BehaviorRelay(value: "")
    
    let progress = BehaviorRelay<Float>(value: 0.0)
    let state = BehaviorRelay<PlayerWorkState>(value: .stop)
    
    let volume = BehaviorRelay<Float>(value: 0.0)
    let systemVolume = BehaviorRelay<Float>(value: 0.0)
    
    private let disposeBag = DisposeBag()
    private let secondsInHour = 60 * 60
    
    // MARK: - Init
    
    init() {
        bindObservers()
    }
    
    // MARK: - Public methods
    
    func getStartedVideo() -> PlaylistItem? {
        guard let firstVideo = videos.first else { return nil }
        currentVideo.accept(firstVideo)
        return firstVideo
    }
    
    func getPreviousVideoId() -> String {
        var videoID = ""
        if currentVideo.value == videos.first {
            videoID = currentVideo.value.snippet.resourceId.videoId
        } else {
            guard let currVideoIndex = videos.firstIndex(where: { $0 == currentVideo.value }) else { return "" }
            let previousVideo = videos[currVideoIndex - 1]
            videoID = previousVideo.snippet.resourceId.videoId
            currentVideo.accept(previousVideo)
        }
        return videoID
    }
    
    func getNextVideoId() -> String {
        var videoID = ""
        if currentVideo.value == videos.last {
            videoID = currentVideo.value.snippet.resourceId.videoId
        } else {
            guard let currVideoIndex = videos.firstIndex(where: { $0 == currentVideo.value }) else { return "" }
            let nextVideo = videos[currVideoIndex + 1]
            videoID = nextVideo.snippet.resourceId.videoId
            currentVideo.accept(nextVideo)
        }
        return videoID
    }
    
    // MARK: - Private methods
    
    private func bindObservers() {
        currentTime
            .map { self.duration - $0 }
            .bind(to: remainTime)
            .disposed(by: disposeBag)
        
        currentTime
            .map { self.formattedTime(by: $0) }
            .bind(to: currentTimeFormatted)
            .disposed(by: disposeBag)
        
        currentTime
            .map { self.duration / $0 }
            .map { 1 / $0 }
            .map { Float($0) }
            .bind(to: progress)
            .disposed(by: disposeBag)
            
        remainTime
            .map { "-" + self.formattedTime(by: $0) }
            .bind(to: remainTimeFormatted)
            .disposed(by: disposeBag)
        
        currentVideo
            .map { $0.snippet.title }
            .bind(to: videoTitle)
            .disposed(by: disposeBag)
        
        currentVideo
            .compactMap(\.snippet.viewCount)
            .compactMap { $0.splitIntoThounsandParts }
            .map { "\($0) просмотра" }
            .bind(to: videoViewCounter)
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(.volumeChanging)
            .compactMap(\.userInfo)
            .compactMap { $0[NSNotification.Name.audioVolume] }
            .compactMap { $0 as? Float }
            .bind(to: systemVolume)
            .disposed(by: disposeBag)
    }
    
    private func formattedTime(by seconds: Double) -> String {
        let (hours, minutes, seconds) = convertToHoursMinutesSeconds(from: Int(seconds))
        return formattedTimeBy(hours, minutes, seconds)
    }
    
    private func convertToHoursMinutesSeconds(from seconds: Int) -> (Int, Int, Int) {
        let hours = seconds / secondsInHour
        let minutes = (seconds % secondsInHour) / 60
        let seconds = (seconds % secondsInHour) % 60
        return (hours, minutes, seconds)
    }
    
    private func formattedTimeBy(_ hours: Int, _ minutes: Int, _ seconds: Int) -> String {
        if Int(duration) >= secondsInHour {
            return String(format: "%01i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%01i:%02i", minutes, seconds)
        }
    }
}
