//
//  VirtualObjectLoader.swift
//  ARDesignerApp
//
//  Created by Goran Pavlovic on 4/4/22.
//

import Foundation

enum VirtualObjectError: LocalizedError {
    case invalidURL
    case cannotSaveModel
    case invalidUser
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Model url is invalid"
        case .cannotSaveModel: return "Cannot save loaded model"
        case .invalidUser: return "User is not logged in"
        }
    }
}

class VirtualObjectLoader {
    private(set) var loadedObjects = [VirtualObject]()

    // MARK: - Loading object

    /**
     Loads a `VirtualObject` on a background queue. `loadedHandler` is invoked
     on a background queue once `object` has been loaded.
    */
    func loadVirtualObject(_ object: VirtualObject, loadedHandler: @escaping (VirtualObject) -> Void) {
        loadedObjects.append(object)

        // Load the content into the reference node.
        DispatchQueue.global(qos: .userInitiated).async {
            object.load()
            loadedHandler(object)
        }
    }

    // MARK: - Removing Objects
    func removeAllVirtualObjects() {
        _ = loadedObjects.map { unload(object: $0) }
        loadedObjects = [VirtualObject]()
    }
    
    func unload(object: VirtualObject?) {
        object?.removeFromParentNode()
        object?.unload()
    }
    
    @discardableResult
    func removeLastVirtualObject() -> VirtualObject? {
        let object = loadedObjects.popLast()
        unload(object: object)
        remove(object: object)
        
        return object
    }
    
    func remove(object: VirtualObject?) {
        unload(object: object)
        loadedObjects.removeAll(where: { $0.id == object?.id })
    }
}
