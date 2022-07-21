//
//  ProfileCoordinator.swift
//  AROrganizer
//
//  Created by Yurii Goroshenko on 6/9/22.
//

import UIKit

final class ProfileCoordinator: CoordinatorProtocol {
    // MARK: - Properties
    private let presenter: UINavigationController
    private let controller: ProfileViewController
    private let viewModel: ProfileViewModel
    
    // MARK: - Lifecycle
    init(presenter: UINavigationController) {
        self.presenter = presenter
        self.viewModel = ProfileViewModel()
        self.controller = ProfileViewController(viewModel: viewModel)
    }
    
    func start(animated: Bool = true) {
        viewModel.delegate = self
        presenter.pushViewController(controller, animated: true)
    }
}

// MARK: - ProfileViewModelOutputProtocol
extension ProfileCoordinator: ProfileViewModelOutputProtocol {
    func didLogoutPressed() {
        AppCoordinator.logout()
    }
    
    func didError(_ error: ServerError) {
        let message = error.description.isEmpty ? "Something went wrong" : error.description
        controller.showErrorMessage(message)
    }
}
