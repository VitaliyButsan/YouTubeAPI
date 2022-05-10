//
//  YouTubeService.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import Moya
import RxSwift

class YouTubeService {
    
    static let instance = YouTubeService()
    private let provider = MoyaProvider<YouTubeAPI>()
    
    private init() { }
    
//    func getChannels(by id: String) -> Single<[Category]> {
//        provider.rx
//            .request(.getChannels(id: id))
//            .filterSuccessfulStatusAndRedirectCodes()
//            .map(CategoriesWrapper.self)
//            .map(\.drinks)
//    }
}
