//
//  PlaylistDataWrapper.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import Foundation

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
