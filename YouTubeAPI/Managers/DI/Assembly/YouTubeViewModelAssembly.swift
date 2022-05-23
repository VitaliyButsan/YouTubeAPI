//
//  YouTubeViewModelAssembly.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import Swinject

final class YouTubeViewModelAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(YouTubeService.self) { _ in
            return YouTubeService()
        }
        .inObjectScope(.container)
        
        container.register(YouTubeViewModel.self) { r in
            let service = r.resolve(YouTubeService.self)
            let viewModel = YouTubeViewModel(service: service)
            return viewModel
        }
    }
}
