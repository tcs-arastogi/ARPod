//
//  NetworkManager.swift
//

import Foundation

protocol NetworkManagerProtocol {
    func request<T>(modelType: T.Type, object: RequestModel, completionHandler: @escaping OperationCompletionHandler<T?>) -> Operation? where T: Decodable
    func cancelRequest(by url: URL)
    func cancelAllRequests()
}

final class NetworkManager: NSObject, NetworkManagerProtocol {
    // MARK: - Properties
    static let shared = NetworkManager()
    private lazy var operationQueue: OperationQueue = OperationQueue()
    private var lastOperation: Operation?
    private var lastRequest: URLRequest?
    private var tempOperation: Operation?

    // MARK: - Public functions
    func request<T>(modelType: T.Type, object: RequestModel, completionHandler: @escaping OperationCompletionHandler<T?>) -> Operation? where T: Decodable {
        guard let url = URL(string: object.endpoint) else {
            debugPrint("❌❌❌ \(object.endpoint) ❌❌❌ ERROR Incorrect URL")
            return nil
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = object.httpMethod
        urlRequest.httpBody = object.httpBody
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        for (key, value) in object.headers ?? [:] {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        lastRequest = urlRequest
        lastOperation = runOperation(urlRequest: urlRequest, completionHandler: { result in
            switch result {
            case .success(let data):
                guard let json = data?.0, let response = data?.1 else { return completionHandler(.failure(.failJSON)) }

                if modelType.self == Data.self {
                    completionHandler(.success(json as? T))
                    return
                }

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let object = try? decoder.decode(modelType, from: json) {
                    completionHandler(.success(object))
                } else {
                    self.relogin(for: response, completionHandler: { result in
                        switch result {
                        case .success(let data):
                            guard let json = data?.0 else { return completionHandler(.failure(.failJSON)) }
                            let object = try? decoder.decode(modelType, from: json)
                            completionHandler(.success(object))
                            
                        case .failure:
                            break
                        }
                    })
                }

            case .failure(let error):
                completionHandler(.failure(error))
            }
        })
        
        return lastOperation
    }

    func cancelRequest(by url: URL) {
        guard let operations = operationQueue.operations as? [NetworkOperation] else { return }
        if let operation = operations.filter({ $0.urlRequest.url == url }).first {
            operation.cancel()
        }
    }

    func cancelAllRequests() {
        operationQueue.cancelAllOperations()
    }
}

// MARK: - URLSessionDelegate
extension NetworkManager: URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
}

// MARK: - Private
private extension NetworkManager {
    static func compareMainData(current: Operation?, with operation: NetworkOperation) -> Bool {
        guard let current = current as? NetworkOperation else { return false }

        let lhsRequest = current.urlRequest
        let rhsRequest = operation.urlRequest
        return lhsRequest == rhsRequest &&
        lhsRequest.httpMethod == rhsRequest.httpMethod &&
        lhsRequest.httpBody == rhsRequest.httpBody &&
        lhsRequest.allHTTPHeaderFields == rhsRequest.allHTTPHeaderFields
    }
    
    // TODO: - Temp solution
    func relogin(for response: URLResponse?, completionHandler: @escaping OperationCompletionHandler<(Data, URLResponse)?>) {
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.requestStatus.rawValue == 200,
            let email = KeychainManager.getValue(type: .email),
            let password = KeychainManager.getValue(type: .password),
            let urlRequest = lastRequest
        else { return }
        
        tempOperation = AuthRepository().initFlow(username: email, password: password, completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.lastOperation = self.runOperation(urlRequest: urlRequest, completionHandler: completionHandler)
                
            case .failure:
                break
            }
        })
    }
    
    func runOperation(urlRequest: URLRequest, completionHandler: @escaping OperationCompletionHandler<(Data, URLResponse)?>) -> Operation? {
        let operation = NetworkOperation(urlRequest: urlRequest, requestDelegate: self, completion: completionHandler)

        if operationQueue.operations.contains(where: { NetworkManager.compareMainData(current: $0, with: operation) }) {
            debugPrint("✏️✏️✏️ Operation still in progress ✏️✏️✏️")
        } else {
            operationQueue.addOperation(operation)
        }
        
        return operation
    }
}
