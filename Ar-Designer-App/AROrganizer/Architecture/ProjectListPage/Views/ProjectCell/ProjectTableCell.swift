//
//  ProjectTableCell.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/4/22.
//

import UIKit

protocol ProjectTableCellProtocol {
    var name: String { get }
    var totalValue: Double { get }
    var price: String { get }
    var createDate: String { get }
    var measurementValue: String { get }
}

final class ProjectTableCell: UITableViewCell {
    private enum Constants {
        static let titleAttribute = TextAttribute(UIFont.brandBoldFont(ofSize: 16), UIColor.black)
        static let disabledTitleAttribute = TextAttribute(UIFont.brandBoldFont(ofSize: 16), UIColor.lightGray)
        static let normalAttribute = TextAttribute(UIFont.brandFont(ofSize: 14), UIColor.black)
        static let infoBoldAttribute = TextAttribute(UIFont.brandBoldFont(ofSize: 11), UIColor.black)
        static let infoAttribute = TextAttribute(UIFont.brandFont(ofSize: 11), UIColor.lightGray)
    }
    
    // MARK: - Outlets
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var priceLabel: UILabel!
    @IBOutlet weak private var measurementLabel: UILabel!
    @IBOutlet weak private var dateLabel: UILabel!
    private var object: ProjectTableCellProtocol?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.addShadow()
    }
    
    // MARK: - Public functions
    func setup(with object: ProjectTableCellProtocol) {
        let priceAttribute = object.totalValue == 0 ? Constants.disabledTitleAttribute : Constants.titleAttribute
        
        titleLabel.attributedText = object.name.attribute(Constants.titleAttribute)
        priceLabel.attributedText = "Total price: ".attribute(Constants.normalAttribute)
            .add(object.price.attribute(priceAttribute))
        
        measurementLabel.attributedText = object.measurementValue.attribute(Constants.infoAttribute)
        dateLabel.attributedText = "Created date: ".attribute(Constants.infoBoldAttribute)
            .add(object.createDate.attribute(Constants.infoAttribute))
    }
}
