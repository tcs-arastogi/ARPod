//
//  AlertMessage.swift
//
//  Created by ygoroshenko on 4/7/17.

import UIKit

/*
 1)
 AlertMessage.show(sender: self, messageText: "<text>")
 
 2)
 let actionCancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
 let actionSettings = UIAlertAction(title: "settings", style: .default, handler: { _ in
 UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
 })
 AlertMessage.show(sender: self, messageText: "please_allow_camera_permission", actions: [actionCancel, actionSettings])
 */

struct AlertTextField {
    var placeholder: String?
    var keyboardType: UIKeyboardType
    var message: String?
    var value: String?
    var action: (title: String, completionHandler: AlertMessageManager.ActionTextCompletionHandler)?
}

final class AlertMessageManager {
    typealias ActionCompletionHandler = (String?) -> Void
    typealias ActionTextCompletionHandler = (String) -> Void

    // MARK: - Private properties
    private static let actionOk = "OK"
    private static let actionCancel = "Cancel"

    // MARK: - Private functions
    private static func presentDefaultAlert(_ alert: UIAlertController, sender: UIViewController) {
        let action = UIAlertAction(title: AlertMessageManager.actionOk, style: .default, handler: nil)
        alert.addAction(action)

        DispatchQueue.main.async {
            sender.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Public functions
    static func show(sender: UIViewController, title: String? = "", messageText: String?,
                     actions: [UIAlertAction]? = nil, style: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: messageText, preferredStyle: style)
        guard let actions = actions else { return presentDefaultAlert(alert, sender: sender) }

        for action in actions {
            alert.addAction(action)
        }

        DispatchQueue.main.async {
            sender.present(alert, animated: true, completion: nil)
        }
    }

    static func showWithTextField(sender: UIViewController, alertTextField: AlertTextField) {
        let alert = UIAlertController(title: nil, message: alertTextField.message, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: AlertMessageManager.actionCancel, style: .cancel, handler: nil)
        let actionSend = UIAlertAction(title: alertTextField.action?.title, style: .default, handler: { _ -> Void in
            let textField = (alert.textFields?.first ?? UITextField()) as UITextField
            guard let text = textField.text else { return }
            
            alertTextField.action?.completionHandler(text)
        })

        alert.addTextField { (textField: UITextField?) -> Void in
            guard let textField = textField else { return }
            textField.text = alertTextField.value
            textField.placeholder = alertTextField.placeholder
            textField.keyboardType = alertTextField.keyboardType
        }

        alert.addAction(actionCancel)
        alert.addAction(actionSend)

        DispatchQueue.main.async {
            sender.present(alert, animated: true, completion: nil)
        }
    }

    static func showActionSheet(sender: UIViewController, messageText: String?,
                                actions: [(title: String, completionHandler: ActionCompletionHandler)]?) {
        let alert = UIAlertController(title: nil, message: messageText, preferredStyle: .actionSheet)
        let actionCancel = UIAlertAction(title: AlertMessageManager.actionCancel, style: .cancel, handler: nil)

        actions?.forEach { (title, actionCompletionHandler) in
            let action = UIAlertAction(title: title, style: .default) { _ in
                actionCompletionHandler(title)
            }
            alert.addAction(action)
        }

        alert.addAction(actionCancel)

        DispatchQueue.main.async {
            sender.present(alert, animated: true, completion: nil)
        }
    }

    static func showSettingsAlert(sender: UIViewController,
                                  message: String,
                                  settingActionTitle: String = "more_settings",
                                  cancelActionTitle: String = "cancel",
                                  cancelHandler: (() -> Void)? = nil) {
        let settingsAction = UIAlertAction(title: settingActionTitle, style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .default, handler: { _ in cancelHandler?() })
        show(sender: sender, messageText: message, actions: [cancelAction, settingsAction])
    }
}
