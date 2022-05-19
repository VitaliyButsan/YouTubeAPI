//
//  PlayerViewAssembly.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 19.05.2022.
//

import Swinject

final class PlayerViewAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(PlayerView.self) { r in
            let viewModel = r.resolve(PlayerViewModel.self)
            let uiFactory = r.resolve(UIFactory.self)
            let playerView = PlayerView(viewModel: viewModel, uiFactory: uiFactory)
            return playerView
        }
    }
}
