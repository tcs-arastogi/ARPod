//
//  Distance.swift
//  AROrganizer-Develop
//
//  Created by Yurii Goroshenko on 6/9/22.
//

import Foundation

enum Distance: Codable {
    case centimeter
    case inch
    case meter
    
    var fator: Float {
        switch self {
        case .centimeter:
            return 100.0
        case .inch:
            return 39.3700787
        case .meter:
            return 1.0
        }
    }
    
    var unit: String {
        switch self {
        case .centimeter:
            return "cm"
        case .inch:
            return "inch"
        case .meter:
            return "m"
        }
    }
    
    var title: String {
        switch self {
        case .centimeter:
            return "Centimeter"
        case .inch:
            return "Inch"
        case .meter:
            return "Meter"
        }
    }
}
