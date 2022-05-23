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
    
    var timerBag: DisposeBag!
    
    private(set) var dataSource = BehaviorRelay(value: [ResourcesSection]())
    
    private var channels = [Channel]()
    
    let isLoadedData = BehaviorRelay(value: false)
    let errorSubject = PublishRelay<String>()
    let timerCounter = BehaviorRelay(value: 0)
    
    let didLayoutSubviewsSubject = PublishRelay<Void>()
    let playerViewHeight = BehaviorRelay<CGFloat>(value: 0.0)
    
    private let disposeBag: DisposeBag
    private let youTubeService: YouTubeService
    
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
        self.disposeBag = DisposeBag()
        self.timerBag = DisposeBag()
    }
    
    // MARK: - Public methods
    
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
    
    func getChannels() {
        let group = DispatchGroup()
        
        for channelId in channelsIDs {
            group.enter()
            
            youTubeService.getChannels(by: channelId)
                .subscribe(onSuccess: { channels in
                    group.leave()
                    guard let newChannel = channels.first else { return }
                    self.channels.append(newChannel)
                }, onFailure: { error in
                    self.errorSubject.accept(error.localizedDescription)
                })
                .disposed(by: disposeBag)
        }
        group.notify(queue: .main) {
            self.getPlaylists()
        }
    }
    
    // MARK: Private methods
    
    private func getPlaylists() {
        let group = DispatchGroup()
        
        for channelId in channelsIDs {
            group.enter()
            getPlaylists(by: channelId, with: group)
        }
        group.notify(queue: .main) {
            self.getPlaylistsItems()
        }
    }
    
    private func getPlaylists(by channelId: String, with group: DispatchGroup) {
        youTubeService.getPlaylists(by: channelId)
            .subscribe(onSuccess: { [weak self] playlists in
                guard let self = self else { return }
                group.leave()
                self.addPlaylistsToChannel(playlists, by: channelId)
            }, onFailure: { error in
                self.errorSubject.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func addPlaylistsToChannel(_ playlists: [Playlist], by channelId: String) {
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
                getPlaylistsItems(by: playlist.id, for: channel.id, with: group)
            }
        }
        group.notify(queue: .main) {
            self.addPlaylistVideosViewCount()
        }
    }
    
    private func getPlaylistsItems(by playlistId: String, for channelId: String, with group: DispatchGroup) {
        youTubeService.getPlaylistItems(by: playlistId)
            .subscribe(onSuccess: { [weak self] playlistItems in
                guard let self = self else { return }
                group.leave()
                self.addPlaylistItemsToPlaylist(playlistItems, by: playlistId, for: channelId)
            }, onFailure: { error in
                self.errorSubject.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func addPlaylistItemsToPlaylist(_ playlistItems: [PlaylistItem], by playlistId: String, for channelId: String) {
        guard let channelIndex = channels.firstIndex(where: { $0.id == channelId }) else { return }
        guard let playlists = channels[channelIndex].playlists else { return }
        guard let playlistIndex = playlists.firstIndex(where: { $0.id == playlistId }) else { return }
        channels[channelIndex].playlists?[playlistIndex].playlistItems = playlistItems
    }
    
    private func addPlaylistVideosViewCount() {
        let group = DispatchGroup()
        
        for channel in channels {
            setVideosViewCount(to: channel, with: group)
        }
        group.notify(queue: .main) {
            self.isLoadedData.accept(true)
            let sections = self.createSections(for: 0)
            self.dataSource.accept(sections)
        }
    }
    
    private func setVideosViewCount(to channel: Channel, with group: DispatchGroup) {
        guard let playlists = channel.playlists else { return }
        
        for playlist in playlists {
            setVideosViewCount(to: playlist, with: group, for: channel)
        }
    }
    
    private func setVideosViewCount(to playlist: Playlist, with group: DispatchGroup, for channel: Channel) {
        guard let playlistItems = playlist.playlistItems else { return }
        
        for playlistItem in playlistItems {
            group.enter()
            
            let itemResource = PlaylistItemResource(
                id: playlistItem.id,
                videoId: playlistItem.snippet.resourceId.videoId,
                playlistId: playlist.id,
                channelId: channel.id,
                viewCount: ""
            )
            getVideos(by: itemResource, with: group)
        }
    }
    
    private func getVideos(by itemResource: PlaylistItemResource, with group: DispatchGroup) {
        youTubeService.getVideos(by: itemResource.videoId)
            .subscribe(onSuccess: { [weak self] videos in
                guard let self = self else { return }
                group.leave()
                
                guard let video = videos.first else { return }
                var tempItemResource = itemResource
                tempItemResource.viewCount = video.statistics.viewCount
                
                self.addVideoViewCountToPlaylistItem(by: tempItemResource)
            }, onFailure: { error in
                self.errorSubject.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func addVideoViewCountToPlaylistItem(by itemResource: PlaylistItemResource) {
        let playlistItemId = itemResource.id
        let playlistId = itemResource.playlistId
        let channelId = itemResource.channelId
        let viewCount = itemResource.viewCount
        
        guard let channelIndex = channels.firstIndex(where: { $0.id == channelId }) else { return }
        guard let playlists = channels[channelIndex].playlists else { return }
        guard let playlistIndex = playlists.firstIndex(where: { $0.id == playlistId }) else { return }
        guard let playlistItems = channels[channelIndex].playlists?[playlistIndex].playlistItems else { return }
        guard let playlistItemIndex = playlistItems.firstIndex(where: { $0.id == playlistItemId }) else { return }
        channels[channelIndex].playlists?[playlistIndex].playlistItems?[playlistItemIndex].snippet.viewCount = viewCount
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
        return channels[index]
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
