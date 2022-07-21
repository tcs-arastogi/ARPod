//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import UIKit

// MARK: - Presenter Protocols
protocol ___VARIABLE_sceneName:identifier___PresenterInput {
//    func setupTemplates()
//    func setupDisplayObjects()
    func showMessage(_ message: String, type: Int)
}

protocol ___VARIABLE_sceneName:identifier___PresenterOutput: AnyObject {
    func presenterDidUpdateDisplayObjects(_ elements: [Any])
    func presenterDidMessage(_ message: String, type: Int)
}

final class ___FILEBASENAMEASIDENTIFIER___ {
    private weak var delegate: ___VARIABLE_sceneName:identifier___PresenterOutput?

    // MARK: - Lifecyclse
    init(output: ___VARIABLE_sceneName:identifier___PresenterOutput) {
        self.delegate = output
    }
}

// MARK: - Presenter Input
extension ___FILEBASENAMEASIDENTIFIER___: ___VARIABLE_sceneName:identifier___PresenterInput {
//    func setupTemplates() {
//        delegate?.presenterDidUpdateDisplayObjects(displayObjects)
//    }
//
//    func setupDisplayObjects() {
//        delegate?.presenterDidUpdateDisplayObjects(displayObjects)
//    }

    func showMessage(_ message: String, type: Int) {
        delegate?.presenterDidMessage(message, type: type)
    }
}

// MARK: - Private
private extension ___FILEBASENAMEASIDENTIFIER___ {

}
