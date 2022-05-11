//
//  PlaylistDataWrapper.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import Foundation

struct PlaylistDataWrapper: Decodable {
    let items: [PlaylistItem]
}

struct PlaylistItem: Decodable {
    let snippet: Snippet
    
    struct Snippet: Decodable {
        let title: String
    }
}
