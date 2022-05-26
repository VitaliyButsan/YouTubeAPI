//
//  YouTubeViewModel.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import RxCocoa
import RxDataSources
import RxSwift

typealias ResourceSection = SectionModel<String, CellModel>

class YouTubeViewModel {
    
    // MARK: - Properties
    
    private(set) var dataSource = BehaviorRelay(value: [ResourceSection]())
    
    private var pagesTimerDisposable: Disposable?
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
    }
    
    // MARK: - Public methods
    
    func startTimer() {
        pagesTimerDisposable = Observable<Int>
            .interval(.seconds(5), scheduler: MainScheduler.instance)
            .bind(to: timerCounter)
    }
    
    func stopTimer() {
        pagesTimerDisposable = nil
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
        zipChannels()
            .subscribe { channels in
                self.channels = channels
                let sections = self.createSections(for: 0)
                self.dataSource.accept(sections)
                self.isLoadedData.accept(true)
            } onError: { error in
                self.errorSubject.accept(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    func zipChannels() -> Observable<[Channel]> {
        Observable.zip(
            channelsIDs.map { self.populateChannel(by: $0) }
        )
    }
    
    func populateChannel(by channelId: String) -> Observable<Channel> {
        Observable<Channel>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            return self.getChannel(by: channelId)
                .flatMap { self.addPlaylists(to: $0) }
                .flatMap { self.addPlaylistsItems(to: $0) }
                .flatMap { self.addPlaylistsItemsViewCount(to: $0) }
                .subscribe { channel in
                    observer.onNext(channel)
                } onError: { error in
                    observer.onError(error)
                }
        }
    }
    
    func getChannel(by channelId: String) -> Observable<Channel> {
        Observable<Channel>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            return self.youTubeService.getChannels(by: channelId)
                .subscribe(onSuccess: { channels in
                    guard let newChannel = channels.first else { return }
                    observer.onNext(newChannel)
                }, onFailure: { error in
                    observer.onError(error)
                })
        }
    }
    
    func addPlaylists(to channel: Channel) -> Observable<Channel> {
        Observable<Channel>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            return self.youTubeService.getPlaylists(by: channel.id)
                .subscribe(onSuccess: { playlists in
                    var tempChannel = channel
                    tempChannel.playlists = playlists
                    observer.onNext(tempChannel)
                }, onFailure: { error in
                    observer.onError(error)
                })
        }
    }
    
    func addPlaylistsItems(to channel: Channel) -> Observable<Channel> {
        Observable<Channel>.create { [weak self] observer in
            guard let self = self, let playlists = channel.playlists else {
                return Disposables.create()
            }
            return self.zipPlaylistsItems(by: playlists)
                .subscribe { playlists in
                    var tempChannel = channel
                    tempChannel.playlists = playlists
                    observer.onNext(tempChannel)
                } onError: { error in
                    observer.onError(error)
                }
        }
    }
    
    func zipPlaylistsItems(by playlists: [Playlist]) -> Observable<[Playlist]> {
        Observable.zip(
            playlists.map { playlist in
                self.addPlaylistItems(to: playlist)
            }
        )
    }
    
    func addPlaylistItems(to playlist: Playlist) -> Observable<Playlist> {
        Observable<Playlist>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            return self.youTubeService.getPlaylistItems(by: playlist.id)
                .subscribe(onSuccess: { playlistItems in
                    var tempPlaylist = playlist
                    tempPlaylist.playlistItems = playlistItems
                    observer.onNext(tempPlaylist)
                }, onFailure: { error in
                    observer.onError(error)
                })
        }
    }
    
    func addPlaylistsItemsViewCount(to channel: Channel) -> Observable<Channel> {
        Observable<Channel>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            return self.zipPlaylists(with: channel.playlists ?? [])
                .subscribe { playlists in
                    var tempChannel = channel
                    tempChannel.playlists = playlists
                    observer.onNext(tempChannel)
                } onError: { error in
                    observer.onError(error)
                }
        }
    }
    
    func zipPlaylists(with playlists: [Playlist]) -> Observable<[Playlist]> {
        Observable.zip(
            playlists.map { playlist in
                self.addPlaylistItemsViewsCount(by: playlist)
            }
        )
    }
    
    func addPlaylistItemsViewsCount(by playlist: Playlist) -> Observable<Playlist> {
        Observable<Playlist>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            return self.zipPlaylistItemsViewCount(by: playlist)
                .subscribe { playlistItem in
                    var tempPlaylist = playlist
                    tempPlaylist.playlistItems = playlistItem
                    observer.onNext(tempPlaylist)
                } onError: { error in
                    observer.onError(error)
                }
        }
    }
    
    func zipPlaylistItemsViewCount(by playlist: Playlist) -> Observable<[PlaylistItem]> {
        guard let playlistItems = playlist.playlistItems else { return .just([]) }
        return Observable.zip(
            playlistItems.map { playlistItem in
                self.addPlaylistItemViewCount(by: playlistItem)
            }
        )
    }
    
    func addPlaylistItemViewCount(by playlistItem: PlaylistItem) -> Observable<PlaylistItem> {
        Observable<PlaylistItem>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            return self.addViewCount(to: playlistItem)
                .subscribe { playlistItem in
                    observer.onNext(playlistItem)
                } onError: { error in
                    observer.onError(error)
                }
        }
    }
    
    func addViewCount(to playlistItem: PlaylistItem) -> Observable<PlaylistItem> {
        Observable<PlaylistItem>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            let videoId = playlistItem.snippet.resourceId.videoId
            
            return self.youTubeService.getVideos(by: videoId)
                .subscribe(onSuccess: { videos in
                    guard let newVideo = videos.first else {
                        observer.onNext(playlistItem)
                        return
                    }
                    var tempPlaylistItem = playlistItem
                    let viewCount = newVideo.statistics.viewCount
                    tempPlaylistItem.snippet.viewCount = viewCount
                    observer.onNext(tempPlaylistItem)
                }, onFailure: { error in
                    observer.onError(error)
                })
        }
    }
    
    private func createSections(for channelIndex: Int) -> [ResourceSection] {
        guard let channel = getChannel(by: channelIndex) else { return [] }
        var sections: [ResourceSection] = []
        
        // add first fixed section
        let cell = CellModel(title: "", typeOfCell: .pageControl(model: channels))
        let section = ResourceSection(model: "", items: [cell])
        sections.append(section)
        
        // add sections depends of playlists count
        for playlist in channel.playlists ?? [] {
            
            let rxPlaylist = RxPlaylist(playlist: playlist)
            let cell = CellModel(title: "", typeOfCell: .playlist(model: rxPlaylist))
            let section = ResourceSection(model: playlist.snippet.title, items: [cell])
            sections.append(section)
        }
        return sections
    }
    
    private func getChannel(by index: Int) -> Channel? {
        if index < 0, index > channels.count - 1 {
            return nil
        }
        return channels[index]
    }
}
