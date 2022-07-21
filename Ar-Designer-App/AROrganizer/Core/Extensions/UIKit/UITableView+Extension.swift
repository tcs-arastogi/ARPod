//
//  UITableView+Extension.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/4/22.
//

import UIKit

extension UITableView {
    func registerNib<T: UITableViewCell>(with cell: T.Type) {
        register(cell.nib, forCellReuseIdentifier: cell.reuseIdentifier)
    }
    
    func dequeueCell<T: UITableViewCell>(_ cell: T.Type, forIndexPath indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T
    }
}

extension UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    // MARK: - xib

    class var reusableIdentifier: String {
        return String(describing: self)
    }

    class var nib: UINib? {
        return UINib.init(nibName: reusableIdentifier, bundle: nil)
    }

    func loadNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return nil }
        return view
    }
}
