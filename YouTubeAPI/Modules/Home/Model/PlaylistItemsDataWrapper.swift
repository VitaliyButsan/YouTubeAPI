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
        let thumbnails: Thumbnail
        
        struct Resource: Decodable {
            let videoId: String
        }
        
        struct Thumbnail: Decodable {
            let `default`, medium, high: Info
            
            struct Info: Decodable {
                let url: String
            }
        }
    }
}

// MARK: - Equatable

extension PlaylistItem: Equatable {
    
    static func == (lhs: PlaylistItem, rhs: PlaylistItem) -> Bool {
        return lhs.id == rhs.id
    }
    
}
