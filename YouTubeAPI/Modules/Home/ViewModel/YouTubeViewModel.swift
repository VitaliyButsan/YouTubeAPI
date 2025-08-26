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
    
    private(set) var sections = BehaviorRelay(value: [ResourceSection]())
    
    private var pagesTimerDisposable: Disposable?
    private var channels = [Channel]()
    
    let isLoadedData = BehaviorRelay(value: false)
    let errorSubject = PublishRelay<String>()
    let pagesCounter = BehaviorRelay(value: 0)
    
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
        youTubeService = service
        disposeBag = DisposeBag()
    }
    
    // MARK: - Public methods
    
    func startTimer() {
        pagesTimerDisposable = Observable<Int>
            .interval(.seconds(5), scheduler: MainScheduler.instance)
            .bind(to: pagesCounter)
    }
    
    func stopTimer() {
        pagesTimerDisposable = nil
        pagesCounter.accept(0)
    }
    
    func getSectionTitle(by sectionIndex: Int) -> String {
        if (sectionIndex < 0) || (sectionIndex > sections.value.count - 1) {
            return ""
        }
        let section = sections.value[sectionIndex]
        let sectionTitle = section.model
        return sectionTitle
    }
    
    func updateData(for channelIndex: Int) {
        let sections = createSections(for: channelIndex)
        self.sections.accept(sections)
    }
    
    func getChannels() {
        zipChannels()
            .subscribe { channels in
                self.channels = channels
                let sections = self.createSections(for: 0)
                self.sections.accept(sections)
                self.isLoadedData.accept(true)
            } onFailure: { error in
                self.errorSubject.accept(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
	
	// MARK: - Private methods
    
    private func zipChannels() -> Single<[Channel]> {
        Observable.from(channelsIDs)
            .concatMap { id in
                self.populateChannel(by: id)
            }
            .toArray()
    }
    
    private func populateChannel(by channelId: String) -> Observable<Channel> {
        Observable<Channel>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            return self.getChannel(by: channelId)
                .flatMap { self.addPlaylists(to: $0) }
                .flatMap { self.addPlaylistsItems(to: $0) }
                .flatMap { self.addPlaylistsItemsViewCount(to: $0) }
                .subscribe(
                    onNext: { channel in
                        observer.onNext(channel)
                    },
                    onError: { error in
                        observer.onError(error)
                    },
                    onCompleted: {
                        observer.onCompleted()
                    }
                )
        }
    }
    
    private func getChannel(by channelId: String) -> Observable<Channel> {
        Observable<Channel>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            return self.youTubeService.getChannels(by: channelId)
                .subscribe(onSuccess: { channels in
                    if let channel = channels.first {
                        observer.onNext(channel)
                    }
                    observer.onCompleted()
                }, onFailure: { error in
                    observer.onError(error)
                })
        }
    }
    
	private func addPlaylists(to channel: Channel) -> Observable<Channel> {
        Observable<Channel>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            return self.youTubeService.getPlaylists(by: channel.id)
                .subscribe(onSuccess: { playlists in
                    var tempChannel = channel
                    tempChannel.playlists = playlists
                    observer.onNext(tempChannel)
                    observer.onCompleted()
                }, onFailure: { error in
                    observer.onError(error)
                })
        }
    }
    
    private func addPlaylistsItems(to channel: Channel) -> Observable<Channel> {
        guard let playlists = channel.playlists, !playlists.isEmpty else {
            return .just(channel)
        }
        return self.zipPlaylistsItems(by: playlists)
            .map { playlists in
                var tempChannel = channel
                tempChannel.playlists = playlists
                return tempChannel
            }
    }
    
    private func zipPlaylistsItems(by playlists: [Playlist]) -> Observable<[Playlist]> {
        if playlists.isEmpty {
            return .just([])
        }
        return Observable.zip(
            playlists.map { self.addPlaylistItems(to: $0) }
        )
    }
    
	private func addPlaylistItems(to playlist: Playlist) -> Observable<Playlist> {
        Observable<Playlist>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            return self.youTubeService.getPlaylistItems(by: playlist.id)
                .subscribe(onSuccess: { playlistItems in
                    var tempPlaylist = playlist
                    tempPlaylist.playlistItems = playlistItems
                    observer.onNext(tempPlaylist)
                    observer.onCompleted()
                }, onFailure: { error in
                    observer.onError(error)
                })
        }
    }
    
    private func addPlaylistsItemsViewCount(to channel: Channel) -> Observable<Channel> {
        let playlists = channel.playlists ?? []
        if playlists.isEmpty { return .just(channel) }

        return self.zipPlaylists(with: playlists)
            .map { playlists in
                var tempChannel = channel
                tempChannel.playlists = playlists
                return tempChannel
            }
    }
    
    private func zipPlaylists(with playlists: [Playlist]) -> Observable<[Playlist]> {
        if playlists.isEmpty { return .just([]) }
        return Observable.zip(
            playlists.map { self.addPlaylistItemsViewsCount(by: $0) }
        )
    }
    
	private func addPlaylistItemsViewsCount(by playlist: Playlist) -> Observable<Playlist> {
        Observable<Playlist>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            return self.zipPlaylistItemsViewCount(by: playlist)
                .subscribe(onNext: { playlistItem in
                    var tempPlaylist = playlist
                    tempPlaylist.playlistItems = playlistItem
                    observer.onNext(tempPlaylist)
                    observer.onCompleted()
                }, onError: { error in
                    observer.onError(error)
                })
        }
    }
    
    private func zipPlaylistItemsViewCount(by playlist: Playlist) -> Observable<[PlaylistItem]> {
        let items = playlist.playlistItems ?? []
        if items.isEmpty { return .just([]) }
        return Observable.zip(items.map { self.addPlaylistItemViewCount(by: $0) })
    }
    
	private func addPlaylistItemViewCount(by playlistItem: PlaylistItem) -> Observable<PlaylistItem> {
        Observable<PlaylistItem>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            return self.addViewCount(to: playlistItem)
                .subscribe { playlistItem in
                    observer.onNext(playlistItem)
                    observer.onCompleted()
                } onError: { error in
                    observer.onError(error)
                }
        }
    }
    
	private func addViewCount(to playlistItem: PlaylistItem) -> Observable<PlaylistItem> {
        Observable<PlaylistItem>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            let videoId = playlistItem.snippet.resourceId.videoId
            
            return self.youTubeService.getVideos(by: videoId)
                .subscribe(onSuccess: { videos in
                    var tempPlaylistItem = playlistItem
                    if let newVideo = videos.first {
                        tempPlaylistItem.snippet.viewCount = newVideo.statistics.viewCount
                    }
                    observer.onNext(tempPlaylistItem)
                    observer.onCompleted()
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
        if index < 0 || index > channels.count - 1 {
            return nil
        }
        return channels[index]
    }
}
