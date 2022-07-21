//
//  ProjectListCoordinator.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/3/22.
//

import UIKit

final class ProjectListCoordinator: ContainerCoordinator, CoordinatorProtocol {
    // MARK: - Properties
    private let window: UIWindow
    private let viewModel: ProjectListViewModel
    private let controller: ProjectListViewController
    
    // MARK: - Lifecycle
    init(window: UIWindow) {
        self.window = window
        self.viewModel = ProjectListViewModel()
        self.controller = ProjectListViewController(viewModel: viewModel)
    }
    
    func start(animated: Bool = true) {
        viewModel.delegate = self
        
        window.rootViewController = UINavigationController(rootViewController: controller)
        window.makeKeyAndVisible()
        
        UserDefaults.isLoggedIn = true
    }
}

// MARK: - Private
private extension ProjectListCoordinator {
    func showController() {
        controller.reloadProjects()
    }
}

// MARK: - ProjectListViewModelOutputProtocol
extension ProjectListCoordinator: ProjectListViewModelOutputProtocol {
    func didProfilePressed() {
        guard let navigation = window.rootViewController as? UINavigationController else { return }
        let coordinator = ProfileCoordinator(presenter: navigation)
        coordinator.start()
        
        self.nextCoordinator = coordinator
    }
    
    func didSelectProject(_ project: Project) {
        guard let navigation = window.rootViewController as? UINavigationController else { return }
        let coordinator = ProjectDetailCoordinator(presenter: navigation, project: project)
        coordinator.start()
        
        self.nextCoordinator = coordinator
    }
    
    func didCreateProjectPressed(type: ProjectType) {
        guard let navigation = window.rootViewController as? UINavigationController else { return }
        
        switch type {
        case .ar:
            let coordinator = ARProjectCoordinator(presenter: navigation, project: nil)
            coordinator.start(animated: true)
            self.nextCoordinator = coordinator
        case .manual:
            // TODO: - open manual mode
            return
        case .manualLite:
            let coordinator = ManualModeLiteCoordinator(presenter: navigation, project: nil)
            coordinator.start(animated: true)
            self.nextCoordinator = coordinator
            // TODO: - open manual lite mode
            return
        }
    }
    
    func didLoadFinish() {
        showController()
    }
    
    func didError(_ error: ServerError) {
        let message = error.description.isEmpty ? "Something went wrong" : error.description
        controller.showErrorMessage(message)
    }
}
