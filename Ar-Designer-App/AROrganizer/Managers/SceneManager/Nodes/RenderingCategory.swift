//
//  RenderingCategory.swift
//  ARDesignerApp
//
//  Created by Andrii Ternovyi on 2/15/22.
//

import Foundation

struct RenderingCategory: OptionSet {
    let rawValue: Int
    static let reflected = RenderingCategory(rawValue: 1 << 1)
    static let planes = RenderingCategory(rawValue: 1 << 2)
    static let model = RenderingCategory(rawValue: 1 << 3)
}
