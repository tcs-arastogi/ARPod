//
//  CachedARModelResponse.swift
//  AROrganizer-Develop
//
//  Created by Yurii Goroshenko on 6/16/22.
//

import Foundation

struct ARModel: Decodable {
    let data: Data
}

class CachedARModel: NSObject {
    var data: Data?
}

// MARK: - Cache
extension LocalCache {
    func getModel(by id: String) -> ARModel? {
        guard
            let object = modelCache.object(forKey: id as NSString),
            let data = object.data
        else { return nil }

        return ARModel(data: data)
    }

    func saveModel(_ id: String, value: ARModel) {
        let object = CachedARModel()
        object.data = value.data
        modelCache.setObject(object, forKey: id as NSString)
    }
}
