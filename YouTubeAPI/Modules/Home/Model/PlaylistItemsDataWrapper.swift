//
//  PlaylistItemsDataWrapper.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import Foundation

struct PlaylistItemsDataWrapper: Decodable {
    let items: [PlaylistItem]
}

struct PlaylistItem: Decodable {
    let id: String
    var snippet: Snippet
    
    struct Snippet: Decodable {
        let title: String
        let resourceId: Resource
        var viewCount: String?
        
        struct Resource: Decodable {
            let videoId: String
        }
    }
}
