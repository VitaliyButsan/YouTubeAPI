//
//  YouTubeService.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import Moya
import RxSwift

class YouTubeService {
    
    private let provider = MoyaProvider<YouTubeAPI>()
    
    // MARK: - Public methods
    
    func getChannels(by id: String) -> Single<[Channel]> {
        provider.rx
            .request(.getChannels(id: id))
            .catch { error in .error(error) }
            .map(ChannelsDataWrapper.self)
            .map(\.items)
    }
    
    func getPlaylists(by id: String) -> Single<[Playlist]> {
        provider.rx
            .request(.getPlaylists(channelId: id, max: 2))
            .catch { error in .error(error) }
            .map(PlaylistDataWrapper.self)
            .map(\.items)
    }
    
    func getPlaylistItems(by id: String) -> Single<[PlaylistItem]> {
        provider.rx
            .request(.getPlaylistItems(playlistId: id, max: 10))
            .catch { error in .error(error) }
            .map(PlaylistItemsDataWrapper.self)
            .map(\.items)
    }
    
    func getVideos(by id: String) -> Single<[Video]> {
        provider.rx
            .request(.getVideos(videoId: id))
            .catch { error in .error(error) }
            .map(VideoDataWrapper.self)
            .map(\.items)
    }
}
