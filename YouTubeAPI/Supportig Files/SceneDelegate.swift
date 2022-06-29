//
//  SceneDelegate.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
	
    func scene(_ scene: UIScene,
			   willConnectTo session: UISceneSession,
			   options connectionOptions: UIScene.ConnectionOptions) {
        
		setupMainWindow(by: scene)
    }
	
	private func setupMainWindow(by scene: UIScene) {
		guard let windowScene = (scene as? UIWindowScene) else { fatalError() }
		let window = UIWindow(windowScene: windowScene)
		window.windowScene = windowScene

		guard let mainVC = SwinjectManager().mainVC else { fatalError() }
		let navigationController = UINavigationController(rootViewController: mainVC)
		window.rootViewController = navigationController
		
		self.window = window
		window.makeKeyAndVisible()
	}
	
}

