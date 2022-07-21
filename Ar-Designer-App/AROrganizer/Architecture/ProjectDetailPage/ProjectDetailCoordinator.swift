//
//  ProjectDetailCoordinator.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/4/22.
//

import UIKit

final class ProjectDetailCoordinator: ContainerCoordinator, CoordinatorProtocol {
    // MARK: - Properties
    private let presenter: UINavigationController
    private let controller: ProjectDetailViewController
    private let viewModel: ProjectDetailViewModel
    
    // MARK: - Lifecycle
    init(presenter: UINavigationController, project: Project) {
        self.presenter = presenter
        self.viewModel = ProjectDetailViewModel(project: project)
        self.controller = ProjectDetailViewController(viewModel: viewModel)
    }
    
    func start(animated: Bool = true) {
        viewModel.delegate = self
        presenter.pushViewController(controller, animated: true)
    }
}

// MARK: - ProjectDetailViewModelOutputProtocol
extension ProjectDetailCoordinator: ProjectDetailViewModelOutputProtocol {
    func didUpdateProject(_ project: Project) {
        controller.refreshUI()
    }
    
    func didOpenProject(_ project: Project) {
        let coordinator = ARProjectCoordinator(presenter: presenter, project: project)
        coordinator.start(animated: true)
        coordinator.delegate = self
        self.nextCoordinator = coordinator
    }
    
    func didFinishFlow() {
        presenter.popViewController(animated: true)
    }
    
    func didError(_ error: ServerError) {
        let message = error.description.isEmpty ? "Something went wrong" : error.description
        controller.showErrorMessage(message)
    }
}

// MARK: - ARProjectCoordinatorDelegate
extension ProjectDetailCoordinator: ARProjectCoordinatorDelegate {
    
}
