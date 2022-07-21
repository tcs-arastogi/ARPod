//
//  ProfileViewController.swift
//  AROrganizer
//
//  Created by Yurii Goroshenko on 6/9/22.
//

import UIKit

final class ProfileViewController: UIViewController {
    private enum Constants {
        static let titleAttribute = TextAttribute(UIFont.brandFont(ofSize: 16), UIColor.black)
        static let emailAttribute = TextAttribute(UIFont.brandFont(ofSize: 14), UIColor.link)
    }
    
    // MARK: - Properties
    private let viewModel: ProfileViewModelInputProtocol
    private let backButton: UIButton = UIButton(type: .custom)
    
    // MARK: - Outlets
    @IBOutlet private weak var autosortSwitch: UISwitch!
    @IBOutlet private weak var autosortMenuButton: UIButton!
    @IBOutlet private weak var profileNameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var bottomView: UIView!
    
    // MARK: - Lifecycle
    deinit {
        debugPrintLog("deinit -> ", self)
    }
    
    init(viewModel: ProfileViewModelInputProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(viewModel: ProfileViewModel())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.viewDidLoad()
    }
    
    func showErrorMessage(_ message: String) {
        AlertMessageManager.show(sender: self, messageText: message)
    }
}

// MARK: - Actions
extension ProfileViewController {
    @IBAction func actionBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionLogoutPressed(_ sender: Any) {
        let actionCancel = UIAlertAction(title: "No", style: .default, handler: nil)
        let actionOK = UIAlertAction(title: "Yes", style: .cancel, handler: { [weak self] _ in
            self?.viewModel.didLogoutPressed()
        })
        
        let message = "Are you sure you want to logout?"
        AlertMessageManager.show(sender: self, title: nil, messageText: message, actions: [actionCancel, actionOK])
    }
    
    @IBAction func autosortAction(_ sender: UISwitch) {
        UserDefaults.isAutosortEnabled = sender.isOn
        autosortMenuButton.isEnabled = UserDefaults.isAutosortEnabled
    }
}

// MARK: - Private
private extension ProfileViewController {
    func setupUI() {
        title = "Profile"
        
        backButton.setup(type: .back)
        backButton.addTarget(self, action: #selector(actionBackPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        bottomView.addShadow()
        
        autosortSwitch.isOn = UserDefaults.isAutosortEnabled
        let menu = viewModel
            .createAutosortMenuActions { [weak self] heuristic in
                self?.autosortMenuButton.setTitle(heuristic.title, for: .normal)
            }
        if let selectedHeuristic = Heuristic(rawValue: UserDefaults.autosortType) {
            autosortMenuButton.setTitle(selectedHeuristic.title, for: .normal)
        }
        autosortMenuButton.menu = UIMenu(title: "Choose Auto-Organize",
                                         image: nil,
                                         identifier: nil,
                                         options: [],
                                         children: menu)
        autosortMenuButton.showsMenuAsPrimaryAction = true
       
        guard let user = LocalManager.shared.user else { return }
        profileNameLabel.attributedText = (user.firstName + " " + user.lastName).attribute(Constants.titleAttribute)
        emailLabel.attributedText = user.emailAddress.attribute(Constants.emailAttribute)
    }
}
