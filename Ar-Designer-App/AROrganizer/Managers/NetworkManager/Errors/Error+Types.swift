//
//  Error+Types.swift
//
//  Created by Yurii Goroshenko on 30.11.2021.
//

import Foundation

// MARK: - Server Errors
enum ServerError: Error {
    case empty
    case error(code: Int, text: String)
    case failMIMEURL
    case failJSON
    case failData
    case invalidToken
    case unowned

    var code: Int {
        switch self {
        case .error(let code, _):   return code
        case .invalidToken:         return -401
        default:                    return -1
        }
    }

    var localizedDescription: String {
        switch self {
        case .error(_, let text):   return text
        default:                    return ""
        }
    }
}

// MARK: - JSON Errors
struct JSONError: Decodable {
    var errors: String? = "" // Waiting for server changes
    var message: String?
    var code: String?
    var timestamp: String?
}

// MARK: - Error+Extentions
extension Error {
    var description: String { return (self as? ServerError)?.localizedDescription ?? self.localizedDescription }
}
