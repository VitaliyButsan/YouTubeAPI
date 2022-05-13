//
//  YouTubeViewModel.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import RxCocoa
import RxSwift
import RxDataSources

class YouTubeViewModel {
    
    // MARK: - Properties
    
    typealias ChannelSection = SectionModel<String, CellModel>
    
    // rx
    let bag: DisposeBag
    
    // managers
    private let youTubeService: YouTubeService
    
    //state
    private(set) var isLoadedData = BehaviorRelay(value: false)
    private(set) var errorSubject = BehaviorRelay(value: "")
    
    // storage
    private var channels = [Channel]()
    private(set) var dataSource = BehaviorRelay(value: [ChannelSection]())
    
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
        addMockData()
    }
    
    func channelsIdsCount() -> Int {
        return channelsIDs.count
    }
    
    func getData() {
        getChannels()
    }
    
    private func getChannels() {
        let group = DispatchGroup()
        
        for id in channelsIDs {
            group.enter()
            youTubeService.getChannels(by: id)
                .subscribe { [weak self] event in
                    guard let self = self else { return }
                    group.leave()
                    
                    switch event {
                    case let .success(channels):
                        guard let newChannel = channels.first else { return }
                        self.channels.append(newChannel)
                    case let .failure(error):
                        self.errorSubject.accept(error.localizedDescription)
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
        
        for channelId in channelsIDs {
            group.enter()
            youTubeService.getPlaylists(by: channelId)
                .subscribe { [weak self] event in
                    guard let self = self else { return }
                    group.leave()
                    
                    switch event {
                    case let .success(playlists):
                        let newPlaylists = Array(playlists.prefix(2))
                        self.addPlaylistsToChannel(newPlaylists, by: channelId)
                    case let .failure(error):
                        self.errorSubject.accept(error.localizedDescription)
                    }
                }
                .disposed(by: bag)
        }
        group.notify(queue: .main) {
            self.getPlaylistsItems()
        }
    }
    
    private func addPlaylistsToChannel(_ playlists: [PlaylistItem], by channelId: String) {
        guard let index = channels.firstIndex(where: { $0.id == channelId }) else { return }
        var tmpChannels = channels
        tmpChannels[index].playlists = playlists
        channels = tmpChannels
    }
    
    private func getPlaylistsItems() {
        let group = DispatchGroup()
        
        for channel in channels {
            guard let playlists = channel.playlists else { return }
            
            for playlist in playlists {
                group.enter()
                
                youTubeService.getPlaylistItems(by: playlist.id)
                    .subscribe { [weak self] event in
                        guard let self = self else { return }
                        group.leave()
                        
                        switch event {
                        case let .success(playlistItems):
                            self.addPlaylistsItemsToChannel(playlistItems, by: playlist.id, in: channel.id)
                        case let .failure(error):
                            self.errorSubject.accept(error.localizedDescription)
                        }
                    }
                    .disposed(by: bag)
            }
        }
        group.notify(queue: .main) {
            self.addPlaylistVideosViewCount()
        }
    }
    
    private func addPlaylistsItemsToChannel(_ playlistItems: [PlaylistItemsItem], by playlistId: String, in channelId: String) {
        guard let channelIndex = channels.firstIndex(where: { $0.id == channelId }) else { return }
        var tempChannels = channels
        guard let playlistIndex = tempChannels[channelIndex].playlists?.firstIndex(where: { $0.id == playlistId }) else { return }
        tempChannels[channelIndex].playlists?[playlistIndex].playlistItems = playlistItems
        channels = tempChannels
    }
    
    private func addPlaylistVideosViewCount() {
        let group = DispatchGroup()
        
        for channel in channels {
            guard let playlists = channel.playlists else { return }
            
            for playlist in playlists {
                guard let playlistItems = playlist.playlistItems else { return }
                
                for playlistItem in playlistItems {
                    group.enter()
                    
                    youTubeService.getVideos(by: playlistItem.snippet.resourceId.videoId)
                        .subscribe { [weak self] event in
                            guard let self = self else { return }
                            group.leave()
                            
                            switch event {
                            case let .success(videos):
                                guard let video = videos.first else { return }
                                let videoViewCount = video.statistics.viewCount
                                self.addVideoViewCountToPlaylistItem(viewCount: videoViewCount,
                                                                     with: playlistItem.id,
                                                                     by: playlist.id,
                                                                     in: channel.id)
                            case let .failure(error):
                                self.errorSubject.accept(error.localizedDescription)
                            }
                        }
                        .disposed(by: bag)
                }
            }
        }
        group.notify(queue: .main) {
            self.isLoadedData.accept(true)
            let sections = self.createSections(by: 0)
            self.dataSource.accept(sections)
        }
    }
    
    private func addVideoViewCountToPlaylistItem(viewCount: String, with playlistItemsItemId: String, by playlistId: String, in channelId: String) {
        var tempChannels = channels
        guard let channelIndex = channels.firstIndex(where: { $0.id == channelId }) else { return }
        guard let playlistIndex = tempChannels[channelIndex].playlists?.firstIndex(where: { $0.id == playlistId }) else { return }
        guard let playlistItemIndex = tempChannels[channelIndex].playlists?[playlistIndex].playlistItems?.firstIndex(where: { $0.id == playlistItemsItemId }) else { return }
        tempChannels[channelIndex].playlists?[playlistIndex].playlistItems?[playlistItemIndex].snippet.viewCount = viewCount
        channels = tempChannels
    }
    
    private func createSections(by channelIndex: Int) -> [ChannelSection] {
        guard let channel = getChannel(by: channelIndex) else { return [] }
        var sections: [ChannelSection] = []
        
        // add first fixed section
        let cell = CellModel(title: "", typeOfCell: .pageControl(channels: channels))
        let section = ChannelSection(model: "", items: [cell])
        sections.append(section)
        
        // add sections depends of playlists count
        for playlist in channel.playlists ?? [] {
            let cell = CellModel(title: playlist.snippet.title, typeOfCell: .playlist(playlist: playlist))
            let section = ChannelSection(model: "", items: [cell])
            sections.append(section)
        }
        return sections
    }
    
    private func getChannel(by index: Int) -> Channel? {
        if index > channels.count - 1 || index < 0 {
            return nil
        }
        let channel = channels[index]
        return channel
    }
    
    private func addMockData() {
        var sections: [ChannelSection] = []
        
        let section1Cells = [MockCell().channelsMock(4)]
        let section1 = ChannelSection(model: "Section 1", items: section1Cells)
        sections.append(section1)
        
        let section2Cells = [MockCell().playlistMock]
        let section2 = ChannelSection(model: "Section 2", items: section2Cells)
        let section3Cells = [MockCell().playlistMock]
        let section3 = ChannelSection(model: "Section 3", items: section3Cells)
        sections.append(section2)
        sections.append(section3)
        
        dataSource.accept(sections)
        print(dataSource.value.count)
        print()
    }
}
