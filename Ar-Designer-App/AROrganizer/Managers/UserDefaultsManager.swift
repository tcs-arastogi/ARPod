//
//  UserDefaultsManager.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/4/22.
//

import Foundation

extension UserDefaults {
    private enum Key: String {
        case isLoggedIn
        case cookies
        case isAutosortEnabled
        case autosortType
        case userID
    }

    // MARK: - Properties
    class var isLoggedIn: Bool? {
        get { UserDefaults.standard.object(forKey: Key.isLoggedIn.rawValue) as? Bool }
        set { UserDefaults.standard.setValue(newValue, forKey: Key.isLoggedIn.rawValue) }
    }
    
    class var isCookies: Bool? {
        get { UserDefaults.standard.object(forKey: Key.cookies.rawValue) as? Bool }
        set { UserDefaults.standard.setValue(newValue, forKey: Key.cookies.rawValue) }
    }
    
    class var isAutosortEnabled: Bool {
        get { UserDefaults.standard.object(forKey: Key.isAutosortEnabled.rawValue) as? Bool ?? true }
        set { UserDefaults.standard.setValue(newValue, forKey: Key.isAutosortEnabled.rawValue) }
    }
    
    class var autosortType: String {
        get { UserDefaults.standard.object(forKey: Key.autosortType.rawValue) as? String ?? Heuristic.default.rawValue }
        set { UserDefaults.standard.setValue(newValue, forKey: Key.autosortType.rawValue) }
    }
    
    class var userID: String {
        get { UserDefaults.standard.object(forKey: Key.userID.rawValue) as? String ?? "-1" }
        set { UserDefaults.standard.setValue(newValue, forKey: Key.userID.rawValue) }
    }
}
