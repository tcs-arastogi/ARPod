//
//  UIView+Extensions.swift
//  ARDesignerApp
//
//  Created by Andrii Ternovyi on 2/22/22.
//

import UIKit

extension UIView {
    func takeScreenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIView {
    func addShadow(offset: CGSize = CGSize.zero, color: UIColor = UIColor.lightGray.withAlphaComponent(0.4), radius: CGFloat = 6.0, opacity: Float = 1) {
      layer.shouldRasterize = true
      layer.rasterizationScale = UIScreen.main.scale
      layer.masksToBounds = false
      layer.shadowOffset = offset
      layer.shadowColor = color.cgColor
      layer.shadowRadius = radius
      layer.shadowOpacity = opacity
    }

    func removeShadow() {
      layer.shadowOffset = CGSize.zero
      layer.shadowColor = UIColor.clear.cgColor
      layer.shadowRadius = 0.0
      layer.shadowOpacity = 0.0
    }
}
