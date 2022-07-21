//
//  TextAttribure.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/4/22.
//

import UIKit

struct TextAttribute {
    // MARK: - Properties
    let font: UIFont
    var color: UIColor = UIColor.systemBackground
    var attributes: [NSAttributedString.Key: Any] {
        return [.font: font, .foregroundColor: color]
    }

    // MARK: - Lifecycle
    init(_ font: UIFont, _ color: UIColor = .black) {
        self.font = font
        self.color = color
    }
}
