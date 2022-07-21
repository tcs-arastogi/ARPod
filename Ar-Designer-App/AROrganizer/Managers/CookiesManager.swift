//
//  CookiesManager.swift
//  AROrganizer-Develop
//
//  Created by Yurii Goroshenko on 6/15/22.
//

import Foundation

final class CookiesManager {
    static func store(_ baseUrl: String) {
        let cookiesStorage = HTTPCookieStorage.shared
        let userDefaults = UserDefaults.standard
        var cookieDict = [String : AnyObject]()
        
        for cookie in cookiesStorage.cookies(for: NSURL(string: baseUrl)! as URL)! {
            cookieDict[cookie.name] = cookie.properties as AnyObject?
        }
        
        userDefaults.set(cookieDict, forKey: "cookiesKey")
    }
    
    static func restore() {
        let cookiesStorage = HTTPCookieStorage.shared
        let userDefaults = UserDefaults.standard
        
        if let cookieDictionary = userDefaults.dictionary(forKey: "cookiesKey") {
            
            for (_, cookieProperties) in cookieDictionary {
                if let properties = cookieProperties as? [HTTPCookiePropertyKey: Any], let cookie = HTTPCookie(properties: properties) {
                    cookiesStorage.setCookie(cookie)
                }
            }
        }
    }
}
