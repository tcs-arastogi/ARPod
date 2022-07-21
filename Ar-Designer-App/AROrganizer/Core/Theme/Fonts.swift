//
//  Fonts.swift
//  ARDesignerApp
//
//  Created by Andrii Ternovyi on 2/9/22.
//

import UIKit.UIFont

protocol FontStyle {
    var brandFontName: String { get }
    var brandBoldFontName: String { get }
    var secondaryFontName: String { get }
    var brandFontType: String { get }
}

extension UIFont {
    static func brandFont(ofSize size: CGFloat) -> UIFont {
        let name = (UIFont() as FontStyle).brandFontName
        return UIFont(name: name, size: size)!
    }

    static func brandBoldFont(ofSize size: CGFloat) -> UIFont {
        let name = (UIFont() as FontStyle).brandBoldFontName
        return UIFont(name: name, size: size)!
    }
}

extension UIFont: FontStyle {
    var brandFontName: String { return "SFProDisplay-Regular" }
    var brandBoldFontName: String { return "SFProDisplay-Bold" }
    var secondaryFontName: String { return "ProximaNova-Regular" }
    var brandFontType: String { return ".otf" }
}
