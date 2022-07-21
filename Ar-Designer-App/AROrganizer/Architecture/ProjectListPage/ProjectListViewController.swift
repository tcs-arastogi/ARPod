//
//  ProjectListViewController.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/3/22.
//

import UIKit

final class ProjectListViewController: UIViewController {
    private enum Constants {
        static let cellHeight: Double = 142.0
        static let topSearchOffset: Double = -60.0
    }
    // MARK: - Properties
    private var viewModel: ProjectListViewModelInputProtocol
    private let searchButton: UIButton = UIButton(type: .custom)
    private let filterButton: UIButton = UIButton(type: .custom)
    private let profileButton: UIButton = UIButton(type: .custom)
    private var searchViewIsHidden: Bool = false {
        didSet { viewModel.isSearching = !searchViewIsHidden }
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var activityLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var topSearchLayout: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    deinit {
        debugPrintLog("deinit -> ", self)
    }
    
    init(viewModel: ProjectListViewModelInputProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(viewModel: ProjectListViewModel())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.appearance(with: UIColor.systemBackground, shadowColor: UIColor.separator)
        viewModel.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dispaySeachView(true, animated: false)
    }
    
    func reloadProjects() {
        tableView.reloadData()
        table(isHidden: false)
    }
    
    func showErrorMessage(_ message: String) {
        activityIndicator.stopAnimating()
        AlertMessageManager.show(sender: self, messageText: message)
    }
}

// MARK: - Actions
extension ProjectListViewController {
    @IBAction func actionProfilePressed(_ sender: Any) {
        viewModel.didProfilePressed()
    }
    
    @IBAction func actionSearchPressed(_ sender: Any) {
        dispaySeachView(!searchViewIsHidden)
        reloadProjects()
    }
    
    @IBAction func actionFilterPressed(_ sender: Any) {
        
    }
    
    @IBAction func actionAddProjectPressed(_ sender: Any) {
        var actions: [(title: String, completionHandler: AlertMessageManager.ActionCompletionHandler)] = []

        let arAction: AlertMessageManager.ActionCompletionHandler = { [weak self] _ in
            self?.viewModel.didCreateProjectPressed(type: .ar)
        }

        let manualAction: AlertMessageManager.ActionCompletionHandler = { [weak self] _ in
            self?.viewModel.didCreateProjectPressed(type: .manual)
        }

        let manualLiteAction: AlertMessageManager.ActionCompletionHandler = { [weak self] _ in
            self?.viewModel.didCreateProjectPressed(type: .manualLite)
        }

        actions.append(("Create AR Project", arAction))
        actions.append(("Create Manual Project", manualAction))
        actions.append(("Create Manual Lite Project", manualLiteAction))

        AlertMessageManager.showActionSheet(sender: self, messageText: "Select kind of project", actions: actions)
    }
    
    @IBAction func actionSearchDidChanged(_ textField: UITextField) {
        viewModel.actionFilterBy(textField.text)
    }
}

// MARK: - Private
private extension ProjectListViewController {
    func setupUI() {
        table(isHidden: true)
        title = "Projects"
        
        profileButton.setup(type: .profile)
        profileButton.addTarget(self, action: #selector(actionProfilePressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        searchButton.setup(type: .search)
        searchButton.addTarget(self, action: #selector(actionSearchPressed), for: .touchUpInside)
        
        filterButton.setup(type: .filter)
        filterButton.addTarget(self, action: #selector(actionFilterPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: searchButton)]
        
        tableView.registerNib(with: ProjectTableCell.self)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = Constants.cellHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        dispaySeachView(true)
    }
    
    func table(isHidden: Bool) {
        activityIndicator.isHidden = !isHidden
        activityLabel.isHidden = !viewModel.displayProjects.isEmpty
        tableView.isHidden = isHidden
    }
    
    func dispaySeachView(_ isHidden: Bool, animated: Bool = true) {
        guard isHidden != searchViewIsHidden else { return }
        topSearchLayout.constant = isHidden ? Constants.topSearchOffset : 0.0
        
        if isHidden {
            searchTextField.text = nil
            viewModel.actionFilterBy(nil)
        }
        searchViewIsHidden = isHidden
        var completed: () -> Void = {
            if isHidden {
                self.searchTextField.resignFirstResponder()
            } else {
                self.searchTextField.becomeFirstResponder()
            }
        }
        
        guard animated else {
            view.layoutIfNeeded()
            completed()
            return
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        } completion: { _ in
            completed()
        }
    }
}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension ProjectListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayProjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueCell(ProjectTableCell.self, forIndexPath: indexPath) else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.setup(with: viewModel.displayProjects[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectProject(viewModel.displayProjects[indexPath.row])
    }
}
