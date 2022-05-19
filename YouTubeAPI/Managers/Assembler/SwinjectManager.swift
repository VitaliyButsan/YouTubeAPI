//
//  SwinjectManager.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import Swinject

final class SwinjectManager {
    
    let assembler = Assembler([
        YouTubeServiceAssembly(),
        YouTubeViewModelAssembly(),
        YouTubeMainViewUIFactoryAssembly(),
        YouTubeMainViewAssembly(),
        YouTubeViewControllerAssembly(),
        
        PlayerViewModelAssembly(),
        PlayerViewAssembly(),
    ])
    
    var mainVC: UIViewController? {
        return assembler.resolver.resolve(YouTubeViewController.self)
    }
}
