//
//  AuthService.swift
//

import Foundation

protocol AuthServiceProtocol {
    func initFlow(username: String, password: String, completionHandler: @escaping OperationCompletionHandler<User?>) -> Operation?
}

final class AuthService: AuthServiceProtocol {
    enum Endpoint {
        case initFlow

        var httpMethod: String {
            return "POST"
        }

        var endpoint: String {
            switch self {
            case .initFlow:
                return NetworkBaseURLs.subEnvironment + "/api/v1/profile/login"
            }
        }
    }

    // MARK: - Private
    private let networkingManager: NetworkManagerProtocol

    // MARK: - Lifecycle
    deinit {
        debugPrintLog("deinit -> ", self)
    }
    
    init() {
        self.networkingManager = NetworkManager.shared
    }

    // MARK: - Public
    func initFlow(username: String, password: String, completionHandler: @escaping OperationCompletionHandler<User?>) -> Operation? {
        let bodyData = ["username": username,
                        "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: bodyData, options: .prettyPrinted)

        let type = Endpoint.initFlow
        let headers = RequestHeader.headers()

        let object = RequestModel(endpoint: type.endpoint, headers: headers, httpMethod: type.httpMethod, httpBody: jsonData)
        return networkingManager.request(modelType: User.self, object: object, completionHandler: completionHandler)
    }
}
