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
        
        PlayerViewAssembly(),
        PlayerViewModelAssembly(),
        PlayerControlPanelViewAssembly(),
        PlayerCustomProgressViewAssembly(),
        PlayerCustomSliderViewAssembly(),
    ])
    
    var mainVC: UIViewController? {
        return assembler.resolver.resolve(YouTubeViewController.self)
    }
}
