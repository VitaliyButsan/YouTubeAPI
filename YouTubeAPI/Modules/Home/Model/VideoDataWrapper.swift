//
//  VideoDataWrapper.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import Foundation

struct VideoDataWrapper: Decodable {
    let items: [Video]
}

struct Video: Decodable {
    let statistics: Statistics
    
    struct Statistics: Decodable {
        let viewCount: String
    }
}
