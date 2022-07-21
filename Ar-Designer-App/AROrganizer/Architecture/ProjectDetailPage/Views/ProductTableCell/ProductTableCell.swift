//
//  ProductTableCell.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/5/22.
//

import UIKit
import Kingfisher

protocol ProductTableCellProtocol {
    var imageLink: String { get }
    var name: String { get }
    var priceValue: String { get }
    var measurementValue: String { get }
    var code: String { get }
}

final class ProductTableCell: UITableViewCell {
    private enum Constants {
        static let titleAttribute = TextAttribute(UIFont.brandFont(ofSize: 14), UIColor.black)
        static let priceAttribute = TextAttribute(UIFont.brandBoldFont(ofSize: 14), UIColor.black)
        static let infoBoldAttribute = TextAttribute(UIFont.brandBoldFont(ofSize: 11), UIColor.black)
        static let infoAttribute = TextAttribute(UIFont.brandFont(ofSize: 11), UIColor.lightGray)
    }
    
    // MARK: - Outlets
    @IBOutlet weak private var previewImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var measurementLabel: UILabel!
    @IBOutlet weak private var priceLabel: UILabel!
    @IBOutlet weak private var codeLabel: UILabel!
    private var object: ProductTableCellProtocol?
    
    // MARK: - Public functions
    func setup(with object: ProductTableCellProtocol) {
        self.object = object
        let url = URL(string: object.imageLink)
        previewImageView.kf.setImage(with: url)
        
        titleLabel.attributedText = object.name.attribute(Constants.titleAttribute)
        priceLabel.attributedText = object.priceValue.attribute(Constants.priceAttribute)
        measurementLabel.attributedText = object.measurementValue.attribute(Constants.infoAttribute)
        codeLabel.attributedText =
        "SKU: ".attribute(Constants.infoBoldAttribute)
            .add(object.code.attribute(Constants.infoAttribute))
    }
}
