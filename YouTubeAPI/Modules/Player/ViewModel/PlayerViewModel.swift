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
    
    // controls
    let state = BehaviorRelay<PlayerWorkState>(value: .stop)
    let prew = BehaviorRelay(value: false)
    let next = BehaviorRelay(value: false)
    
    // volume
    let volume = BehaviorRelay<Float>(value: 0.0)
    
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
