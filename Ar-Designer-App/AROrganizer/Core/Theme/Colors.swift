//
//  Colors.swift
//  ARDesignerApp
//
//  Created by Andrii Ternovyi on 2/3/22.
//

import UIKit.UIColor

private extension UIColor {
    static func color(named: String) -> UIColor {
        UIColor(named: named) ?? .systemPink
    }
}

extension UIColor {
    static let arButton = UIColor.color(named: "arButton")
    static let placeholder = UIColor.color(named: "placeholder")
}
