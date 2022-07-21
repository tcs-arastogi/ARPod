//
//  LoginViewController.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/2/22.
//

import UIKit

final class LoginViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signInButton: UIButton!
    let viewModel: LoginViewModelInputProtocol
    
    // MARK: - Lifecycle
    deinit {
        debugPrintLog("deinit -> ", self)
    }
    
    init(viewModel: LoginViewModelInputProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(viewModel: LoginViewModel())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    func refreshState() {
        signInButton.loadingIndicator(false, textColor: .white)
    }
    
    func showErrorMessage(_ message: String) {
        refreshState()
        AlertMessageManager.show(sender: self, messageText: message)
    }
}

// MARK: - Actions
extension LoginViewController {
    @IBAction func actionSignInPressed(_ sender: Any) {
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            email.isValidEmail && password.isValidPassword
        else { return }
        
        signInButton.loadingIndicator(true, textColor: .clear)
        [emailTextField, passwordTextField].forEach { $0?.resignFirstResponder() }
        viewModel.didFinishEnter(email: email, password: password)
    }
    
    @IBAction func emailDidChange(_ sender: Any) {
        checkStateButton()
    }
    
    @IBAction func passwordDidChange(_ sender: Any) {
        checkStateButton()
    }
}

// MARK: - Private
private extension LoginViewController {
    func setupUI() {
//// #if DEBUG
        emailTextField.text = "qatest@test.com"
        passwordTextField.text = "qqqqqq!!"
//// #endif
        checkStateButton()
    }
    
    func checkStateButton() {
        guard
            emailTextField.text?.isValidEmail ?? false,
            passwordTextField.text?.isValidPassword ?? false
        else {
            signInButton.inActive()
            return
        }
        
        signInButton.active()
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        
        case passwordTextField:
            actionSignInPressed(self)
            
        default:
            break
        }
        
        return true
    }
}
