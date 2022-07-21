//
//  PrimaryActionButton.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/4/22.
//

import UIKit

final class PrimaryActionButton: UIButton {
    
    // MARK: - Lifecycle
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = bounds.height / 2
        self.addShadow()        
    }
}
