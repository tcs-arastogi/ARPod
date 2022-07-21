//
//  CGPoint+Extensions.swift
//  ARDesignerApp
//
//  Created by Andrii Ternovyi on 2/9/22.
//

import Foundation
import CoreGraphics
import SceneKit

extension CGPoint {
    
    init(_ size: CGSize) {
        self.init()
        self.x = size.width
        self.y = size.height
    }
    
    init(_ vector: SCNVector3) {
        self.init()
        self.x = CGFloat(vector.x)
        self.y = CGFloat(vector.y)
    }
    
    func distanceTo(_ point: CGPoint) -> CGFloat {
        (self - point).length()
    }
    
    func length() -> CGFloat {
        sqrt(self.x * self.x + self.y * self.y)
    }
    
    func midpoint(_ point: CGPoint) -> CGPoint {
        (self + point) / 2
    }
    
    func friendlyString() -> String {
        "(\(String(format: "%.2f", x)), \(String(format: "%.2f", y)))"
    }
}

// swiftlint:disable shorthand_operator
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}

func / (left: CGPoint, right: CGFloat) -> CGPoint {
    CGPoint(x: left.x / right, y: left.y / right)
}

func * (left: CGPoint, right: CGFloat) -> CGPoint {
    CGPoint(x: left.x * right, y: left.y * right)
}

func /= (left: inout CGPoint, right: CGFloat) {
    left = left / right
}

func *= (left: inout CGPoint, right: CGFloat) {
    left = left * right
}
// swiftlint:enable shorthand_operator
