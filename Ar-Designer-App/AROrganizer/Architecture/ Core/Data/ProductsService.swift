//
//  ProductsService.swift
//  AROrganizer-Develop
//
//  Created by Yurii Goroshenko on 6/10/22.
//

import Foundation

protocol ProductsServiceProtocol {
    func getProducts(by project: Project, completionHandler: @escaping OperationCompletionHandler<ProductsResponse?>) -> Operation?
    func removeProduct(for projecttId: String, by productId: String, completionHandler: @escaping OperationCompletionHandler<Bool?>) -> Operation?
    func downloadProduct(by modelName: String, completionHandler: @escaping OperationCompletionHandler<ModelResponse?>) -> Operation?
}

final class ProductsService: ProductsServiceProtocol {
    enum Endpoint {
        case getProducts(userId: String, query: String)
        case deleteProducts(userId: String, projectId: String, productId: String)
        case downloadProducts(userId: String, modelName: String)
        
        var httpMethod: String {
            switch self {
            case .deleteProducts: // Check if need
                return "DELETE"
            default:
                return "GET"
            }
        }
        
        var endpoint: String {
            switch self {
            case .getProducts(let userId, let query):
                return NetworkConfigurator.baseServerURL + "/api/v1/ar/users/" + userId + "/products/" + query
            
            case .deleteProducts(let userId, let projectId, let productId):
                return NetworkConfigurator.baseServerURL + "/api/v1/ar/users/" + userId + "/projects/" + projectId + "/products/" + productId
            
            case .downloadProducts(let userId, let modelName):
                return NetworkConfigurator.baseServerURL + "/api/v1/ar/users/" + userId + "/products/models?model_name=" + modelName
            }
            
        }
    }
    
    // MARK: - Private
    private let userId: String = UserDefaults.userID
    private let networkingManager: NetworkManagerProtocol
    
    // MARK: - Lifecycle
    deinit {
        debugPrintLog("deinit -> ", self)
    }
    
    init() {
        self.networkingManager = NetworkManager.shared
    }
    
    // MARK: - Public
    func getProducts(by project: Project, completionHandler: @escaping OperationCompletionHandler<ProductsResponse?>) -> Operation? {
        let type = Endpoint.getProducts(userId: self.userId, query: project.roomType + project.measurements.toQuery)
        let headers = RequestHeader.headers()
        let object = RequestModel(endpoint: type.endpoint, headers: headers, httpMethod: type.httpMethod, httpBody: nil)
        return networkingManager.request(modelType: ProductsResponse.self, object: object, completionHandler: completionHandler)
    }
    
    func removeProduct(for projecttId: String, by productId: String, completionHandler: @escaping OperationCompletionHandler<Bool?>) -> Operation? {
        let type = Endpoint.deleteProducts(userId: self.userId, projectId: projecttId, productId: productId)
        let headers = RequestHeader.headers()
        let object = RequestModel(endpoint: type.endpoint, headers: headers, httpMethod: type.httpMethod, httpBody: nil)
        return networkingManager.request(modelType: Bool.self, object: object, completionHandler: completionHandler)
    }
    
    func downloadProduct(by modelName: String, completionHandler: @escaping OperationCompletionHandler<ModelResponse?>) -> Operation? {
        let type = Endpoint.downloadProducts(userId: self.userId, modelName: modelName)
        let headers = RequestHeader.headers()
        let object = RequestModel(endpoint: type.endpoint, headers: headers, httpMethod: type.httpMethod, httpBody: nil)
        return networkingManager.request(modelType: ModelResponse.self, object: object, completionHandler: completionHandler)
    }
}
