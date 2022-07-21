//
//  AppCoordinator.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/3/22.
//

import UIKit

final class AppCoordinator: ContainerCoordinator, CoordinatorProtocol {
    // MARK: - Properties
    private let window: UIWindow
    
    // MARK: - Lifecycle
    init(window: UIWindow) {
        self.window = window
    }
    
    func start(animated: Bool) {
        showSpashFlow()
    }
    
    static func logout() {
        guard let sceneDelegate = UIApplication.shared.windows.first?.windowScene?.delegate as? SceneDelegate else { return }
        AuthRepository().logout()
        sceneDelegate.coordinator?.start(animated: false)
    }
}

// MARK: - SplashCoordinatorProtocol
extension AppCoordinator: SplashCoordinatorProtocol {
    func showSpashFlow(animated: Bool = true) {
        let coordinator = SplashCoordinator(window: window)
        coordinator.delegate = self
        coordinator.start()
        self.nextCoordinator = coordinator
    }
    
    func didFinish(isLoggedIn: Bool) {
        if isLoggedIn {
            showProjectListFlow()
        } else {
            showLoginFlow()
        }
    }
}

// MARK: - LoginCoordinatorProtocol
extension AppCoordinator: LoginCoordinatorProtocol {
    func showLoginFlow(animated: Bool = true) {
        let coordinator = LoginCoordinator(window: window)
        coordinator.delegate = self
        coordinator.start()
        self.nextCoordinator = coordinator
    }
    
    func didFinishLoginFlow() {
        showProjectListFlow()
    }
}

// MARK: - ProjectListCoordinator
extension AppCoordinator {
    func showProjectListFlow(animated: Bool = true) {
        let coordinator = ProjectListCoordinator(window: window)
        coordinator.start()
        self.nextCoordinator = coordinator
    }
}
