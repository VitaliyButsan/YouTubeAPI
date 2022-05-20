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
    let volume = BehaviorRelay<Float>(value: 0.0)
    
    
    
}
