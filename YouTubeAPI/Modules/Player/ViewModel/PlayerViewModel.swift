//
//  PlayerViewModel.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 18.05.2022.
//

import RxCocoa
import RxSwift

class PlayerViewModel {
    
    let bag = DisposeBag()
    
    // state
    var previousPlayerOpenedState: PlayerOpenCloseState = .close
    let isPlayerOpened = BehaviorRelay<PlayerOpenCloseState>(value: .close)
    let yOffset = BehaviorRelay<CGFloat>(value: 0.0)
    
    let didLayoutSubviewsSubject = PublishRelay<Void>()
    
    var currentPlayingVideo: PlaylistItem?
    
    // time
    var duration = 0.0
    
    let secondsInHour = 60 * 60
    let secondsInMinute = 60
    
    let currentTime = BehaviorRelay(value: 0.0)
    let currentTimeFormatted = BehaviorRelay(value: "")
    private var currMinutes = 0
    private var currSeconds = 0
    private var currHours = 0
    
    let remainTime = BehaviorRelay(value: 0.0)
    let remainTimeFormatted = BehaviorRelay(value: "")
    private var remainSeconds = 0
    private var remainMinutes = 0
    private var remainHours = 0
    
    let progress = BehaviorRelay<Float>(value: 0.0)
    
    // controls
    let state = BehaviorRelay<PlayerWorkState>(value: .stop)
    
    // volume
    let volume = BehaviorRelay<Float>(value: 0.0)
    
    // storage
    var videos: [PlaylistItem] = []
    
    init() {
        subscribeObservers()
    }
    
    func getStartedVideoId() -> String {
        if let currentPlayingVideo = currentPlayingVideo {
            return currentPlayingVideo.snippet.resourceId.videoId
        } else {
            guard let firstVideo = videos.first else { return "" }
            currentPlayingVideo = firstVideo
            let videoID = firstVideo.snippet.resourceId.videoId
            return videoID
        }
    }
    
    func getPreviousVideoId() -> String {
        guard let currentVideo = currentPlayingVideo else { return "" }
        var videoID = ""
        
        if currentVideo == videos.first {
            videoID = currentVideo.snippet.resourceId.videoId
        } else {
            guard let currVideoIndex = videos.firstIndex(where: { $0 == currentVideo }) else { return "" }
            let previousVideo = videos[currVideoIndex - 1]
            videoID = previousVideo.snippet.resourceId.videoId
            currentPlayingVideo = previousVideo
        }
        return videoID
    }
    
    func getNextVideoId() -> String {
        guard let currentVideo = currentPlayingVideo else { return "" }
        var videoID = ""
        
        if currentVideo == videos.last {
            videoID = currentVideo.snippet.resourceId.videoId
        } else {
            guard let currVideoIndex = videos.firstIndex(where: { $0 == currentVideo }) else { return "" }
            let nextVideo = videos[currVideoIndex + 1]
            videoID = nextVideo.snippet.resourceId.videoId
            currentPlayingVideo = nextVideo
        }
        return videoID
    }
    
    private func subscribeObservers() {
        currentTime
            .map { self.duration - $0 }
            .bind(to: remainTime)
            .disposed(by: bag)
        
        currentTime
            .map { time in
                self.formattedTime(by: time)
            }
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
            .map { time in
                "-" + self.formattedTime(by: time)
            }
            .bind(to: remainTimeFormatted)
            .disposed(by: bag)
    }
    
    private func formattedTime(by time: Double) -> String {
        let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(Int(time))
        return formattedTimeBy(hours, minutes, seconds)
    }
    
    private func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    private func formattedTimeBy(_ hours: Int, _ minutes: Int, _ seconds: Int) -> String {
        if Int(duration) >= secondsInHour {
            return String(format: "%01i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%01i:%02i", minutes, seconds)
        }
    }
}
