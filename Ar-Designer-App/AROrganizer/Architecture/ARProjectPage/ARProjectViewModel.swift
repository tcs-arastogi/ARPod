//
//  ARProjectViewModel.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/7/22.
//

import Foundation
import SceneKit

// MARK: - Input Protocol
protocol ARProjectViewModelInputProtocol: ProjectEditorInitiable {
    func didAddProductPressed()
    func didSaveProjectPressed()
    func trySaveProject(with newName: String) -> Bool
    
    func didChangeMeasurements(_ measurements: Measurements)
    func didChangeMeasurementsValue(_ value: Float, state: SceneManager.DrawingState)
    
    func actionAddProduct(_ product: Product, modelId: String)
    func actionDublicateProduct(by model: VirtualObject)
    func actionChangePosition(by model: VirtualObject)
    func actionRemoveProduct(by model: VirtualObject)
    func downloadModels(loaderHandler: @escaping ((current: Int, count: Int)) -> Void,
                        completionHandler: @escaping ([(model: VirtualObject, product: Product)]) -> Void)
}

// MARK: - Output Protocol
protocol ARProjectViewModelOutputProtocol: AnyObject {
    func didChangedMeasurements()
    func didSaveProject(_ project: Project)
    func didAddProductPressed(project: Project)
    func didError(_ error: ServerError)
}

final class ARProjectViewModel: ARProjectViewModelInputProtocol {
    
    // MARK: - Private
    private var operation: Operation?
    private let productRepository: ProductsRepositoryProtocol = ProductsRepository()
    
    // MARK: - Public
    var project: Project = .empty
    var repository: ProjectsRepositoryProtocol = ProjectsRepository()
    var isNewProject: Bool = false
    weak var delegate: ARProjectViewModelOutputProtocol?
    
    lazy var debouncer = NetworkDebouncer.init(callback: saveProjectCalled)
    
    // MARK: - Lifecycle
    convenience init(project: Project?) {
        self.init()
        setup(with: project)
    }
    
    private init() { }
    
    // MARK: - Public functions
    func didChangeMeasurements(_ measurements: Measurements) {
        project.measurements = measurements
        delegate?.didChangedMeasurements()
    }
    
    func didChangeMeasurementsValue(_ value: Float, state: SceneManager.DrawingState) {
        switch state {
        case .draggingInitialLength:
            project.measurements.length = value
            
        case .draggingInitialWidth:
            project.measurements.width = value
            
        case .draggingInitialHeight:
            project.measurements.height = value
        
        default:
            break
        }
    }
    
    func didAddProductPressed() {
        delegate?.didAddProductPressed(project: project)
    }
    
    func trySaveProject(with newName: String) -> Bool {
        if !repository.projectNames.contains(newName) {
            project.name = newName
            didSaveProjectPressed()
            return true
        }
        return false
    }
    
    func didSaveProjectPressed() {
        debouncer.call()
    }
    
    func actionAddProduct(_ product: Product, modelId: String) {
        // TEMP solution
        let newProduct = Product(id: product.id, sku: product.sku, name: product.name, imageUrl: product.imageUrl,
                                 modelUrl: product.modelUrl, price: product.price, measurements: product.measurements)

        newProduct.virtualId = modelId
        project.products?.append(newProduct)
        project.refreshTotalPrice()
    }
    
    func downloadModels(loaderHandler: @escaping ((current: Int, count: Int)) -> Void,
                        completionHandler: @escaping ([(model: VirtualObject, product: Product)]) -> Void) {
        productRepository.downloadProducts(by: project, loaderHandler: { result in
            loaderHandler(result)
        }, completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let array):
                completionHandler(array)
            case .failure(let error):
                self.delegate?.didError(error)
            }
        })
    }
    
    func actionRemoveProduct(by model: VirtualObject) {
        project.products?.removeAll(where: { $0.virtualId == model.id.uuidString })
        project.refreshTotalPrice()
    }
    
    func actionDublicateProduct(by model: VirtualObject) {
        guard let product = project.productList.first(where: { $0.sku == model.sku }) else { return }
        project.products?.append(Product(object: model, model: product))
        project.refreshTotalPrice()
    }
    
    func actionChangePosition(by model: VirtualObject) {
        project
            .products?
            .first(where: { $0.virtualId == model.id.uuidString })?
            .position = model.position.toPosition
    }
}

private extension ARProjectViewModel {
    func saveProjectCalled() {
        operation?.cancel()
        
        if isNewProject {
            operation = repository.createProject(project) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let project):
                    self.project.id = project.id
                    self.isNewProject = false
                    self.delegate?.didSaveProject(self.project)
                    
                case .failure(let error):
                    self.delegate?.didError(error)
                }
            }
        } else {
            operation = repository.updateProject(project) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.delegate?.didSaveProject(self.project)
                    
                case .failure:
                    break
                }
            }
        }
    }
}
