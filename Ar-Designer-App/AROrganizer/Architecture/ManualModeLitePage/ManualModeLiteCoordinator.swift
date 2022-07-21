//
//  ManualModeLiteCoordinator.swift
//  AROrganizer
//
//  Created by Valeriy Jefimov on 7/5/22.
//

import UIKit

protocol ManualModeLiteProtocol: AnyObject {
    func didFinishFlow()
}

final class ManualModeLiteCoordinator: ContainerCoordinator, CoordinatorProtocol {
    // MARK: - Properties
    private let presenter: UINavigationController
    private let controller: ManualModeLiteController
    private let viewModel: ManualModeLiteModel
    weak var delegate: ManualModeLiteProtocol?
    
    // MARK: - Lifecycle
    init(presenter: UINavigationController, project: Project?) {
        self.presenter = presenter
        self.viewModel = ManualModeLiteModel(project: project)
        self.controller = ManualModeLiteController(viewModel: viewModel)
        super.init()
    }
    
    func start(animated: Bool = true) {
        viewModel.delegate = self
        
        viewModel.delegate = self
        presenter.pushViewController(controller, animated: animated)
    }
}

// MARK: - ManualModeLiteModelOutputProtocol
extension ManualModeLiteCoordinator: ManualModeLiteModelOutputProtocol {
    func didFinish() {
        delegate?.didFinishFlow()
    }
    
    func didError(_ error: ServerError) {
        
    }
}

