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
    
    // time
    var duration = 0.0
    
    let currentTime = BehaviorRelay(value: 0.0)
    let currentTimeFormatted = BehaviorRelay(value: "")
    private var currMinutes = 0
    private var currSeconds = 0
    
    let remainTime = BehaviorRelay(value: 0.0)
    let remainTimeFormatted = BehaviorRelay(value: "")
    private var remainSeconds = 0
    private var remainMinutes = 0
    
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
    
    private func subscribeObservers() {
        currentTime
            .map { self.duration - $0 }
            .bind(to: remainTime)
            .disposed(by: bag)
        
        currentTime
            .map { Int($0) }
            .map { time in
                self.currMinutes = (time / 60)
                self.currSeconds = time - (60 * self.currMinutes)
                return String(format: "%01i:%02i", self.currMinutes, self.currSeconds)
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
            .map { Int($0) }
            .map { time in
                self.remainMinutes = (time / 60)
                self.remainSeconds = time - (60 * self.remainMinutes)
                return "-" + String(format: "%01i:%02i", self.remainMinutes, self.remainSeconds)
            }
            .bind(to: remainTimeFormatted)
            .disposed(by: bag)
    }
    
}
