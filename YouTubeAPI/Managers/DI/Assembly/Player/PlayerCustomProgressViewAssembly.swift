//
//  PlayerCustomProgressViewAssembly.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 19.05.2022.
//

import Swinject

final class PlayerCustomProgressViewAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(CustomProgressView.self) { r in
            let uiFactory = r.resolve(UIFactory.self)
            let viewModel = r.resolve(PlayerViewModel.self)
            let progressView = CustomProgressView(viewModel: viewModel, uiFactory: uiFactory)
            return progressView
        }
    }
}
