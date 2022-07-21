//
//  UIButton+Loader.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/2/22.
//

import UIKit

extension UIButton {
    func loadingIndicator(_ show: Bool, color: UIColor = .systemBackground, textColor: UIColor? = nil) {
        let tag = 808404
        setTitleColor(textColor, for: .normal)
        self.isEnabled = !show
        self.alpha = show ? 0.75 : 1.0
        
        if show {
            let indicator = UIActivityIndicatorView()
            indicator.color = color
            let buttonHeight = bounds.size.height
            let buttonWidth = bounds.size.width
            indicator.center = CGPoint(x: buttonWidth / 2, y: buttonHeight / 2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
    
    func active() {
        self.isEnabled = true
        self.setTitleColor(UIColor.white, for: .normal)
        self.backgroundColor = UIColor.link
        
    }
    
    func inActive() {
        self.isEnabled = false
        self.setTitleColor(UIColor.black, for: .normal)
        self.backgroundColor = UIColor.lightGray
    }
}
