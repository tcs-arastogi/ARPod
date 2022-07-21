//
//  ProjectsService.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/3/22.
//

import Foundation

protocol ProjectsServiceProtocol {
    func getProjects(completionHandler: @escaping OperationCompletionHandler<ProjectsResponse?>) -> Operation?
    func getProject(by projectId: String, completionHandler: @escaping OperationCompletionHandler<ProjectResponse?>) -> Operation?
    func removeProject(by projectId: String, completionHandler: @escaping OperationCompletionHandler<ProjectDeleteResponse?>) -> Operation?
    func createProject(_ project: Project, completionHandler: @escaping OperationCompletionHandler<ProjectResponse?>) -> Operation?
    func updateProject(_ project: Project, completionHandler: @escaping OperationCompletionHandler<ProjectResponse?>) -> Operation?
}

final class ProjectsService: ProjectsServiceProtocol {
    enum Endpoint {
        case getProjects(userId: String)
        case getProject(userId: String, projectId: String)
        case deleteProject(userId: String, projectId: String)
        case createProject(userId: String, project: Project)
        case updateProject(userId: String, project: Project)
        
        var httpMethod: String {
            switch self {
            case .createProject:
                return "POST"
                
            case .updateProject:
                return "PUT"
                
            case .deleteProject:
                return "DELETE"
            
            default:
                return "GET"
            }
        }
        
        var endpoint: String {
            switch self {
            case .getProjects(let userId):
                return NetworkConfigurator.baseServerURL + "/api/v1/ar/users/" + userId + "/projects"

            case .getProject(let userId, let projectId):
                return NetworkConfigurator.baseServerURL + "/api/v1/ar/users/" + userId + "/projects/" + projectId

            case .deleteProject(let userId, let projectId):
                return NetworkConfigurator.baseServerURL + "/api/v1/ar/users/" + userId + "/projects/" + projectId
                
            case .updateProject(let userId, let project):
                return NetworkConfigurator.baseServerURL + "/api/v1/ar/users/" + userId + "/projects/" + String(project.id)
            
            case .createProject(let userId, _):
                return NetworkConfigurator.baseServerURL + "/api/v1/ar/users/" + userId + "/projects"
            }
        }
    }
    
    // MARK: - Private
    private let userId: String = UserDefaults.userID
    private let networkingManager: NetworkManagerProtocol
    
    // MARK: - Lifecycle
    deinit {
        debugPrintLog("deinit -> ", self)
    }
    
    init() {
        self.networkingManager = NetworkManager.shared
    }
    
    // MARK: - Public
    func getProjects(completionHandler: @escaping OperationCompletionHandler<ProjectsResponse?>) -> Operation? {
        let type = Endpoint.getProjects(userId: self.userId)
        let headers = RequestHeader.headers()
        let object = RequestModel(endpoint: type.endpoint, headers: headers, httpMethod: type.httpMethod, httpBody: nil)
        return networkingManager.request(modelType: ProjectsResponse.self, object: object, completionHandler: completionHandler)
    }
    
    func getProject(by projectId: String, completionHandler: @escaping OperationCompletionHandler<ProjectResponse?>) -> Operation? {
        let type = Endpoint.getProject(userId: userId, projectId: projectId)
        let headers = RequestHeader.headers()
        let object = RequestModel(endpoint: type.endpoint, headers: headers, httpMethod: type.httpMethod, httpBody: nil)
        return networkingManager.request(modelType: ProjectResponse.self, object: object, completionHandler: completionHandler)
    }
    
    func removeProject(by projectId: String, completionHandler: @escaping OperationCompletionHandler<ProjectDeleteResponse?>) -> Operation? {
        let type = Endpoint.deleteProject(userId: self.userId, projectId: projectId)
        let headers = RequestHeader.headers()
        let object = RequestModel(endpoint: type.endpoint, headers: headers, httpMethod: type.httpMethod, httpBody: nil)
        return networkingManager.request(modelType: ProjectDeleteResponse.self, object: object, completionHandler: completionHandler)
    }
    
    func updateProject(_ project: Project, completionHandler: @escaping OperationCompletionHandler<ProjectResponse?>) -> Operation? {
        let type = Endpoint.updateProject(userId: self.userId, project: project)
        let headers = RequestHeader.headers()
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try? encoder.encode(project)
        
        let object = RequestModel(endpoint: type.endpoint, headers: headers, httpMethod: type.httpMethod, httpBody: data)
        return networkingManager.request(modelType: ProjectResponse.self, object: object, completionHandler: completionHandler)
    }
    
    func createProject(_ project: Project, completionHandler: @escaping OperationCompletionHandler<ProjectResponse?>) -> Operation? {
        let type = Endpoint.createProject(userId: self.userId, project: project)
        let headers = RequestHeader.headers()
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try? encoder.encode(project)
        
        let object = RequestModel(endpoint: type.endpoint, headers: headers, httpMethod: type.httpMethod, httpBody: data)
        return networkingManager.request(modelType: ProjectResponse.self, object: object, completionHandler: completionHandler)

    }
}
