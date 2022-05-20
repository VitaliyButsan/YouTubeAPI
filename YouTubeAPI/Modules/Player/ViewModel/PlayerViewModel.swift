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
    
    let trackingTime = BehaviorRelay<Float>(value: 0.0)
    
    let play = BehaviorRelay(value: false)
    let prew = BehaviorRelay(value: false)
    let next = BehaviorRelay(value: false)
    
    let volume = BehaviorRelay<Float>(value: 0.0)
    
}
