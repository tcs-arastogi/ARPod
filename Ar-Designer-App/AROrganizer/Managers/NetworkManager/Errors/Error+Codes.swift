//
//  Error+Codes.swift
//

import Foundation

enum HTTPStatusCode: Int {
    case success = 200
    case badRequest = 400
    case unAuthorized = 401
    case notFound = 404
    case invalidToken = 498
    case internalServerError = 500
    case serviceUnavailable = 503
    case `none` = 666

    init(rawValue: Int) {
        switch rawValue {
        case 200..<300: self = .success
        case 400: self = .badRequest
        case 401: self = .unAuthorized
        case 404: self = .notFound
        case 498: self = .invalidToken
        case 500: self = .internalServerError
        case 503: self = .serviceUnavailable
        default: self = .none
        }
    }

    var isServerError: Bool {
        switch rawValue {
        case 500..<600: return true
        default:        return false
        }
    }
}

enum ServerCode: Int {
    case serverError = 1001
    case unknown = -1000

    case `none` = 0
}
