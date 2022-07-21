//
//  ProductListViewModel.swift
//  AROrganizer
//
//  Created by Yurii Goroshenko on 6/10/22.
//

import Foundation

// MARK: - Input Protocol
protocol ProductListViewModelInputProtocol {
    var products: [Product] { get }
    
    func viewDidLoad()
    func didSelectProduct(_ product: Product)
    func didFinishFlow()
}

// MARK: - Output Protocol
protocol ProductListViewModelOutputProtocol: AnyObject {
    func didChangedProduct(_ product: Product)
    func didLoadModel(_ model: VirtualObject, by product: Product)
    func didLoadFinish()
    func didFinishFlow()
    func didError(_ error: ServerError)
}

final class ProductListViewModel: ProductListViewModelInputProtocol {
    private let repository: ProductsRepositoryProtocol = ProductsRepository()
    private var operation: Operation?
    private let project: Project
    var products: [Product] = []
    weak var delegate: ProductListViewModelOutputProtocol?
    
    // MARK: - Lifecycle
    init(project: Project) {
        self.project = project
    }
    
    // MARK: - Public functions
    func viewDidLoad() {
        self.operation = repository.getProducts(by: project, completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let array):
                self.products = array
                self.delegate?.didLoadFinish()
                
            case .failure(let error):
                self.delegate?.didError(error)
            }
        })
    }
    
    func didSelectProduct(_ product: Product) {
        guard let modelUrl = product.modelUrl, !product.isDownloading else { return }
        product.downloading = true
        delegate?.didChangedProduct(product)
        
        self.operation = repository.downloadProduct(by: modelUrl) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let object):
                product.downloading = false
                product.downloaded = true
                self.delegate?.didLoadModel(object, by: product)
                self.delegate?.didChangedProduct(product)
                
            case .failure(let error):
                product.downloading = false
                self.delegate?.didError(error)
            }
        }
    }
    
    func didFinishFlow() {
        delegate?.didFinishFlow()
    }
}
