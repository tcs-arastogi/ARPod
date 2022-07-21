//
//  ARProjectCoordinator.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/7/22.
//

import UIKit
import OverlayContainer

enum OverlayNotch: Int, CaseIterable {
    case hidden, medium, maximum
}

protocol ARProjectCoordinatorDelegate: AnyObject {
    func didUpdateProject(_ project: Project)
}

final class ARProjectCoordinator: ContainerCoordinator, CoordinatorProtocol {
    // MARK: - Properties
    private let presenter: UINavigationController
    private let controller: ARProjectViewController
    private let viewModel: ARProjectViewModel
    private let overlayContainer: OverlayContainerViewController = OverlayContainerViewController()
    weak var delegate: ARProjectCoordinatorDelegate?
    
    // MARK: - Lifecycle
    init(presenter: UINavigationController, project: Project?) {
        self.presenter = presenter
        self.viewModel = ARProjectViewModel(project: project)
        self.controller = ARProjectViewController(viewModel: viewModel)
        super.init()
    }
    
    func start(animated: Bool = true) {
        viewModel.delegate = self
        
        overlayContainer.delegate = self
        overlayContainer.viewControllers = [
            controller,
            UIViewController()
        ]
        
        presenter.pushViewController(overlayContainer, animated: animated)
    }
}

// MARK: - ARProjectViewModelOutputProtocol
extension ARProjectCoordinator: ARProjectViewModelOutputProtocol {
    func didChangedMeasurements() {
        controller.refreshMeasurements()
    }
    
    func didSaveProject(_ project: Project) {
        controller.didSaveProject()
        delegate?.didUpdateProject(project)
    }
    
    func didAddProductPressed(project: Project) {
        let coordinator = ProductListCoordinator(presenter: overlayContainer, project: project, delegate: self)
        coordinator.start()
        self.nextCoordinator = coordinator
    }
    
    func didError(_ error: ServerError) {
        let message = error.description.isEmpty ? "Something went wrong" : error.description
        controller.showErrorMessage(message)
    }
}

// MARK: - ProductListCoordinatorProtocol
extension ARProjectCoordinator: ProductListCoordinatorProtocol {
    func actionAddModel(_ model: VirtualObject, by product: Product) {
        controller.addModel(model, by: product)
    }
}

// TODO: - need review
// MARK: - OverlayContainerViewControllerDelegate
extension ARProjectCoordinator: OverlayContainerViewControllerDelegate {
    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        return OverlayNotch.allCases.count
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat {
        switch OverlayNotch.allCases[index] {
        case .maximum:
            return availableSpace * 0.85
            
        case .medium:
            return 442.0
            
        case .hidden:
            return 0
        }
    }
}

// MARK: - DrivingScrollViewProvider
protocol DrivingScrollViewProvider {
    var drivingScrollView: UIScrollView { get }
}

extension OverlayContainerViewController {
    func present(overlay: UIViewController, scrollProvider: DrivingScrollViewProvider? = nil, animated: Bool) {
        viewControllers.removeLast()
        viewControllers.append(overlay)
        
        moveOverlay(toNotchAt: OverlayNotch.medium.rawValue, animated: animated) {
            guard let scrollView = scrollProvider?.drivingScrollView else { return }
            self.drivingScrollView = scrollView
        }
    }
    
    func dissmissOveraly(animated: Bool) {
        moveOverlay(toNotchAt: OverlayNotch.hidden.rawValue, animated: animated) {
            self.viewControllers.removeLast()
            self.viewControllers.append(UIViewController())
        }
    }
}
