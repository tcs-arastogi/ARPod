//
//  Measurements.swift
//  ARDesignerApp
//
//  Created by Mykhailo Lysenko on 5/18/22.
//

import SceneKit

enum MeasurementsType: Int {
    case none = 0
    case width
    case length
    case height
}

struct Measurements: Codable, Hashable {
    var width: Float
    var length: Float
    var height: Float
    
    var metricType: Distance? = .inch // TODO: - Need check type
    
    // Convertors
    var toString: String { String(format: "%0.2f x %0.2f x %0.2f in", width, length, height) }
    var toVector: SCNVector3 { SCNVector3(x: length, y: height, z: width) }
    var toQuery: String { return "?length=\(length)&width=\(width)&height=\(height)" }
    
    // Display
    var widthValue: String { String(format: "%0.2f", width) }
    var lengthValue: String { String(format: "%0.2f", length) }
    var heightValue: String { String(format: "%0.2f", height) }
    
    var isEmpty: Bool {
        return height == 0 && width == 0 && length == 0
    }
}
