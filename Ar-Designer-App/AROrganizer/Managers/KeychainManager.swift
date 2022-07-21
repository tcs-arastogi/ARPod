//
//  KeychainManager.swift
//
//  Created by Yurii Goroshenko on 19.04.2022.

//

import Foundation
import Security

final class KeychainManager {
    enum KeychainValueType: String {
        case token
        case userID
        // TODO: - temp solution
        case email
        case password
    }

    private static let service = Bundle.main.infoDictionary?[kCFBundleNameKey as String] ?? ""
    private static var defaultQuery: [String: AnyObject] {
        [kSecAttrService as String: service as AnyObject,
         kSecClass as String: kSecClassGenericPassword]
    }

    // MARK: - Public
    static func delete(type: KeychainValueType?) {
        var query = defaultQuery
        if let type = type {
            query[kSecAttrType as String] = type.rawValue as AnyObject
        }

        let status = SecItemDelete(query as CFDictionary)

        guard parseStatus(status: status, type: type) else { return }
        debugPrintLog("Keychain key[\(type?.rawValue ?? "all")]: Deleted")
    }

    static func deleteAll() {
        delete(type: .userID)
        delete(type: .token)
        delete(type: .password)
    }
}

// MARK: - Data
extension KeychainManager {
    static func save(data: Data, type: KeychainValueType) {
        var query = defaultQuery
        query[kSecAttrAccount as String] = type.rawValue as AnyObject
        query[kSecAttrType as String] = type.rawValue as AnyObject
        query[kSecValueData as String] = data as AnyObject

        let status = SecItemAdd(query as CFDictionary, nil)
        guard parseStatus(status: status, type: type) else { return }
        debugPrintLog("Keychain key[\(type.rawValue)]: Added")
    }

    static func getDataValue(type: KeychainValueType) -> Data? {
        var query = defaultQuery
        query[kSecAttrType as String] = type.rawValue as AnyObject
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)

        guard parseStatus(status: status, type: type) else { return nil }
        guard let result = itemCopy as? Data else {
            debugPrintLog("Keychain key[\(type.rawValue)]: invalid format")
            return nil
        }

        return result
    }
}

// MARK: - String
extension KeychainManager {
    static func save(value: String, type: KeychainValueType) {
        guard let data = value.data(using: .utf8, allowLossyConversion: false) else { return }
        var query = defaultQuery
        
        query[kSecAttrAccount as String] = type.rawValue as AnyObject
        query[kSecAttrType as String] = type.rawValue as AnyObject
        query[kSecValueData as String] = data as AnyObject

        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard parseStatus(status: status, type: type) else { return }
        debugPrintLog("Keychain key[\(type.rawValue)]: Added")
    }

    static func update(value: String, type: KeychainValueType) {
        guard let data = value.data(using: .utf8, allowLossyConversion: false) else { return }
        var query = defaultQuery
        query[kSecAttrType as String] = type.rawValue as AnyObject

        let attributes: [String: AnyObject] = [kSecValueData as String: data as AnyObject]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        guard parseStatus(status: status, type: type) else { return }
        debugPrintLog("Keychain key[\(type.rawValue)]: Updated")
    }

    static func getValue(type: KeychainValueType) -> String? {
        var query = defaultQuery
        query[kSecAttrType as String] = type.rawValue as AnyObject
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)

        guard parseStatus(status: status, type: type) else { return nil }
        guard let result = itemCopy as? Data else {
            debugPrintLog("Keychain key[\(type.rawValue)]: invalid format")
            return nil
        }

        return String(data: result, encoding: .utf8)
    }
}

// MARK: - Private
private extension KeychainManager {
    static func parseStatus(status: OSStatus, type: KeychainValueType?) -> Bool {
        let keyString = type?.rawValue ?? "all"
        guard status != errSecItemNotFound else {
            debugPrintLog("Keychain key[" + keyString + "]: item not found")
            return false
        }

        if status == errSecDuplicateItem {
            debugPrintLog("Keychain key[" + keyString + "]: duplicate")
            return false
        }

        guard status == errSecSuccess else {
            debugPrintLog("Keychain key[" + keyString + "]: error code \(status)")
            return false
        }

        return true
    }
}
