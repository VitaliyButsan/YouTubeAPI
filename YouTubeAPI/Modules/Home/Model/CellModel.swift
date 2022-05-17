//
//  CellModel.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 13.05.2022.
//

import Foundation
import RxRelay
import RxDataSources

struct CellModel {
    
    enum CellType {
        case pageControl(channels: [Channel])
        case playlist(playlist: RxPlaylist)
    }
    
    let title: String
    let typeOfCell: CellType
}

struct MockCell {
    
    func channelsMock(_ count: Int) -> CellModel {
        var channels: [Channel] = []
        for _ in 0..<count {
            let channel = Channel(id: "", statistics: .init(subscriberCount: ""), brandingSettings: .init(channel: .init(title: ""), image: .init(bannerExternalUrl: "")), playlists: [])
            channels.append(channel)
        }
        let cell = CellModel(title: "", typeOfCell: .pageControl(channels: channels))
        return cell
    }
    
    func playlistMock(_ count: Int) -> CellModel {
        var playlistItems: [PlaylistItem] = []
        
        for x in 0..<count {
            let resourceId = PlaylistItem.Snippet.Resource.init(videoId: "23423423")
            let snippet = PlaylistItem.Snippet.init(title: "title", resourceId: resourceId, viewCount: "999")
            let playlistItem = PlaylistItem(id: "\(x)", snippet: snippet)
            playlistItems.append(playlistItem)
        }
        
        let section = PlaylistItemsSection(model: "", items: playlistItems)
        let playlistItemsSections = BehaviorRelay(value: [section])
        
        let playlistSnippet = RxPlaylist.Snippet(title: "playlist name")
        let playlist = RxPlaylist(id: "111", snippet: playlistSnippet, playlistItems: playlistItemsSections)
        
        return CellModel(title: "Playlist", typeOfCell: .playlist(playlist: playlist))
    }
}
