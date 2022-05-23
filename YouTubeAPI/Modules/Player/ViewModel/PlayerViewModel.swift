//
//  PlayerViewModel.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 18.05.2022.
//

import RxCocoa
import RxSwift

class PlayerViewModel {
    
    var duration = 0.0
    var videos: [PlaylistItem] = []
    var previousPlayerOpenedState: PlayerOpenCloseState = .close
    var currentVideo = BehaviorRelay(value: PlaylistItem.placeholder)
    
    let bag = DisposeBag()
    let isPlayerOpened = BehaviorRelay<PlayerOpenCloseState>(value: .close)
    let yOffset = BehaviorRelay<CGFloat>(value: 0.0)
    let didLayoutSubviewsSubject = PublishRelay<Void>()
    
    let videoTitle = BehaviorRelay(value: "")
    let videoViewsCounter = BehaviorRelay(value: "")
    
    let currentTime = BehaviorRelay(value: 0.0)
    let currentTimeFormatted = BehaviorRelay(value: "")
    
    let remainTime = BehaviorRelay(value: 0.0)
    let remainTimeFormatted = BehaviorRelay(value: "")
    
    let progress = BehaviorRelay<Float>(value: 0.0)
    let state = BehaviorRelay<PlayerWorkState>(value: .stop)
    
    let volume = BehaviorRelay<Float>(value: 0.0)
    let systemVolume = BehaviorRelay<Float>(value: 0.0)
    
    
    init() {
        subscribeObservers()
    }
    
    func getStartedVideoId() -> String {
        guard let firstVideo = videos.first else { return "" }
        currentVideo.accept(firstVideo)
        return firstVideo.snippet.resourceId.videoId
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
    
    private func subscribeObservers() {
        currentTime
            .map { self.duration - $0 }
            .bind(to: remainTime)
            .disposed(by: bag)
        
        currentTime
            .map { self.formattedTime(by: $0) }
            .bind(to: currentTimeFormatted)
            .disposed(by: bag)
        
        currentTime
            .filter { !$0.isZero }
            .map { self.duration / $0 }
            .map { 1 / $0 }
            .map { Float($0) }
            .bind(to: progress)
            .disposed(by: bag)
            
        remainTime
            .map { "-" + self.formattedTime(by: $0) }
            .bind(to: remainTimeFormatted)
            .disposed(by: bag)
        
        currentVideo
            .map { $0.snippet.title }
            .bind(to: videoTitle)
            .disposed(by: bag)
        
        currentVideo
            .compactMap(\.snippet.viewCount)
            .compactMap { $0.splitIntoThounsandParts }
            .map { "\($0) просмотра"}
            .bind(to: videoViewsCounter)
            .disposed(by: bag)
        
        NotificationCenter.default.rx
            .notification(.volumeChanging)
            .compactMap(\.userInfo)
            .compactMap { $0[NSNotification.Name.audioVolume] }
            .compactMap { $0 as? Float }
            .bind(to: systemVolume)
            .disposed(by: bag)
    }
    
    private func formattedTime(by time: Double) -> String {
        let (hours, minutes, seconds) = secondsConvertToHoursMinutesSeconds(Int(time))
        return formattedTimeBy(hours, minutes, seconds)
    }
    
    private func secondsConvertToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        return (hours, minutes, seconds)
    }
    
    private func formattedTimeBy(_ hours: Int, _ minutes: Int, _ seconds: Int) -> String {
        let secondsInHour = (60 * 60)
        let duration = Int(duration)
        if duration >= secondsInHour {
            return String(format: "%01i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%01i:%02i", minutes, seconds)
        }
    }
}
