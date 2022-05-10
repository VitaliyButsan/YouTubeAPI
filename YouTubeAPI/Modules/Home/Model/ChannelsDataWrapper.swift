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
//    let statistics: Statistics
    let settings: Settings
    
    struct Statistics: Decodable {
        let subscriberCount: Int
    }
    
    struct Settings: Decodable {
        let channel: Setting
        
        struct Setting: Decodable {
            let title: String
        }
    }
}
