//
//  UINavigationViewController+Extension.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/3/22.
//

import UIKit

extension UINavigationController {
    static func create(rootViewController controller: UIViewController,
                       color: UIColor = UIColor.clear,
                       shadowColor: UIColor = UIColor.clear) -> UINavigationController {
        let navigation = UINavigationController(rootViewController: controller)
        navigation.navigationBar.isTranslucent = true

        navigation.navigationBar.tintColor = UIColor.black
        navigation.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBackground]
        navigation.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBackground]

        navigation.navigationBar.barTintColor = color
        navigation.view.backgroundColor = color

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        appearance.shadowColor = shadowColor

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        return navigation
    }

    func appearance(with color: UIColor = UIColor.clear, shadowColor: UIColor = UIColor.clear) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        appearance.shadowColor = shadowColor

        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.brandBoldFont(ofSize: 14)]

        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
    }
}
