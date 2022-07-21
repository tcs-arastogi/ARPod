//
//  ProjectDetailViewModel.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/4/22.
//

import Foundation

// MARK: - Input Protocol
protocol ProjectDetailViewModelInputProtocol {
    var project: Project { get }
    
    func viewDidLoad()
    func actionBackPressed()
    func saveProject()
    func openProject()
    func deleteProject()
    func removeProduct(_ product: Product)
}

// MARK: - Output Protocol
protocol ProjectDetailViewModelOutputProtocol: AnyObject {
    func didUpdateProject(_ project: Project)
    func didOpenProject(_ project: Project)
    func didFinishFlow()
    func didError(_ error: ServerError)
}

final class ProjectDetailViewModel: ProjectDetailViewModelInputProtocol {
    private var operation: Operation?
    private var repository: ProjectsRepositoryProtocol = ProjectsRepository()
    private let productRepository: ProductsRepositoryProtocol = ProductsRepository()
    
    var project: Project
    weak var delegate: ProjectDetailViewModelOutputProtocol?
    
    // MARK: - Lifecycle
    init(project: Project) {
        self.project = project
    }
    
    func viewDidLoad() {
        self.operation = repository.getProject(by: "\(project.id)", completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let project):
                self.project = project
                self.project.refreshTotalPrice()
                self.delegate?.didUpdateProject(project)
                
            case .failure(let error):
                self.delegate?.didError(error)
            }
        })
    }
    
    // MARK: - Public functions
    func actionBackPressed() {
        delegate?.didFinishFlow()
    }
    
    func openProject() {
        delegate?.didOpenProject(project)
    }
    
    func saveProject() {
        self.operation = repository.updateProject(project) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.delegate?.didUpdateProject(self.project)
            
            case .failure(let error):
                self.delegate?.didError(error)
            }
        }
    }
    
    func deleteProject() {
        self.operation = repository.removeProject(by: "\(project.id)") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.repository.projectNames.removeAll(where: { $0 == self.project.name })
                self.delegate?.didFinishFlow()
            case .failure(let error):
                self.delegate?.didError(error)
            }
        }
    }
    
    func removeProduct(_ product: Product) {
        project.products?.removeAll(where: { $0.id == product.id })
        project.refreshTotalPrice()
        saveProject()
        delegate?.didUpdateProject(self.project)
    }
}
