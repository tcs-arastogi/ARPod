//
//  ProjectModel.swift
//  ARDesignerApp
//
//  Created by Mykhailo Lysenko on 3/15/22.
//

import Foundation

enum ProjectType {
    case ar
    case manual
    case manualLite
}

final class Project: Codable {
    var id: Int = 0
    var createdAt: TimeInterval = Date().timeIntervalSince1970
    var updatedAt: TimeInterval = Date().timeIntervalSince1970
    var name: String = ""
    var roomType: String = "KITCHEN"
    var image: String? = "project_template"
    var measurements: Measurements = Measurements(width: 0, length: 0, height: 0)
    
    var products: [Product]? = []
    var productList: [Product] { products ?? [] } // server should return products always
    var totalPrice: Double = 0.0
    
    init(name: String) {
        self.name = name
    }
    
    func refreshTotalPrice() {
        self.totalPrice = products?.reduce(0, { partialResult, product in
            partialResult + product.price
        }) ?? 0.0
    }
}

// MARK: - ProjectTableCellProtocol
extension Project: ProjectTableCellProtocol {
    var totalValue: Double { return totalPrice }
    var price: String { return String(format: "$%.2f", totalValue) }
    var createDate: String { return createdAt.toDateString() }
    var measurementValue: String { return measurements.toString }
}

extension Project {
    static var empty: Project { Project(name: "Project0") }
}
