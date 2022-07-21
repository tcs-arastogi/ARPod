//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import Foundation

// MARK: - Interactor Protocol
protocol ___VARIABLE_sceneName:identifier___InteractorInput {
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
}

final class ___FILEBASENAMEASIDENTIFIER___ {
    // MARK: - Variables
//    private let repository: <#type#>
    private let presenter: ___VARIABLE_sceneName:identifier___PresenterInput
    private var lastOperation: Operation?

    // MARK: - Lifecycle
    init(output: ___VARIABLE_sceneName:identifier___PresenterOutput) {
        self.presenter = ___VARIABLE_sceneName:identifier___Presenter(output: output)
//        self.repository = <#type#>
    }
}

// MARK: - ___VARIABLE_sceneName:identifier___InteractorInput
extension ___FILEBASENAMEASIDENTIFIER___: ___VARIABLE_sceneName:identifier___InteractorInput {
    func viewDidLoad() {
        // Load  data from cache
    }

    func viewWillAppear() {
        // Load  data from network
        loadDisplayObjects()
    }

    func viewWillDisappear() {
        lastOperation?.cancel()
    }
}

// MARK: - Private
private extension ___FILEBASENAMEASIDENTIFIER___ {
    func loadDisplayObjects() {
//        self.lastOperation = repository.loadData(completionHandler: { [weak self] (result) in
//            guard let self = self else { return }
//
//            switch result {
//            case .success:
//                // setup presender
//                self.presenter.setupSecurities(displayObjects)
//            case .failure(let error):
//                self.presenter.showMessage(error.localizedDescription, type: .error)
//            }
//
//            self.lastOperation = nil
//        })
    }
}
