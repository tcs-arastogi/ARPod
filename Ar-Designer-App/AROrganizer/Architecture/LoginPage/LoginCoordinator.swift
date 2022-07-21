//
//  LoginCoordinator.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/2/22.
//

import UIKit

protocol LoginCoordinatorProtocol: AnyObject {
    func didFinishLoginFlow()
}

final class LoginCoordinator: CoordinatorProtocol {
    // MARK: - Properties
    private let window: UIWindow
    private let controller: LoginViewController
    private let viewModel: LoginViewModel
    weak var delegate: LoginCoordinatorProtocol?
    
    // MARK: - Lifecycle
    init(window: UIWindow) {
        self.window = window
        self.viewModel = LoginViewModel()
        self.controller = LoginViewController(viewModel: viewModel)
    }
    
    func start(animated: Bool = true) {
        viewModel.delegate = self
        
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
}

// MARK: - LoginViewModelOutputProtocol
extension LoginCoordinator: LoginViewModelOutputProtocol {
    func didFinish() {
        controller.refreshState()
        delegate?.didFinishLoginFlow()
    }
    
    func didError(_ error: ServerError) {
        let message = error.description.isEmpty ? "Something went wrong" : error.description
        controller.showErrorMessage(message)
    }
}
