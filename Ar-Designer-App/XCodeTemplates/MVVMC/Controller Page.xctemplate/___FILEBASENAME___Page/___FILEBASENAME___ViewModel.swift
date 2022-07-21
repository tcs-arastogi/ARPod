//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import Foundation

// MARK: - Input Protocol
protocol ___VARIABLE_sceneName:identifier___ViewModelInputProtocol {
    func viewDidLoad()
}

// MARK: - Output Protocol
protocol ___VARIABLE_sceneName:identifier___ViewModelOutputProtocol: AnyObject {
    func didError(_ error: ServerError)
}

final class ___FILEBASENAMEASIDENTIFIER___: ___VARIABLE_sceneName:identifier___ViewModelInputProtocol {
    private var operation: Operation?
    weak var delegate: ___VARIABLE_sceneName:identifier___ViewModelOutputProtocol?
    
    // MARK: - Public functions
    func viewDidLoad() {
        
    }
}
