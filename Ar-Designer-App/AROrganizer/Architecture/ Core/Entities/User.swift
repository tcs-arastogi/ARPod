//
//  User.swift
//  ARDesignerApp
//
//  Created by Andrii Ternovyi on 2/4/22.
//

import Foundation

struct User: Codable {
    let customerId: Int
    let firstName: String
    let lastName: String
    let emailAddress: String
    let defaultPhone: String
}
