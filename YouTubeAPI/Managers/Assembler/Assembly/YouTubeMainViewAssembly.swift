//
//  YouTubeMainViewAssembly.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import Swinject

final class YouTubeMainViewAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(MainView.self) { r in
            let viewModel = r.resolve(YouTubeViewModel.self)
            let uiFactory = r.resolve(UIFactory.self)
            let view = MainView(viewModel: viewModel, uiFactory: uiFactory)
            return view
        }
    }
}
