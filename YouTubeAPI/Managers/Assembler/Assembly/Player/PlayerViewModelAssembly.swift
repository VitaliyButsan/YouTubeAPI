//
//  PlayerViewModelAssembly.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 19.05.2022.
//

import Swinject

final class PlayerViewModelAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(PlayerViewModel.self) { r in
            return PlayerViewModel()
        }
    }
}
