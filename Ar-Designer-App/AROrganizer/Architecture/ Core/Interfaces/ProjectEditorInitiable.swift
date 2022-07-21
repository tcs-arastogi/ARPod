//
//  ProjectEditorInitiable.swift
//  AROrganizer
//
//  Created by Valeriy Jefimov on 7/11/22.
//

import Foundation

protocol ProjectEditorInitiable: AnyObject {
    // swiftlint:disable implicitly_unwrapped_optional
    var project: Project { get set }
    // swiftlint:enable implicitly_unwrapped_optional
    var isNewProject: Bool { get set }
    var repository: ProjectsRepositoryProtocol { get }
  
}

extension ProjectEditorInitiable {
    func setup(with project: Project?) {
        guard let project = project else {
            self.isNewProject = true
    
            var newProjectName = "Project1"
            while self.repository.projectNames.contains(newProjectName) {
                newProjectName = newProjectName.incrementedName
            }
            self.project = Project(name: newProjectName)
            return
        }
        
        self.project = project
    }
}
