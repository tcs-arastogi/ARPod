//
//  ProjectsRepository.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/4/22.
//

import Foundation

protocol ProjectsRepositoryProtocol {
    var projectNames: [String] { get set }
    
    func getProjects(completionHandler: @escaping (Result<[Project], ServerError>) -> Void) -> Operation?
    func getProject(by projectId: String, completionHandler: @escaping (Result<Project, ServerError>) -> Void) -> Operation?
    func updateProject(_ project: Project, completionHandler: @escaping (Result<Bool, ServerError>) -> Void) -> Operation?
    func removeProject(by projectId: String, completionHandler: @escaping (Result<Bool, ServerError>) -> Void) -> Operation?
    func createProject(_ project: Project, completionHandler: @escaping (Result<Project, ServerError>) -> Void) -> Operation?
}

private var namesCashe: [String] = []

final class ProjectsRepository {
    
    // MARK: - Public
    public var projectNames: [String] {
        get { namesCashe }
        set { namesCashe = newValue }
    }
    // MARK: - Private
    private let service: ProjectsServiceProtocol
    
    // MARK: - Lifecycle
    init() {
        self.service = ProjectsService()
    }
}

// MARK: - AuthRepositoryProtocol
extension ProjectsRepository: ProjectsRepositoryProtocol {
    // MARK: - Deinit
    
    // MARK: - Loading
    func getProjects(completionHandler: @escaping (Result<[Project], ServerError>) -> Void) -> Operation? {
        return service.getProjects { result in
            switch result {
            case .success(let value):
                guard let value = value?.data else { return }
                
                DispatchQueue.main.async { [weak self] in
                    self?.projectNames = value.map(\.name)
                    completionHandler(.success(value))
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    func getProject(by projectId: String, completionHandler: @escaping (Result<Project, ServerError>) -> Void) -> Operation? {
        return service.getProject(by: projectId) { result in
            switch result {
            case .success(let value):
                guard let value = value?.data else { return }
                
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
    
    func removeProject(by projectId: String, completionHandler: @escaping (Result<Bool, ServerError>) -> Void) -> Operation? {
        return service.removeProject(by: projectId) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    completionHandler(.success(true))
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    func updateProject(_ project: Project, completionHandler: @escaping (Result<Bool, ServerError>) -> Void) -> Operation? {
        return service.updateProject(project) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    completionHandler(.success(true))
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    func createProject(_ project: Project, completionHandler: @escaping (Result<Project, ServerError>) -> Void) -> Operation? {
        return service.createProject(project) { result in
            switch result {
            case .success(let value):
                guard let object = value?.data else { return }
                DispatchQueue.main.async {
                    completionHandler(.success(object))
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }
}
