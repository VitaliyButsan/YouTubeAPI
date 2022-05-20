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
    
    let currentTime = BehaviorRelay<Double>(value: 0.0)
    var duration = 0.0
    
    let state = BehaviorRelay<PlayerWorkState>(value: .stop)
    let prew = BehaviorRelay<Bool>(value: false)
    let next = BehaviorRelay<Bool>(value: false)
    
    let volume = BehaviorRelay<Float>(value: 0.0)
    
}
