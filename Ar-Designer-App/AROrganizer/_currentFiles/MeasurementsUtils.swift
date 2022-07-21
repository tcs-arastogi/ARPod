//
//  MeasurementsUtils.swift
//  ARDesignerApp
//
//  Created by Andrii Ternovyi on 3/23/22.
//

import Foundation

final class MeasurementsUtils {
    enum Constants {
        static let inchesShortSymbol: String = "″"
    }

    static let shared = MeasurementsUtils()
    
    var isMetric: Bool {
        get { UserDefaults.standard.bool(forKey: "com.containerstore.ar.designerapp.isMetric") }
        set { UserDefaults.standard.set(newValue, forKey: "com.containerstore.ar.designerapp.isMetric") }
    }

    func toString(from value: Float, showSymbol: Bool = true) -> String {
        let data = converted(value: value)
        let symbol = showSymbol ? shortSymbolString : ""
        return String(format: "%.2f%@", data, symbol)
    }
    
    func converted(value: Float) -> Double {
        let measurement = Measurement(value: Double(value), unit: UnitLength.meters)
        return measurement.converted(to: isMetric ? .centimeters : .inches).value
    }
    
    func toMeters(from value: Float, forceCentimeters: Bool = false) -> Float {
        let measurement = Measurement(value: Double(value),
                                      unit: isMetric || forceCentimeters ? UnitLength.centimeters : .inches)
        let data = measurement.converted(to: UnitLength.meters).value
        return Float(data)
    }
    
    func switchMeasurementSystem() {
        isMetric = !isMetric
    }
    
    private var shortSymbolString: String {
        isMetric ? " " + UnitLength.centimeters.symbol : Constants.inchesShortSymbol
    }

    var symbolString: String {
        isMetric ? UnitLength.centimeters.symbol : UnitLength.inches.symbol
    }
    
    static func value(for row: Int) -> String {
        var value: String = ""
        
        if MeasurementsUtils.shared.isMetric {
            value = String(row)
        } else {
            if row < 1 || row > 7 { value.append(String(Int(row / 8)) + " ") }
            value.append(["", "1/8", "1/4", "3/8", "1/2", "5/8", "3/4", "7/8", ""][row % 8])
        }
        
        return value + " " + MeasurementsUtils.shared.symbolString
    }
}
