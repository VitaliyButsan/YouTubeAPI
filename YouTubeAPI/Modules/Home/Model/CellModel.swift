//
//  CellModel.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 13.05.2022.
//

import Foundation

struct CellModel {
    
    enum CellType {
        case pageControl(channels: [Channel])
        case playlist(playlist: Playlist)
    }
    
    let title: String
    let typeOfCell: CellType
}

struct MockCell {
    
    func channelsMock(_ count: Int) -> CellModel {
        var channels: [Channel] = []
        for _ in 0..<count {
            let channel = Channel(id: "", statistics: .init(subscriberCount: ""), brandingSettings: .init(channel: .init(title: "")), playlists: [])
            channels.append(channel)
        }
        let cell = CellModel(title: "", typeOfCell: .pageControl(channels: channels))
        return cell
    }
    
    var playlistMock: CellModel {
        var playlistItems: [PlaylistItem] = []
        for x in 0..<2 {
            let resourceId = PlaylistItem.Snippet.Resource.init(videoId: "23423423")
            let snippet = PlaylistItem.Snippet.init(title: "title", resourceId: resourceId, viewCount: "999")
            let playlistItem = PlaylistItem(id: "\(x)", snippet: snippet)
            playlistItems.append(playlistItem)
        }
        let playlistSnippet = Playlist.Snippet(title: "playlist name")
        let playlist = Playlist(id: "111", snippet: playlistSnippet, playlistItems: playlistItems)
        return CellModel(title: "Playlist", typeOfCell: .playlist(playlist: playlist))
    }
}
