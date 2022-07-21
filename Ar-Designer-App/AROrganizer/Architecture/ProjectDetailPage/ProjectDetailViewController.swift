//
//  ProjectDetailViewController.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/4/22.
//

import UIKit

final class ProjectDetailViewController: UIViewController {
    private enum Constants {
        static let cellHeight: Double = 100.0
        static let totalAttribute = TextAttribute(UIFont.brandBoldFont(ofSize: 16), UIColor.black)
        static let projectAttribute = TextAttribute(UIFont.brandFont(ofSize: 16), UIColor.black)
        static let titleBoldAttribute = TextAttribute(UIFont.brandBoldFont(ofSize: 14), UIColor.black)
        static let titleAttribute = TextAttribute(UIFont.brandFont(ofSize: 12), UIColor.lightGray)
    }
    
    // MARK: - Properties
    private let backButton: UIButton = UIButton(type: .custom)
    private let moreButton: UIButton = UIButton(type: .custom)
    private var viewModel: ProjectDetailViewModelInputProtocol
    private var isEditMode: Bool = false
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var projectNameTextField: UITextField!
    @IBOutlet private weak var measurementLabel: UILabel!
    @IBOutlet private weak var totalPriceLabel: UILabel!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var bottomStackView: UIStackView!
    @IBOutlet private weak var activityLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    deinit {
        debugPrintLog("deinit -> ", self)
    }
    
    init(viewModel: ProjectDetailViewModelInputProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(viewModel: ProjectDetailViewModel(project: Project(name: "")))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.appearance(with: UIColor.systemBackground, shadowColor: UIColor.separator)
    }
    
    func refreshUI() {
        setupProductHeader()
        activityIndicator.stopAnimating()
        activityLabel.isHidden = !viewModel.project.productList.isEmpty
        tableView.reloadData()
    }
    
    func showErrorMessage(_ message: String) {
        activityIndicator.stopAnimating()
        AlertMessageManager.show(sender: self, messageText: message)
    }
}

// MARK: - Actions
extension ProjectDetailViewController {
    @IBAction func actionBackPressed(_ sender: Any) {
        viewModel.actionBackPressed()
    }
    
    @IBAction func actionMorePressed(_ sender: Any) {
        var actions: [(title: String, completionHandler: AlertMessageManager.ActionCompletionHandler)] = []
        
        let action: AlertMessageManager.ActionCompletionHandler = { [weak self] _ in
            guard let self = self else { return }
            self.actionDeleteProjectPressed(self)
        }
        
        actions.append(("Delete Project", action))
        
        AlertMessageManager.showActionSheet(sender: self, messageText: "Select action", actions: actions)
    }
    
    @IBAction func actionEditNamePressed(_ sender: Any) {
        if isEditMode {
            viewModel.project.name = projectNameTextField.text ?? ""
            projectNameTextField.resignFirstResponder()
            viewModel.saveProject()
        } else {
            projectNameTextField.isUserInteractionEnabled = true
            projectNameTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func actionOpenProjectPressed(_ sender: Any) {
        viewModel.openProject()
    }
    
    @IBAction func actionDeleteProjectPressed(_ sender: Any) {
        let actionCancel = UIAlertAction(title: "No", style: .default, handler: nil)
        let actionOK = UIAlertAction(title: "Yes", style: .cancel, handler: { [weak self] _ in
            self?.viewModel.deleteProject()
        })
        
        let message = "Are you sure you want delete project?"
        AlertMessageManager.show(sender: self, title: nil, messageText: message, actions: [actionCancel, actionOK])
    }
}

// MARK: - Private
private extension ProjectDetailViewController {
    func setupUI() {
        backButton.setup(type: .back)
        backButton.addTarget(self, action: #selector(actionBackPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
         
        moreButton.setup(type: .more)
        moreButton.addTarget(self, action: #selector(actionMorePressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
        
        tableView.registerNib(with: ProductTableCell.self)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = Constants.cellHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        setupProductHeader()
        bottomView.addShadow()
        
        textFieldDidEndEditing(projectNameTextField)
    }
    
    func setupProductHeader() {
        title = "Project Detail"
        projectNameTextField.attributedText = viewModel.project.name.attribute(Constants.projectAttribute)
        measurementLabel.attributedText = viewModel.project.measurementValue.attribute(Constants.titleAttribute)
        totalPriceLabel.attributedText =
        "Total price: \(viewModel.project.price)".attribute(Constants.totalAttribute)
            .add("\n(\(viewModel.project.productList.count) items)".attribute(Constants.titleAttribute))
    }
}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension ProjectDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.project.productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueCell(ProductTableCell.self, forIndexPath: indexPath) else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.setup(with: viewModel.project.productList[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let product = viewModel.project.productList[indexPath.row]
        viewModel.removeProduct(product)
    }
}

// MARK: - UITextFieldDelegate
extension ProjectDetailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.borderStyle = .roundedRect
        textField.textColor = UIColor.black
        editButton.setImage(UIImage(named: "ic-done"), for: .normal)
        isEditMode = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.borderStyle = .none
        textField.textColor = UIColor.lightGray
        textField.isUserInteractionEnabled = false
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        isEditMode = false
    }
}
