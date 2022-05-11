//
//  YouTubeServiseAssembly.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import Swinject

final class YouTubeServiceAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(YouTubeService.self) { r in
            return YouTubeService.instance
        }
    }
}

