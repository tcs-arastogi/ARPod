//
//  Common.swift
//  AROrganizer-Develop
//
//  Created by Yurii Goroshenko on 6/15/22.
//

import Foundation

struct ModelResponse: Decodable {
    var data: Data
}

struct ProductsResponse: Decodable {
    var data: [Product]
}

struct ProjectResponse: Decodable {
    var data: Project
}

struct ProjectDeleteResponse: Decodable {
    var data: Project?
    var errors: String?
    var meta: String?
}

struct ProjectsResponse: Decodable {
    var data: [Project]
}
