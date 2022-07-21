//
//  Product.swift
//  ARDesignerApp
//
//  Created by Mykhailo Lysenko on 5/18/22.
//

import Foundation

final class Product: Codable {
    var id: Int? = 0
    let productId: Int? = 0
    let sku: Int
    let name: String
    let imageUrl: String
    let modelUrl: String?
    let price: Double
    let measurements: Measurements
    
    var position: Position? = Position(x: 0, y: 0, z: 0)
    var eulerAngles: Float?
    
    var downloaded: Bool?
    var downloading: Bool? = false
    
    var virtualId: String?

    // TODO: - TEMP Fix
    init(object: VirtualObject, model: Product) {
        self.id = model.id
        self.virtualId = object.id.uuidString
        self.sku = model.sku
        self.name = model.name
        self.imageUrl = model.imageUrl
        self.modelUrl = model.modelUrl
        self.price = model.price
        self.measurements = model.measurements
        self.position = model.position
    }
    
    init(id: Int?, sku: Int, name: String, imageUrl: String, modelUrl: String?, price: Double, measurements: Measurements) {
        self.id = id
        self.sku = sku
        self.name = name
        self.imageUrl = imageUrl
        self.modelUrl = modelUrl
        self.price = price
        self.measurements = measurements
    }
    
    var modelSku: String? {
        guard let name = modelUrl?.components(separatedBy: "/").last else { return nil }
        return "\(name.prefix(while: { $0.isNumber }))"
    }
    
    func checkDownload() -> Bool {
        guard let modelUrl = modelUrl else { return false }
        return ModelFileManager.objectExist(for: modelUrl)
    }
}

// MARK: - ProductTableCellProtocol
extension Product: ProductTableCellProtocol, ProductCellProtocol {
    var isDownloading: Bool { return downloading ?? false }
    var needDownload: Bool { return !(downloaded ?? false) }
    var imageLink: String { return imageUrl }
    var priceValue: String { return String(format: "$%.2f", price) }
    var measurementValue: String { return measurements.toString }
    var code: String { return "\(sku)" }
}
