//
//  CollisionCategory.swift
//  ARDesignerApp
//
//  Created by Goran Pavlovic on 5/13/22.
//

import Foundation

struct CollisionCategory: OptionSet {
    let rawValue: Int
    static let modelCategory = CollisionCategory(rawValue: 1 << 0)
    static let boxCategory = CollisionCategory(rawValue: 1 << 1)
}
