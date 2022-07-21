//
//  ProductionsRepository.swift
//  AROrganizer-Develop
//
//  Created by Yurii Goroshenko on 6/10/22.
//

import Foundation

protocol ProductsRepositoryProtocol {
    func getProducts(by project: Project, completionHandler: @escaping (Result<[Product], ServerError>) -> Void) -> Operation?
    func removeProduct(for projecttId: String, by productId: String, completionHandler: @escaping (Result<Bool, ServerError>) -> Void) -> Operation?
    func downloadProduct(by modelName: String, completionHandler: @escaping (Result<VirtualObject, ServerError>) -> Void) -> Operation?
    func downloadProducts(by project: Project,
                          loaderHandler: @escaping ((current: Int, count: Int)) -> Void,
                          completionHandler: @escaping (Result<([(model: VirtualObject, product: Product)]), ServerError>) -> Void)
    
}

final class ProductsRepository {
    private let service: ProductsServiceProtocol
    private var operations: [Operation] = []
    
    // MARK: - Lifecycle
    init() {
        self.service = ProductsService()
    }
}

// MARK: - ProductsRepositoryProtocol
extension ProductsRepository: ProductsRepositoryProtocol {
    var virtualObjectLoader: VirtualObjectLoader { return VirtualObjectLoader() }
    
    // MARK: - Loading
    func getProducts(by project: Project, completionHandler: @escaping (Result<[Product], ServerError>) -> Void) -> Operation? {
        if let products = LocalCache.shared.getProducts(by: project.measurementValue)?.data {
            for product in products {
                product.downloaded = product.checkDownload()
            }
            
            DispatchQueue.main.async {
                completionHandler(.success(products))
            }
            
            return nil
        }
        
        return service.getProducts(by: project, completionHandler: { result in
            switch result {
            case .success(let response):
                guard let response = response else { return }
                let array = response.data.filter({ !($0.modelUrl ?? "").isEmpty }) // TODO: - removing broken models
                
                for product in array {
                    product.downloaded = product.checkDownload()
                }
                
                LocalCache.shared.saveProducts(project.measurementValue, value: response)
                
                DispatchQueue.main.async {
                    completionHandler(.success(array))
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        })
    }
    
    func removeProduct(for projecttId: String, by productId: String, completionHandler: @escaping (Result<Bool, ServerError>) -> Void) -> Operation? {
        return service.removeProduct(for: projecttId, by: productId) { result in
            switch result {
            case .success(let value):
                guard let value = value else { return }
                
                DispatchQueue.main.async {
                    completionHandler(.success(value))
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    func downloadProducts(by project: Project,
                          loaderHandler: @escaping ((current: Int, count: Int)) -> Void,
                          completionHandler: @escaping (Result<([(model: VirtualObject, product: Product)]), ServerError>) -> Void) {
        guard !project.productList.isEmpty else {
            completionHandler(.success([]))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let downloadGroup = DispatchGroup()
            var models: [(VirtualObject, Product)] = []
            var index: Int = 0
            DispatchQueue.main.async {
                loaderHandler((index, project.productList.count))
            }
            
            for product in project.productList {
                guard let modelUrl = URL(string: product.modelUrl ?? "")?.lastPathComponent, !product.isDownloading else { return }
                downloadGroup.enter()
                
                let operation = self?.downloadProduct(by: modelUrl) { result in
                    switch result {
                    case .success(let object):
                        models.append((object, product))
                        
                    case .failure(let error):
                        debugPrintLog(error.localizedDescription)
                    }
                    index += 1
                    DispatchQueue.main.async {
                        loaderHandler((index, project.productList.count))
                    }
                    
                    downloadGroup.leave()
                }
                
                if let operation = operation {
                    self?.operations.append(operation)
                }
            }
            
            downloadGroup.notify(queue: DispatchQueue.main) {
                DispatchQueue.main.async {
                    completionHandler(.success(models))
                }
            }
        }
    }
    
    func downloadProduct(by modelName: String, completionHandler: @escaping (Result<VirtualObject, ServerError>) -> Void) -> Operation? {
        if ModelFileManager.objectExist(for: modelName) {
            loadModel(modelName: modelName, completionHandler: completionHandler)
            return nil
        }
        
        return service.downloadProduct(by: modelName) { [weak self] result in
            switch result {
            case .success(let value):
                guard let value = value?.data else { return }
                self?.saveModel(data: value, modelName: modelName)
                self?.loadModel(modelName: modelName, completionHandler: completionHandler)
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }
}

// MARK: - Storage model
private extension ProductsRepository {
    func saveModel(data: Data, modelName: String) {
        do {
            let fileManager = FileManager.default
            let destinationUrl = ModelFileManager.url(for: modelName)
            if ModelFileManager.objectExist(for: modelName) {
                try fileManager.removeItem(atPath: destinationUrl.path)
            }
            
            try data.write(to: destinationUrl)
        } catch {
            print("Fail")
        }
    }
    
    func loadModel(modelName: String, completionHandler: @escaping (Result<VirtualObject, ServerError>) -> Void) {
        let url = ModelFileManager.url(for: modelName)
        guard let object = VirtualObject(url: url) else { return }
        
        virtualObjectLoader.loadVirtualObject(object) { object in
            DispatchQueue.main.async {
                completionHandler(.success(object))
            }
        }
    }
}
