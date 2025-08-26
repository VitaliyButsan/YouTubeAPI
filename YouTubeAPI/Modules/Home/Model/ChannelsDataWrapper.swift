//
//  ChannelsDataWrapper.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import RxDataSources

struct ChannelsDataWrapper: Decodable {
    let items: [Channel]
    
    private enum CodingKeys: String, CodingKey { case items }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decodeIfPresent([Channel].self, forKey: .items) ?? []
    }
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
        let image: Image
        
        struct Setting: Decodable {
            let title: String
        }
        
        struct Image: Decodable {
            let bannerExternalUrl: String
        }
    }
}
