//
//  YouTubeViewModel.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import RxCocoa
import RxSwift

class YouTubeViewModel {
    
    private let youTubeService: YouTubeService
    private let bag = DisposeBag()
    
    init(service: YouTubeService?) {
        guard let service = service else {
            fatalError("YouTubeViewModel init")
        }
        self.youTubeService = service
    }
    
    func getChannels(by id: String) {
        youTubeService.getChannels(by: id)
            .subscribe { event in
            switch event {
            case let .success(channels):
                print("===>", channels.first?.statistics.subscriberCount ?? 0)
            case let .failure(error):
                fatalError()
            }
        }
        .disposed(by: bag)
    }
}
