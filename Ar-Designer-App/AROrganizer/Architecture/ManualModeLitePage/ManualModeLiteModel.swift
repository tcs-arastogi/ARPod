//
//  ManualModeLiteModel.swift
//  AROrganizer
//
//  Created by Valeriy Jefimov on 7/5/22.
//

import Foundation

// MARK: - Input Protocol
protocol ManualModeLiteModelInputProtocol: ProjectEditorInitiable {
    
}

// MARK: - Output Protocol
protocol ManualModeLiteModelOutputProtocol: AnyObject {
    func didFinish()
    func didError(_ error: ServerError)
}

final class ManualModeLiteModel: ManualModeLiteModelInputProtocol {
    var project: Project = .empty
    var repository: ProjectsRepositoryProtocol = ProjectsRepository()
    var isNewProject: Bool = false
    weak var delegate: ManualModeLiteModelOutputProtocol?
    
    convenience init(project: Project?) {
        self.init()
        setup(with: project)
    }
    
    private init() { }
}
