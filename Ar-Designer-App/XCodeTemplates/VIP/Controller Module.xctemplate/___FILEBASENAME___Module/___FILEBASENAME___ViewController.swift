//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import UIKit

// MARK: - View Protocols
protocol ___VARIABLE_sceneName:identifier___ViewStyle {

}

protocol ___VARIABLE_sceneName:identifier___ViewDelegate {

}

final class ___FILEBASENAMEASIDENTIFIER___: UIViewController {
    // MARK: - Variables
    private var displayObjects: [Any] = []
    private lazy var interactor: ___VARIABLE_sceneName:identifier___InteractorInput = { return ___VARIABLE_sceneName:identifier___Interactor(output: self) }()
    // MARK: - Outlets

    // MARK: - Lifecycle
    deinit {
        debugPrint("deinit -> ", self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        interactor.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      interactor.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      interactor.viewWillDisappear()
    }

    func setupUI() {

    }
}

// MARK: - Button Action
extension ___FILEBASENAMEASIDENTIFIER___ {

}

// MARK: - Private
private extension ___FILEBASENAMEASIDENTIFIER___ {

}

// MARK: - ___VARIABLE_sceneName: identifier___PresenterOutput
extension ___FILEBASENAMEASIDENTIFIER___: ___VARIABLE_sceneName: identifier___PresenterOutput {
    func presenterDidUpdateDisplayObjects(_ elements: [Any]) {
        self.displayObjects = elements
        // Reload collection
    }

    func presenterDidMessage(_ message: String, type: Int) {

    }
}
