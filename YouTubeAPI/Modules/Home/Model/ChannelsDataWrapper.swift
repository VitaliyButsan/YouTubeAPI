//
//  ChannelsDataWrapper.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import Foundation

struct ChannelsDataWrapper: Decodable {
    let items: [Channel]
}

struct Channel: Decodable {
    let statistics: Statistics
    let brandingSettings: Settings
    
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
