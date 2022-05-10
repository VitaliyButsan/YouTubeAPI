//
//  YouTubeAPI.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import Moya

enum YouTubeAPI {
    case getChannels(id: String)
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
                "part" : L10n.requestChannelsParts,
                "key" : L10n.apiKey,
                "id" : "\(id)",
            ]
        }
    }
    
    var task: Task {
        switch self {
        case .getChannels:
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}

