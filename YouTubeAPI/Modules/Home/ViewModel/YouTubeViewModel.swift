//
//  YouTubeViewModel.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import RxCocoa
import RxSwift
//import RxDataSources

class YouTubeViewModel {
    
    // MARK: - Properties
    
//    // typealiases
//    typealias Section = SectionModel<String, PlaylistItem>
    
    // managers
    private let youTubeService: YouTubeService
    private let bag: DisposeBag
    
    //state
    private(set) var isLoadedData = BehaviorRelay(value: false)
    
    // storage
    private(set) var channels = BehaviorRelay(value: [Channel]())
//    private(set) var sections = BehaviorRelay(value: [Section]())
    
    private let channelsIDs = [
        L10n.channelId1,
        L10n.channelId2,
        L10n.channelId3,
        L10n.channelId4,
    ]
    
    // MARK: - Lifecycle
    
    init(service: YouTubeService?) {
        guard let service = service else {
            fatalError("YouTubeViewModel init")
        }
        self.youTubeService = service
        self.bag = DisposeBag()
    }
    
    func getData() {
        getChannels()
    }
    
    private func getChannels() {
        let group = DispatchGroup()
        
        for id in channelsIDs {
            group.enter()
            youTubeService.getChannels(by: id)
                .subscribe { event in
                    group.leave()
                    switch event {
                    case let .success(channels):
                        print("===>", channels.first?.statistics.subscriberCount ?? 0)
                    case let .failure(error):
                        fatalError()
                    }
                }
                .disposed(by: bag)
        }
        group.notify(queue: .main) {
            self.getPlaylists()
        }
    }
    
    private func getPlaylists() {
        let group = DispatchGroup()
        
        for id in channelsIDs {
            group.enter()
            youTubeService.getPlaylists(by: id)
                .subscribe { event in
                    group.leave()
                    switch event {
                    case let .success(playlists):
                        playlists.forEach { print("\n", $0.snippet.title) }
                    case let .failure(error):
                        fatalError()
                    }
                }
                .disposed(by: bag)
        }
        group.notify(queue: .main) {
            self.isLoadedData.accept(true)
        }
    }
}
