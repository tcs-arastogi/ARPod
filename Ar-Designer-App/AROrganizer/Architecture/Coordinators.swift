//
//  CoordinatorProtocol.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/2/22.
//

import Foundation

protocol CoordinatorProtocol {
    func start(animated: Bool)
}

class ContainerCoordinator {
    var nextCoordinator: CoordinatorProtocol?
}
