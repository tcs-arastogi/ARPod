//
//  RequestModel.swift
//

import Foundation

struct RequestModel {
    let endpoint: String
    let headers: [String: String]?
    let httpMethod: String
    let httpBody: Data?
}
