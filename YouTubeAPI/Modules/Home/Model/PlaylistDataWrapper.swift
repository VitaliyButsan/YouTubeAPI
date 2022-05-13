//
//  PlaylistDataWrapper.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import RxCocoa
import RxDataSources

struct PlaylistDataWrapper: Decodable {
    let items: [Playlist]
} 

struct Playlist: Decodable {
    let id: String
    let snippet: Snippet
    var playlistItems: [PlaylistItem]?
    
    struct Snippet: Decodable {
        let title: String
    }
}

// MARK: - dataSourcePlaylistItems

extension Playlist {
    typealias Section = SectionModel<String, PlaylistItem>

    var dataSourcePlaylistItems: BehaviorRelay<[Section]> {
        var newPlaylistItems: [Section] = []
        guard let playlistItems = playlistItems else {
            return .init(value: [])
        }
        for playlist in playlistItems {
            let title = playlist.snippet.title
            let items = playlistItems
            let newPlaylist = SectionModel(model: title, items: items)
            newPlaylistItems.append(newPlaylist)
        }
        return BehaviorRelay(value: newPlaylistItems)
    }
}
