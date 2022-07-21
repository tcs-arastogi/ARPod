//
//  ButtonStyle.swift
//
//  Created by Yurii Goroshenko on 20.11.2021.
//

import UIKit

protocol ButtonElementStyle {
    var titleColor: UIColor { get }
    var titleFont: UIFont { get }
    var backgroundColor: UIColor { get }
}

enum ButtonElementKind: String, Decodable {
    case primary
    case secondary
}

enum ButtonElement {
    case standart(kind: ButtonElementKind)
    case back
    case close
    
    case search
    case filter

    case edit
    case profile
    case more

    // Configuration Fields
    var imageName: String? {
        switch self {
        case .back:         return "ic-arrow-left"
        case .close:        return "xmark"
        case .search:       return "magnifyingglass"
        case .filter:       return "line.3.horizontal.decrease"

        case .edit:         return "pencil"
        case .profile:      return "person.crop.circle"
        case .more:         return "ellipsis"

        default:            return nil
        }
    }

    var tintColor: UIColor {
        switch self {
        case .standart:
            return UIColor.systemBackground
        default:
            return UIColor.label
        }
    }

    var frame: CGRect? {
        switch self {
        case .standart:
            return nil
        default:
            return CGRect(x: 0, y: 0, width: 44, height: 44)
        }
    }

    var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
        switch self {
        case .back:
            return .left
        case .search:
            return .right
        default:
            return .center
        }
    }

    var cornerRadius: CGFloat {
        return 4.0
    }
}

// MARK: - Buttons
extension UIButton {
    func setup(text: String? = nil, type: ButtonElement) {
        if text != nil {
            setTitle(text, for: .normal)
        }

        if let buttonFrame = type.frame {
            frame = buttonFrame
        }

        if let imageName = type.imageName {
            setImage(UIImage(systemName: imageName) ?? UIImage(named: imageName), for: .normal)
        } else {
            setImage(nil, for: .normal)
        }

        contentHorizontalAlignment = type.contentHorizontalAlignment
        clipsToBounds = true
        layer.cornerRadius = type.cornerRadius

        tintColor = type.tintColor
        titleLabel?.font = (type as ButtonElementStyle).titleFont
        setTitleColor((type as ButtonElementStyle).titleColor, for: .normal)
        backgroundColor = (type as ButtonElementStyle).backgroundColor
    }
}

// MARK: -
extension ButtonElement: ButtonElementStyle {
    var titleColor: UIColor {
        switch self {
        case .standart(let kind):
            switch kind {
            case .primary:
                return UIColor.black
            case .secondary:
                return UIColor.black
            }
        default:
            return UIColor.systemBackground
        }
    }

    var titleFont: UIFont {
        switch self {
        case .standart(let kind):
            switch kind {
            case .primary:
                return UIFont.brandBoldFont(ofSize: 16)
            case .secondary:
                return UIFont.brandFont(ofSize: 14)
            }
        default:
            return UIFont.brandFont(ofSize: 14)
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .standart(let kind):
            switch kind {
            case .primary:
                return UIColor.blue
            case .secondary:
                return UIColor.clear
            }
        default:
            return UIColor.clear
        }
    }
}
