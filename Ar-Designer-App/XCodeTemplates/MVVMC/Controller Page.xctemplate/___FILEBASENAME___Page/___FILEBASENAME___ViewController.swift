//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import UIKit

// MARK: - Input Protocol
protocol ___VARIABLE_sceneName:identifier___ViewControllerInputProtocol {
    func showErrorMessage(_ message: String)
}

final class ___FILEBASENAMEASIDENTIFIER___: UIViewController, ___VARIABLE_sceneName:identifier___ViewControllerInputProtocol {
    // MARK: - Properties
    private let viewModel: ___VARIABLE_sceneName:identifier___ViewModelInputProtocol?
    
    // MARK: - Lifecycle
    deinit {
        debugPrint("deinit -> ", self)
    }
    
    init(viewModel: ___VARIABLE_sceneName:identifier___ViewModelInputProtocol?) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(viewModel: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel?.viewDidLoad()
    }
    
    func showErrorMessage(_ message: String) {
        
    }
}

// MARK: - Actions
extension ___FILEBASENAMEASIDENTIFIER___ {
    
}

// MARK: - Private
private extension ___FILEBASENAMEASIDENTIFIER___ {
    func setupUI() {
        
    }
}
