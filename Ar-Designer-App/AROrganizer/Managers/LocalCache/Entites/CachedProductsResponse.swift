//
//  CachedProductsResponse.swift
//  AROrganizer-Develop
//
//  Created by Yurii Goroshenko on 6/16/22.
//

import Foundation

final class CachedProductsResponse: NSObject {
    var data: [Product] = []
}

// MARK: - Cache
extension LocalCache {
    func getProducts(by id: String) -> ProductsResponse? {
        guard let object = productsCache.object(forKey: id as NSString) else { return nil }
        return ProductsResponse(data: object.data)
    }
    
    func saveProducts(_ id: String, value: ProductsResponse) {
        let object = CachedProductsResponse()
        object.data = value.data
        productsCache.setObject(object, forKey: id as NSString)
    }
}
