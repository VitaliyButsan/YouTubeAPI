//
//  YouTubeViewModel.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import RxCocoa
import RxDataSources
import RxSwift

typealias ResourcesSection = SectionModel<String, CellModel>

class YouTubeViewModel {
    
    // MARK: - Properties
    
    // rx
    private let bag: DisposeBag
    var timerBag: DisposeBag!
    
    // services
    private let youTubeService: YouTubeService
    
    //state
    let isLoadedData = BehaviorRelay(value: false)
    let errorSubject = PublishRelay<String>()
    let timerCounter = BehaviorRelay(value: 0)
    
    let didLayoutSubviewsSubject = PublishRelay<Void>()
    let playerViewHeight = BehaviorRelay<CGFloat>(value: 0.0)
    
    // storage
    private var channels = [Channel]()
    private(set) var dataSource = BehaviorRelay(value: [ResourcesSection]())
    
    private let channelsIDs = [
        L10n.channelId1,
        L10n.channelId2,
        L10n.channelId3,
        L10n.channelId4,
    ]
    
    // To-Do move to Constants
    let sectionHeaderHeight: CGFloat = 60.0
    let defaultPadding: CGFloat = 18.0
    
    // MARK: - Lifecycle
    
    init(service: YouTubeService?) {
        guard let service = service else {
            fatalError("YouTubeViewModel init")
        }
        self.youTubeService = service
        self.bag = DisposeBag()
        self.timerBag = DisposeBag()
    }
    
    // public methods
    func startTimer() {
        Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.instance).bind { timePassed in
            self.timerCounter.accept(timePassed)
        }
        .disposed(by: timerBag)
    }
    
    func stopTimer() {
        timerBag = nil
        timerCounter.accept(0)
    }
    
    func channelsIdsCount() -> Int {
        return channelsIDs.count
    }
    
    func getSectionTitle(by sectionIndex: Int) -> String {
        if sectionIndex > dataSource.value.count - 1 || sectionIndex < 0 {
            return ""
        }
        let section = dataSource.value[sectionIndex]
        let sectionTitle = section.model
        return sectionTitle
    }
    
    func updateData(for channelIndex: Int) {
        let sections = self.createSections(for: channelIndex)
        self.dataSource.accept(sections)
    }
    
    // To-Do delete getData()
    func getData() {
        getChannels()
    }
    
    // private methods
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
                        self.addPlaylistsToChannel(playlists, by: channelId)
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
    
    private func addPlaylistsToChannel(_ playlists: [Playlist], by channelId: String) {
        guard let index = channels.firstIndex(where: { $0.id == channelId }) else { return }
        var tmpChannels = channels
        tmpChannels[index].playlists = playlists
        channels = tmpChannels
    }
    
    // TO-DO - forEach functions iteraciotn
    private func getPlaylistsItems() {
        let group = DispatchGroup()
        
        for channel in channels {
            guard let playlists = channel.playlists else { return }
            for playlist in playlists {
                group.enter()
                
                // TO-DO : subscribe: OnSeccess, sebcribe: OnFailure
                youTubeService.getPlaylistItems(by: playlist.id)
                    .subscribe { [weak self] event in
                        guard let self = self else { return }
                        group.leave()
                        
                        switch event {
                        case let .success(playlistItems):
                            self.addPlaylistItemsToChannelPlaylist(playlistItems, by: playlist.id, in: channel.id)
                        case let .failure(error):
                            self.errorSubject.accept(error.localizedDescription)
                        }
                    }
                // rename to disposeBag
                    .disposed(by: bag)
            }
        }
        group.notify(queue: .main) {
            self.addPlaylistVideosViewCount()
        }
    }
    
    
    // To-Do refactor guards
    private func addPlaylistItemsToChannelPlaylist(_ playlistItems: [PlaylistItem], by playlistId: String, in channelId: String) {
        guard let channelIndex = channels.firstIndex(where: { $0.id == channelId }) else { return }
        var tempChannels = channels
        guard let playlistIndex = tempChannels[channelIndex].playlists?.firstIndex(where: { $0.id == playlistId }) else { return }
        tempChannels[channelIndex].playlists?[playlistIndex].playlistItems = playlistItems
        channels = tempChannels
    }
    
    // TO-DO - forEach functions iteraciotn
    private func addPlaylistVideosViewCount() {
        let group = DispatchGroup()
        
        for channel in channels {
            guard let playlists = channel.playlists else { return }
            
            for playlist in playlists {
                guard let playlistItems = playlist.playlistItems else { return }
                
                for playlistItem in playlistItems {
                    group.enter()
                    
                    // TO-DO : subscribe: OnSeccess, sebcribe: OnFailure
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
            let sections = self.createSections(for: 0)
            self.dataSource.accept(sections)
        }
    }
    
    // TO-DO: Refactor -
    private func addVideoViewCountToPlaylistItem(viewCount: String, with playlistItemId: String, by playlistId: String, in channelId: String) {
        var tempChannels = channels
        guard let channelIndex = channels.firstIndex(where: { $0.id == channelId }) else { return }
        guard let playlistIndex = tempChannels[channelIndex].playlists?.firstIndex(where: { $0.id == playlistId }) else { return }
        guard let playlistItemIndex = tempChannels[channelIndex].playlists?[playlistIndex].playlistItems?.firstIndex(where: { $0.id == playlistItemId }) else { return }
        tempChannels[channelIndex].playlists?[playlistIndex].playlistItems?[playlistItemIndex].snippet.viewCount = viewCount
        channels = tempChannels
    }
    
    private func createSections(for channelIndex: Int) -> [ResourcesSection] {
        guard let channel = getChannel(by: channelIndex) else { return [] }
        var sections: [ResourcesSection] = []
        
        // add first fixed section
        let cell = CellModel(title: "", typeOfCell: .pageControl(model: channels))
        let section = ResourcesSection(model: "", items: [cell])
        sections.append(section)
        
        // add sections depends of playlists count
        for playlist in channel.playlists ?? [] {
            let rxPlaylist = rxPlaylist(from: playlist)
            let cell = CellModel(title: "", typeOfCell: .playlist(model: rxPlaylist))
            let section = ResourcesSection(model: playlist.snippet.title, items: [cell])
            sections.append(section)
        }
        return sections
    }
    
    private func getChannel(by index: Int) -> Channel? {
        if index > channels.count - 1, index < 0 {
            return nil
        }
        let channel = channels[index]
        return channel
    }
    
    private func rxPlaylist(from playlist: Playlist) -> RxPlaylist {
        let playlistId = playlist.id
        let playlistSnippetTitle = playlist.snippet.title
        let playlistItems = playlist.playlistItems ?? []
        
        let rxSection = PlaylistItemsSection(model: "", items: playlistItems)
        let rxSections = BehaviorRelay(value: [rxSection])
        let rxSnippet = RxPlaylist.Snippet(title: playlistSnippetTitle)
        let rxPlaylist = RxPlaylist(id: playlistId, snippet: rxSnippet, playlistItems: rxSections)
        
        return rxPlaylist
    }
}
