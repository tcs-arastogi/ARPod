//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import UIKit

protocol ___VARIABLE_sceneName:identifier___CoordinatorProtocol: AnyObject {
    
}

final class ___FILEBASENAMEASIDENTIFIER___: CoordinatorProtocol {
    // MARK: - Properties
    private var presenter: UINavigationController
    private var controller: ___VARIABLE_sceneName:identifier___ViewControllerInputProtocol?
    
    // MARK: - Lifecycle
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start(animated: Bool = true) {
        let viewModel = ___VARIABLE_sceneName:identifier___ViewModel()
        viewModel.delegate = self
        let controller = ___VARIABLE_sceneName:identifier___ViewController(viewModel: viewModel)
        presenter.present(controller, animated: animated, completion: nil)
        self.controller = controller
    }
}

// MARK: - ___VARIABLE_sceneName:identifier___ViewModelOutputProtocol
extension ___FILEBASENAMEASIDENTIFIER___: ___VARIABLE_sceneName:identifier___ViewModelOutputProtocol {
    func didError(_ error: ServerError) {
        
    }
}
