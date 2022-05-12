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
    private var channels = BehaviorRelay(value: [Channel]()) ///  ??  may not BehaviorRelay()
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
        
        setupObservers()
    }
    
    func channelsIdsCount() -> Int {
        return channelsIDs.count
    }
    
    func getData() {
        getChannels()
    }
    
    private func setupObservers() {
        
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
                        self.channels.accept(self.channels.value + [newChannel])
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
        guard let index = channels.value.firstIndex(where: { $0.id == channelId }) else { return }
        var tmpChannels = channels.value
        tmpChannels[index].playlists = playlists
        channels.accept(tmpChannels)
    }
    
    private func getPlaylistsItems() {
        let group = DispatchGroup()
        
        for channel in channels.value {
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
        guard let channelIndex = channels.value.firstIndex(where: { $0.id == channelId }) else { return }
        var tempChannels = channels.value
        guard let playlistIndex = tempChannels[channelIndex].playlists?.firstIndex(where: { $0.id == playlistId }) else { return }
        tempChannels[channelIndex].playlists?[playlistIndex].playlistItems = playlistItems
        channels.accept(tempChannels)
    }
    
    private func addPlaylistVideosViewCount() {
        let group = DispatchGroup()
        
        for channel in channels.value {
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
            let cells = self.createCells(by: 0)
            let newSection = ChannelSection(model: "", items: cells)
            self.dataSource.accept([newSection])
        }
    }
    
    private func addVideoViewCountToPlaylistItem(viewCount: String, with playlistItemsItemId: String, by playlistId: String, in channelId: String) {
        var tempChannels = channels.value
        guard let channelIndex = channels.value.firstIndex(where: { $0.id == channelId }) else { return }
        guard let playlistIndex = tempChannels[channelIndex].playlists?.firstIndex(where: { $0.id == playlistId }) else { return }
        guard let playlistItemIndex = tempChannels[channelIndex].playlists?[playlistIndex].playlistItems?.firstIndex(where: { $0.id == playlistItemsItemId }) else { return }
        tempChannels[channelIndex].playlists?[playlistIndex].playlistItems?[playlistItemIndex].snippet.viewCount = viewCount
        channels.accept(tempChannels)
    }
    
    private func createCells(by channelIndex: Int) -> [CellModel] {
        guard let channel = getChannel(by: channelIndex) else { return [] }
        var cells: [CellModel] = []
        // add first fixed cell
        let firstCell = CellModel(title: "", typeOfCell: .pageControl(channels: channels.value))
        cells.append(firstCell)
        // add cells depends of playlists count
        for playlist in channel.playlists ?? [] {
            let newCellModel = CellModel(title: "", typeOfCell: .playlist(playlist: playlist))
            cells.append(newCellModel)
        }
        return cells
    }
    
    private func getChannel(by index: Int) -> Channel? {
        if index > channels.value.count - 1 || index < 0 {
            return nil
        }
        let channel = channels.value[index]
        return channel
    }
}

struct CellModel {
    
    enum CellType {
        case pageControl(channels: [Channel])
        case playlist(playlist: PlaylistItem)
    }
    
    let title: String
    let typeOfCell: CellType
}
