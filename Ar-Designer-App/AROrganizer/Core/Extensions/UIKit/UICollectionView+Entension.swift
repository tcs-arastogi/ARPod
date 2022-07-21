//
//  UICollectionView+Entension.swift
//  AROrganizer-Develop
//
//  Created by Yurii Goroshenko on 6/10/22.
//

import UIKit

extension UICollectionView {
    func registerNib<T: UICollectionViewCell>(with cell: T.Type) {
        register(cell.nib, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }
    
    // swiftlint:disable force_cast
    func dequeue<T: UICollectionViewCell>(cell: T.Type, forIndexPath indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
