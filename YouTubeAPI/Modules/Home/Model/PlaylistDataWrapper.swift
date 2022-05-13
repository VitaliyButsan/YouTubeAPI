//
//  PlaylistDataWrapper.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import RxCocoa
import RxDataSources

typealias PlaylistItemsSection = SectionModel<String, PlaylistItem>

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

struct RxPlaylist {
    let id: String
    let snippet: Snippet
    var playlistItems: BehaviorRelay<[PlaylistItemsSection]>?
    
    struct Snippet {
        let title: String
    }
}
