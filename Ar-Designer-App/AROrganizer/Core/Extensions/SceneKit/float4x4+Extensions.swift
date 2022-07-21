//
//  float4x4+Extensions.swift
//  ARDesignerApp
//
//  Created by Goran Pavlovic on 4/8/22.
//

import ARKit
import Foundation

extension float4x4 {
    // Treats matrix as a (right-hand column-major convention) transform matrix
    // and factors out the translation component of the transform.
    var translation: SIMD3<Float> {
        get {
            let translation = columns.3
            return [translation.x, translation.y, translation.z]
        }
        set(newValue) {
            columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
        }
    }
}
