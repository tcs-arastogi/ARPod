//
//  NetworkLogger.swift
//
//  Created by Yurii Goroshenko on 24.01.2022.
//

import Foundation

protocol NetworkLoggerProtocol {
    func startLog(_ request: URLRequest)
    func endLog(_ response: URLResponse?, data: Data?, with error: Error?)
}

final class NetworkLogger: NetworkLoggerProtocol {
    private var startTime: CFAbsoluteTime = 0.0
    private var urlRequest: URLRequest?
    private var urlResponse: URLResponse?
    private let configurator: LoggerConfigurator = LoggerConfigurator()

    // MARK: - Lifecycle
    func startLog(_ request: URLRequest) {
        self.urlRequest = request
        self.startTime = CFAbsoluteTimeGetCurrent()

        guard configurator.request else { return }
        let title = request.url?.absoluteString ?? ""
        // Add curl format as type
        debugPrint("🚀🚀🚀 \(request.httpMethod!) \(title) 🚀🚀🚀") // need add send time
    }

    func endLog(_ response: URLResponse?, data: Data?, with error: Error?) {
        self.urlResponse = response
        let diff = CFAbsoluteTimeGetCurrent() - self.startTime
        let time = String(format: "%0.2f sec.", diff)

        showResponseLogs(time: time)

        if let data = data {
            showBodyDataLogs(data, time: time)
        }

        if let errorMessage = error {
            showErrorLogs(errorMessage, time: time)
        }
    }
}

// MARK: - Private functions
private extension NetworkLogger {
    func showResponseLogs(time: String) {
        guard configurator.response, let request = urlRequest, let response = urlResponse else { return }

        let requestApi = request.url?.absoluteString ?? ""

        // Logger Title
        if let dataResponse = response as? HTTPURLResponse {
            if dataResponse.statusCode == 200 {
                debugPrint("✅✅✅ \(request.httpMethod!) \(requestApi) ✅✅✅ SUCCESS \(dataResponse.statusCode) ⏱️\(time)⏱️")
            } else {
                debugPrint("❌❌❌ \(request.httpMethod!) \(requestApi) ❌❌❌ ERROR \(dataResponse.statusCode) ⏱️\(time)⏱️")
            }
        }
    }

    func showBodyDataLogs(_ data: Data, time: String) {
        guard let request = urlRequest else { return }

        // REQUEST HEADERS
        if configurator.headers, let headers = request.allHTTPHeaderFields {
            debugPrint("🏷️🏷️🏷️ REQUEST HEADERS 🏷️🏷️🏷️")
            debugPrint(headers as AnyObject)
        }

        // REQUEST PARAMETERS
        if configurator.parameters, let httpBody = request.httpBody {
            let params = try? JSONSerialization.jsonObject(with: httpBody, options: .allowFragments)
            debugPrint("✉️✉️✉️ REQUEST PARAMETERS ✉️✉️✉️")
            debugPrint(params as AnyObject)
        }

        guard configurator.body else { return }
        // RESPONSE BODY
        let body = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        debugPrint("📤📤📤 RESPONSE BODY 📤📤📤")
        debugPrint(body as AnyObject)
    }

    func showErrorLogs(_ error: Error, time: String) {
        guard let request = urlRequest else { return }
        let apiName = request.url?.absoluteString ?? ""

        if let code = (error as? ServerError)?.code {
            debugPrint("❌❌❌ \(request.httpMethod!) \(apiName) ❌❌❌ ERROR \(code) ⏱️\(time)⏱️")
            debugPrint("📝📝📝 \(error.description) 📝📝")
        } else {
            debugPrint("❌❌❌ \(request.httpMethod!) \(apiName) ❌❌❌ ERROR ⏱️\(time)⏱️")
            debugPrint("📝📝📝 \(error.localizedDescription) 📝📝")
        }
    }
}
