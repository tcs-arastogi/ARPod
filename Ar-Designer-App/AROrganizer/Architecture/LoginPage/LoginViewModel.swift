//
//  LoginViewModel.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/2/22.
//

import Foundation

// MARK: - Input Protocol
protocol LoginViewModelInputProtocol {
    func didFinishEnter(email: String, password: String)
}

// MARK: - Output Protocol
protocol LoginViewModelOutputProtocol: AnyObject {
    func didFinish()
    func didError(_ error: ServerError)
}

final class LoginViewModel: LoginViewModelInputProtocol {
    private let repository: AuthRepositoryProtocol = AuthRepository()
    private var operation: Operation?
    weak var delegate: LoginViewModelOutputProtocol?
    
    // MARK: - Public functions
    func didFinishEnter(email: String, password: String) {
        self.operation = repository.initFlow(username: email, password: password, completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.delegate?.didFinish()
                
            case .failure(let error):
                self.delegate?.didError(error)
            }
        })
    }
}
