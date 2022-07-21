//
//  SceneDelegate.swift
//  ARDesignerApp
//
//  Created by Andrii Ternovyi on 1/31/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator?
    
    // MARK: - Lifecicle
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        self.coordinator = AppCoordinator(window: window)
        coordinator?.start(animated: true)
    }
}
