//
//  YouTubeAPI.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import Moya

enum YouTubeAPI {
    case getChannels(id: String)
    case getPlaylists(channelId: String, max: Int)
    case getPlaylistItems(playlistId: String, max: Int)
    case getVideos(videoId: String)
}

// MARK: - TargetType Protocol -

extension YouTubeAPI: TargetType {
    
    var baseURL: URL {
        URL(string: L10n.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getChannels:
            return "/channels"
        case .getPlaylists:
            return "/playlists"
        case .getPlaylistItems:
            return "/playlistItems"
        case .getVideos:
            return "/videos"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var params: [String : String] {
        switch self {
        case let .getChannels(id):
            return [
                "part" : L10n.channelsRequestParts,
                "key" : L10n.apiKey,
                "id" : "\(id)",
            ]
        case let .getPlaylists(id, max):
            return [
                "part" : L10n.playlistsRequestParts,
                "key" : L10n.apiKey,
                "channelId" : "\(id)",
                "maxResults" : "\(max)"
            ]
        case let .getPlaylistItems(id, max):
            return [
                "part" : L10n.playlistItemsRequestParts,
                "key" : L10n.apiKey,
                "playlistId" : "\(id)",
                "maxResults" : "\(max)"
            ]
        case let .getVideos(id):
            return [
                "part" : L10n.videosRequestParts,
                "key" : L10n.apiKey,
                "id" : "\(id)",
            ]
        }
    }
    
    var task: Task {
        switch self {
        case .getChannels, .getPlaylists, .getPlaylistItems, .getVideos:
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}

