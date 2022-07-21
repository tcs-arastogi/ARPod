//
//  AuthRepository.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/4/22.
//

import Foundation

protocol AuthRepositoryProtocol {
    func logout()
    func initFlow(username: String, password: String, completionHandler: @escaping (Result<User, ServerError>) -> Void) -> Operation?
}

final class AuthRepository {
    private let service: AuthServiceProtocol
    private var passcode: String?

    // MARK: - Lifecycle
    init() {
        self.service = AuthService()
    }
}

// MARK: - AuthRepositoryProtocol
extension AuthRepository: AuthRepositoryProtocol {
    // MARK: - Deinit
    func logout() {
        UserDefaults.isLoggedIn = false
        KeychainManager.deleteAll()
    }

    // MARK: - Loading
    func initFlow(username: String, password: String, completionHandler: @escaping (Result<User, ServerError>) -> Void) -> Operation? {
        KeychainManager.deleteAll()
        return service.initFlow(username: username, password: password) { result in
            switch result {
            case .success(let value):
                guard let value = value else { return }
                
                UserDefaults.userID = String(value.customerId)
                
                // TODO: - temp solution
                KeychainManager.save(value: username, type: .email)
                KeychainManager.save(value: password, type: .password)
                
                // Temp solution
                LocalManager.shared.user = value
                
                DispatchQueue.main.async {
                    completionHandler(.success(value))
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }
}
