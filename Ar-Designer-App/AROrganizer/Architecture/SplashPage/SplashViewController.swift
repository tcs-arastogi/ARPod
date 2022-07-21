//
//  SplashViewController.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/4/22.
//

import UIKit

final class SplashViewController: UIViewController {
    private let viewModel: SplashViewModelInputProtocol
    
    // MARK: - Lifecycle
    deinit {
        debugPrintLog("deinit -> ", self)
    }
    
    init(viewModel: SplashViewModelInputProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(viewModel: SplashViewModel())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }
    
    func showErrorMessage(_ message: String) {
        AlertMessageManager.show(sender: self, messageText: message)
    }
}

// MARK: - Private
private extension SplashViewController {
    func setupUI() {
        
    }
}
