//
//  ToolTip.swift
//  AROrganizer
//
//  Created by Yurii Goroshenko on 6/22/22.
//

import UIKit

final class ToolTip {
    private enum Constants {
        static let hintAttribute = TextAttribute(UIFont.brandFont(ofSize: 12), UIColor.white)
        static let hintSize = CGSize(width: 116, height: 40)
        static let hintLabelRect = CGRect(x: 8, y: 4, width: 100, height: 30)
    }
    
    // MARK: - Properties
    private var popover: UIViewController = UIViewController()
    
    // MARK: - Public
    func showTip(presenter: UIViewController, button: UIButton, text: String) {
        popover = UIViewController()
        popover.view.backgroundColor = UIColor.clear
        popover.modalPresentationStyle = .popover
        popover.preferredContentSize = Constants.hintSize
        
        let label = UILabel(frame: Constants.hintLabelRect)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.attributedText = text.attribute(Constants.hintAttribute)
        popover.view.addSubview(label)
        
        guard let popoverController = popover.popoverPresentationController else { return }
        popoverController.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        popoverController.delegate = presenter as? UIPopoverPresentationControllerDelegate
        popoverController.permittedArrowDirections = .down
        popoverController.sourceView = button
        popoverController.sourceRect = CGRect(origin: CGPoint(x: button.bounds.midX, y: -4), size: CGSize.zero)
        
        presenter.present(popover, animated: true, completion: { [weak self] in
            self?.popover.view.superview?.layer.cornerRadius = 2.0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.hideTip()
        }
    }
    
    func hideTip() {
        popover.dismiss(animated: true)
    }
}
