//
//  Logger.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/7/22.
//

import Foundation

func debugPrintLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if LoggerConfigurator.debugPrint {
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.debugPrint(output, terminator: terminator)
    }
}

// MARK: - Log Configurator
struct LoggerConfigurator {
    let request: Bool = false
    let response: Bool = true
    let headers: Bool = false
    let parameters: Bool = false
    let body: Bool = true
    static let debugPrint: Bool = true
}
