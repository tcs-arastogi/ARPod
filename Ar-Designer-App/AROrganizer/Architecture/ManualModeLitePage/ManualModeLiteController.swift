//
//  ManualModeLiteController.swift
//  AROrganizer
//
//  Created by Valeriy Jefimov on 7/5/22.
//

import UIKit

final class ManualModeLiteController: UIViewController {
    // MARK: - Properties
    let viewModel: ManualModeLiteModelInputProtocol
    
    // MARK: - Lifecycle
    init(viewModel: ManualModeLiteModelInputProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(viewModel: ManualModeLiteModel(project: nil))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Actions
extension ManualModeLiteController {}

// MARK: - Private
private extension ManualModeLiteController {
    func setupUI() {

    }
}
