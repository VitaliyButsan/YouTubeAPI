//
//  PlaylistItemsDataWrapper.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import Foundation

struct PlaylistItemsDataWrapper: Decodable {
    let items: [PlaylistItemsItem]
}

struct PlaylistItemsItem: Decodable {
    let snippet: Snippet
    
    struct Snippet: Decodable {
        let title: String
        let resourceId: Resource
        
        struct Resource: Decodable {
            let videoId: String
        }
    }
}
