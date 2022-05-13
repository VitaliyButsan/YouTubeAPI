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
        case playlist(playlist: PlaylistItem)
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
        let playlist = PlaylistItem(id: "111", snippet: PlaylistItem.Snippet(title: "playlist name"))
        return CellModel(title: "Playlist", typeOfCell: .playlist(playlist: playlist))
    }
}

