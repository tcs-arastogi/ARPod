//
//  SplashCoordinator.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/4/22.
//

import UIKit

protocol SplashCoordinatorProtocol: AnyObject {
    func didFinish(isLoggedIn: Bool)
}

final class SplashCoordinator: CoordinatorProtocol {
    private let window: UIWindow
    private let controller: SplashViewController
    private let viewModel: SplashViewModel
    weak var delegate: SplashCoordinatorProtocol?
    
    // MARK: - Lifecycle
    init(window: UIWindow) {
        self.window = window
        self.viewModel = SplashViewModel()
        self.controller = SplashViewController(viewModel: viewModel)
    }
    
    func start(animated: Bool = true) {
        viewModel.delegate = self
        
        window.rootViewController = controller
        window.makeKeyAndVisible()
        
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .light
        }
    }
}

// MARK: - SplashViewModelOutputProtocol
extension SplashCoordinator: SplashViewModelOutputProtocol {
    func didFinish() {
        delegate?.didFinish(isLoggedIn: UserDefaults.isLoggedIn ?? false)
    }
    
    func didError(_ error: ServerError) {
        let message = error.description.isEmpty ? "Something went wrong" : error.description
        controller.showErrorMessage(message)
    }
}
