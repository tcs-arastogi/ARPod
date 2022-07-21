//
//  SplashViewModel.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/4/22.
//

import Foundation

// MARK: - Input Protocol
protocol SplashViewModelInputProtocol {
    func viewDidAppear()
}

// MARK: - Output Protocol
protocol SplashViewModelOutputProtocol: AnyObject {
    func didFinish()
    func didError(_ error: ServerError)
}

final class SplashViewModel: SplashViewModelInputProtocol {
    private var operation: Operation?
    weak var delegate: SplashViewModelOutputProtocol?
    
    // MARK: - Public functions
    func viewDidAppear() {        
        delegate?.didFinish()
    }
}
