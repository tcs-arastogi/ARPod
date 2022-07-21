//
//  ProfileViewModel.swift
//  AROrganizer
//
//  Created by Yurii Goroshenko on 6/9/22.
//

import Foundation
import UIKit

// MARK: - Input Protocol
protocol ProfileViewModelInputProtocol {
    func viewDidLoad()
    func didLogoutPressed()
    func createAutosortMenuActions(didSelect: @escaping (Heuristic) -> Void) -> [UIAction]
}

// MARK: - Output Protocol
protocol ProfileViewModelOutputProtocol: AnyObject {
    func didLogoutPressed()
    func didError(_ error: ServerError)
}

final class ProfileViewModel: ProfileViewModelInputProtocol {
    private var operation: Operation?
    
    // MARK: - Public
    weak var delegate: ProfileViewModelOutputProtocol?
    
    // MARK: - Public functions
    func viewDidLoad() {
        
    }
    
    func didLogoutPressed() {
        delegate?.didLogoutPressed()
    }
    
    func createAutosortMenuActions(didSelect: @escaping (Heuristic) -> Void) -> [UIAction] {
        return Heuristic.allCases.map { heuristic in
            UIAction(title: heuristic.title,
                     image: heuristic.image,
                     handler: { _ in
                UserDefaults.autosortType = heuristic.rawValue
                didSelect(heuristic)
            })
        }
    }
}

extension Heuristic {
    var title: String {
        switch self {
        case .bestArea:
            return "Best Area"
        case .bestShortside:
            return "Best Shortside"
        case .bestLongside:
            return "Best Longside"
        case .worstArea:
            return "Worst Area"
        case .worstShortside:
            return "Worst Shortside"
        case .worstLongside:
            return "Worst Longside"
        case .bottomLeft:
            return "Bottom Left"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .bestArea:
            return UIImage(systemName: "square.fill")
        case .bestShortside:
            return UIImage(systemName: "square.grid.3x3")
        case .bestLongside:
            return UIImage(systemName: "square.grid.2x2")
        case .worstArea:
            return UIImage(systemName: "square.on.square.squareshape.controlhandles")
        case .worstShortside:
            return UIImage(systemName: "square.split.1x2")
        case .worstLongside:
            return UIImage(systemName: "square.split.2x2")
        case .bottomLeft:
            return UIImage(systemName: "square.lefthalf.filled")
        }
    }
}
