//
//  Position.swift
//  ARDesignerApp
//
//  Created by Mykhailo Lysenko on 5/18/22.
//

import Foundation
import SceneKit

struct Position: Codable, Hashable {
    let x: Float
    let y: Float
    let z: Float
}

extension SCNVector3 {
    var toPosition: Position {
        return .init(x: x, y: y, z: z)
    }
}
extension Position {
    var toVector3: SCNVector3 {
        return .init(x, y, z)
    }
    
    var toMeters: Position {
        return .init(
            x: Float(MeasurementsUtils.shared.toMeters(from: x, forceCentimeters: true)),
            y: Float(MeasurementsUtils.shared.toMeters(from: y, forceCentimeters: true)),
            z: Float(MeasurementsUtils.shared.toMeters(from: z, forceCentimeters: true))
        )
    }
}
