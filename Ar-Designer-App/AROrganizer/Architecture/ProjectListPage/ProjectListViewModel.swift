//
//  ProjectListViewModel.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/3/22.
//

import Foundation

// MARK: - Input Protocol
protocol ProjectListViewModelInputProtocol {
    var displayProjects: [Project] { get }
    var isSearching: Bool { get set }

    func viewDidLoad()
    func didCreateProjectPressed(type: ProjectType)
    func didProfilePressed()
    func didSelectProject(_ project: Project)
    func actionFilterBy(_ text: String?)
}

// MARK: - Output Protocol
protocol ProjectListViewModelOutputProtocol: AnyObject {
    func didSelectProject(_ project: Project)
    func didCreateProjectPressed(type: ProjectType)
    func didProfilePressed()
    func didLoadFinish()
    func didError(_ error: ServerError)
}

final class ProjectListViewModel: ProjectListViewModelInputProtocol {
    // MARK: - Private
    private let repository: ProjectsRepositoryProtocol = ProjectsRepository()
    private var operation: Operation?
    private var dataProjects: [Project] = []
    private var filteredProjects: [Project] = []
    
    // MARK: - Public
    var displayProjects: [Project] {
        isSearching && !filteredProjects.isEmpty
        ? filteredProjects
        : dataProjects
    }
    var isSearching: Bool = false

    weak var delegate: ProjectListViewModelOutputProtocol?
    
    // MARK: - Public functions
    func viewDidLoad() {
        self.operation = repository.getProjects(completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let array):
                self.dataProjects = array.sorted(by: { $0.updatedAt > $1.updatedAt })
                self.delegate?.didLoadFinish()
                
            case .failure(let error):
                self.delegate?.didError(error)
            }
        })
    }
    
    func actionFilterBy(_ text: String?) {
        guard let text = text else {
            filteredProjects = []
            return
        }
        
        filteredProjects = dataProjects
            .filter({ $0.name.lowercased().contains(text) })
            .sorted(by: { $0.updatedAt > $1.updatedAt })
        delegate?.didLoadFinish()
    }
    
    func didProfilePressed() {
        delegate?.didProfilePressed()
    }
    
    func didSelectProject(_ project: Project) {
        delegate?.didSelectProject(project)
    }
    
    func didCreateProjectPressed(type: ProjectType) {
        delegate?.didCreateProjectPressed(type: type)
    }
}
