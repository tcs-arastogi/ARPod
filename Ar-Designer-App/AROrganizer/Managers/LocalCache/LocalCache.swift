//
//  LocalCache.swift
//  AROrganizer-Develop
//
//  Created by Yurii Goroshenko on 6/13/22.
//

import Foundation

final class LocalCache {
    static let shared = LocalCache()

    // MARK: - LocalCache
    let modelCache = NSCache<NSString, CachedARModel>()
    let productsCache = NSCache<NSString, CachedProductsResponse>()
}
