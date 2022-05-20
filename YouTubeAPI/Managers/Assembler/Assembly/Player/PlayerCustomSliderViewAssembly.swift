//
//  PlayerCustomSliderViewAssembly.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 20.05.2022.
//

import Swinject

final class PlayerCustomSliderViewAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(CustomSliderView.self) { r in
            let uiFactory = r.resolve(UIFactory.self)
            let viewModel = r.resolve(PlayerViewModel.self)
            let sliderView = CustomSliderView(viewModel: viewModel, uiFactory: uiFactory)
            return sliderView
        }
    }
}
