//
//  YouTubeViewControllerAssembly.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import Swinject

final class YouTubeViewControllerAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(YouTubeViewController.self) { r in
            let viewModel = r.resolve(YouTubeViewModel.self)
            let viewController = YouTubeViewController(viewModel: viewModel)
            return viewController
        }
    }
}
