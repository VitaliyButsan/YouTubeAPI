//
//  YouTubeMainViewUIFactoryAssembly.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import Swinject

final class YouTubeMainViewUIFactoryAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(UIFactory.self) { r in
            return UIFactory()
        }
    }
}
