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
        case pageControl(model: [Channel])
        case playlist(model: RxPlaylist)
    }
    
    let title: String
    let typeOfCell: CellType
}

struct MockCell {
    
    func channelsMock(_ count: Int) -> CellModel {
        let urls = [
            "https://i.ytimg.com/vi/5ww7JyxV1ds/default.jpg",
            "https://i.ytimg.com/vi/NsQBW809MeQ/default.jpg"
        ]
        
        var counter = urls.count
        
        if count > 0 {
            counter += (count * 2)
        }
        
        let playlist1 = Playlist(id: "PLPMTgVQ-QjJP_khz2zdxibqiurJrkwCos", snippet: .init(title: ""), playlistItems: [])
        let playlist2 = Playlist(id: "PLTU3J-plh1fAvqJDKepiDKduIeJ64IupT", snippet: .init(title: ""), playlistItems: [])
        
        var channels: [Channel] = []
        for index in 0..<urls.count {
            let channel = Channel(id: "", statistics: .init(subscriberCount: "7777777"), brandingSettings: .init(channel: .init(title: "Amazing Channel"), image: .init(bannerExternalUrl: urls[index])), playlists: [playlist1, playlist2])
            channels.append(channel)
        }
        let cell = CellModel(title: "", typeOfCell: .pageControl(model: channels))
        return cell
    }
    
    func playlistMock(_ count: Int) -> CellModel {
        var url = ""
        var playlistID = ""
        
        switch count {
        case 0:
            url = "https://i.ytimg.com/vi/5ww7JyxV1ds/default.jpg"
            playlistID = "PLPMTgVQ-QjJPE28AwAsMRACs99UyDqJXE"
        case 1:
            url = "https://i.ytimg.com/vi/NsQBW809MeQ/default.jpg"
            playlistID = "PLTU3J-plh1fAvqJDKepiDKduIeJ64IupT"
        default:
            break
        }
        
        var counter = 2
        
        if count > 0 {
            counter += (count * 2)
        }
        
        var playlistItems: [PlaylistItem] = []
        
        for x in 0..<counter {
            let resourceId = PlaylistItem.Snippet.Resource(videoId: "23423423")
            let url = PlaylistItem.Snippet.Thumbnail.Info(url: url)
            let thumbnails = PlaylistItem.Snippet.Thumbnail(default: url, medium: url, high: url)
            let snippet = PlaylistItem.Snippet(title: "title", resourceId: resourceId, viewCount: "9999999", thumbnails: thumbnails)
            let playlistItem = PlaylistItem(id: "\(x)", snippet: snippet)
            playlistItems.append(playlistItem)
        }
        
        let section = PlaylistItemsSection(model: "", items: playlistItems)
        let playlistItemsSections = BehaviorRelay(value: [section])
        
        let playlistSnippet = RxPlaylist.Snippet(title: "playlist name")
        let playlist = RxPlaylist(id: playlistID, snippet: playlistSnippet, playlistItems: playlistItemsSections)
        
        return CellModel(title: "Playlist", typeOfCell: .playlist(model: playlist))
    }
}
