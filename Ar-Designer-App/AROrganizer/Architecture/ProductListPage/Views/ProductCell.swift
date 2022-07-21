//
//  ProductCell.swift
//  AROrganizer-Develop
//
//  Created by Yurii Goroshenko on 6/10/22.
//

import UIKit
import Kingfisher

protocol ProductCellProtocol {
    var imageLink: String { get }
    var name: String { get }
    var priceValue: String { get }
    var measurementValue: String { get }
    var needDownload: Bool { get }
    var isDownloading: Bool { get }
}

final class ProductCell: UICollectionViewCell {
    static let identifier = "ProductCell"
    
    private enum Constants {
        static let titleAttribute = TextAttribute(UIFont.brandFont(ofSize: 14), UIColor.black)
        static let priceAttribute = TextAttribute(UIFont.brandBoldFont(ofSize: 16), UIColor.black)
        static let infoAttribute = TextAttribute(UIFont.brandFont(ofSize: 11), UIColor.lightGray)
    }
    
    private var object: ProductCellProtocol?
    
    // MARK: - Outlets
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var previewImageView: UIImageView!
    @IBOutlet weak private var cloudImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var measurementLabel: UILabel!
    @IBOutlet weak private var priceLabel: UILabel!
    @IBOutlet weak private var downloadingView: UIView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.addShadow()
    }
    
    // MARK: - Public functions
    func setup(with object: ProductCellProtocol) {
        let url = URL(string: object.imageLink)
        previewImageView.kf.setImage(with: url)
//        cloudImageView.isHidden = !object.needDownload
        downloadingView.isHidden = !object.isDownloading
        titleLabel.attributedText = object.name.attribute(Constants.titleAttribute)
        priceLabel.attributedText = object.priceValue.attribute(Constants.priceAttribute)
        measurementLabel.attributedText = object.measurementValue.attribute(Constants.infoAttribute)
    }
}
