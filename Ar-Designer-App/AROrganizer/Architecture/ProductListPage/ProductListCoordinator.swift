//
//  ProductListCoordinator.swift
//  AROrganizer
//
//  Created by Yurii Goroshenko on 6/10/22.
//

import UIKit
import OverlayContainer

protocol ProductListCoordinatorProtocol: AnyObject {
    func actionAddModel(_ model: VirtualObject, by product: Product)
}

final class ProductListCoordinator: CoordinatorProtocol {
    // MARK: - Properties
    private let presenter: OverlayContainerViewController
    private let controller: ProductListViewController
    private let viewModel: ProductListViewModel
    weak var delegate: ProductListCoordinatorProtocol?
    
    // MARK: - Lifecycle
    init(presenter: OverlayContainerViewController, project: Project, delegate: ProductListCoordinatorProtocol?) {
        self.presenter = presenter
        self.viewModel = ProductListViewModel(project: project)
        self.controller = ProductListViewController(viewModel: viewModel)
        
        self.delegate = delegate
    }
    
    func start(animated: Bool = true) {
        viewModel.delegate = self
        
        let navigation = UINavigationController(rootViewController: controller)
        presenter.present(overlay: navigation, scrollProvider: controller, animated: animated)
    }
}

// MARK: - ProductListViewModelOutputProtocol
extension ProductListCoordinator: ProductListViewModelOutputProtocol {
    func didLoadModel(_ model: VirtualObject, by product: Product) {
        model.sku = product.sku
        delegate?.actionAddModel(model, by: product)
    }
    
    func didChangedProduct(_ product: Product) {
        controller.updateProduct(product)
    }
    
    func didLoadFinish() {
        controller.refreshUI()
    }
    
    func didFinishFlow() {
        presenter.dissmissOveraly(animated: true)
    }
    
    func didError(_ error: ServerError) {
        let message = error.description.isEmpty ? "Something went wrong" : error.description
        controller.showErrorMessage(message)
    }
}
