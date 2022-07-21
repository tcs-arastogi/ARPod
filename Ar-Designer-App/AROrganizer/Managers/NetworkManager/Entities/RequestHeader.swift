//
//  RequestHeader.swift
//

import UIKit
import Foundation

struct RequestHeader {
    static func headers(with token: Bool = true) -> [String: String] {
//        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
//        + "(\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""))"
        
        let headers = ["Platform": "iOS",
                       "Accept-Language": "en",
//                       "Version-App": appVersion,
                       "Version-Device-SDK": UIDevice.current.systemVersion,
                       "Device-UID": UIDevice.current.identifierForVendor?.uuidString ?? "-1",
                       "Content-Type": "application/json"]
        
        return headers
    }
}
