//
//  PlayerControlPanelViewAssembly.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 19.05.2022.
//

import Swinject

final class PlayerControlPanelViewAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(PlayerControlPanelView.self) { r in
            let viewModel = r.resolve(PlayerViewModel.self)
            let uiFactory = r.resolve(UIFactory.self)
            let progressView = r.resolve(CustomProgressView.self)
            let sliderView = r.resolve(CustomSliderView.self)
            let controlPanelView = PlayerControlPanelView(viewModel: viewModel, uiFactory: uiFactory, progressView: progressView, sliderView: sliderView)
            return controlPanelView
        }
    }
}

