//
//  NetworkManagerOperation.swift
//

import Foundation

typealias OperationCompletionHandler<T> = (Result<T, ServerError>) -> Void

final class NetworkOperation: Operation {
    // MARK: - Properties
    private let logger: NetworkLoggerProtocol = NetworkLogger()
    private let completion: OperationCompletionHandler<(Data, URLResponse)?>
    private weak var requestDelegate: URLSessionDelegate?
    var urlRequest: URLRequest
    
    // MARK: - Lifecycle
    init(urlRequest: URLRequest, requestDelegate: URLSessionDelegate, completion: @escaping OperationCompletionHandler<(Data, URLResponse)?>) {
        self.urlRequest = urlRequest
        self.completion = completion
        self.requestDelegate = requestDelegate
    }
    
    override func main() {
        self.logger.startLog(urlRequest)
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: requestDelegate, delegateQueue: .main)
        let task = session.dataTask(with: urlRequest, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            self.logger.endLog(response, data: data, with: error)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let serverError = ServerError.error(code: HTTPStatusCode.none.rawValue, text: "")
                return self.completion(.failure(serverError))
            }
            
            // Get Cookies
            CookiesManager.store(NetworkBaseURLs.environment)
            UserDefaults.isCookies = true
            
            let statusCode = httpResponse.requestStatus.rawValue
            switch httpResponse.requestStatus {
            case .success:
                guard let data = data, let response = response else { return }
                guard !self.validationErrors(data, statusCode: statusCode) else { return }
                self.completion(.success((data, response)))
                
            case .invalidToken:
                // Logout in main queue
                return
                
            case .unAuthorized:
                self.completion(.failure(ServerError.invalidToken))
                return
                
            default:
                guard let data = data, !data.isEmpty else { return }
                _ = self.validationErrors(data, statusCode: statusCode)
            }
        })
        
        task.resume()
    }
}

// MARK: - Private functions
private extension NetworkOperation {
    func validationErrors(_ data: Data, statusCode: Int) -> Bool {
        guard statusCode != 200 else { return false }
        let error = try? JSONDecoder().decode(JSONError.self, from: data)
        let serverError = ServerError.error(code: statusCode, text: error?.message ?? "")
        completion(.failure(serverError))
        return true
    }
}

// MARK: - HTTPURLResponse
extension HTTPURLResponse {
    var requestStatus: HTTPStatusCode { return HTTPStatusCode(rawValue: statusCode) }
}
