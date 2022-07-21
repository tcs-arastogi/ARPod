//
//  ModelFileManager.swift
//  AROrganizer-Develop
//
//  Created by Yurii Goroshenko on 6/15/22.
//

import Foundation

final class ModelFileManager {
    static func objectExist(for name: String) -> Bool {
         FileManager.default.fileExists(atPath: url(for: name).path)
    }

    static func url(for modelName: String) -> URL {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent(modelName)
        return destinationUrl
    }
}
