//
//  ChannelsDataWrapper.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import RxDataSources

struct ChannelsDataWrapper: Decodable {
    let items: [Channel]
}

struct Channel: Decodable {
    let id: String
    let statistics: Statistics
    let brandingSettings: Settings
    var playlists: [Playlist]?
    
    struct Statistics: Decodable {
        let subscriberCount: String
    }
    
    struct Settings: Decodable {
        let channel: Setting
        
        struct Setting: Decodable {
            let title: String
        }
    }
}

extension Channel {
    typealias Section = SectionModel<String, Playlist>

    var dataSourcePlaylists: [Section] {
        var newPlaylists: [Section] = []
        guard let playlists = playlists else { return [] }
        
        for playlist in playlists {
            let title = playlist.snippet.title
            let items = playlists
            let newPlaylist = SectionModel(model: title, items: items)
            newPlaylists.append(newPlaylist)
        }
        return newPlaylists
    }
}
