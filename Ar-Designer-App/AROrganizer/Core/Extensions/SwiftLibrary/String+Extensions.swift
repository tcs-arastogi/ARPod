//
//  String+Extensions.swift
//  ARDesignerApp
//
//  Created by Mykhailo Lysenko on 6/1/22.
//

import Foundation

extension String {
    static func randomString(_ len: Int = 15) -> String {
        let charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let c = Array(charSet)
        var s: String = ""
        for _ in (1...len) {
            s.append(c[Int(arc4random()) % c.count])
        }
        return s
    }
    
    var isValidEmail: Bool {
        return self.range(of: #"^\S+@\S+\.\S+$"#, options: .regularExpression) != nil
    }

    var isValidPassword: Bool {
        return self.count > 4
    }
}

extension String {
    func attribute(_ attribute: TextAttribute) -> NSAttributedString {
        let attributes = attribute.attributes
        return NSAttributedString(string: self, attributes: attributes)
    }

    func trimSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}

extension NSAttributedString {
    func add(_ attributedString: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        result.append(attributedString)
        return result
    }
}

/// Project name autoincrement
extension String {
    var incrementedName: String {
        let pattern = "\\d+"
        guard
            let regex = try? NSRegularExpression(pattern: pattern, options: []),
            let numberStr = self.components(separatedBy: " ").last,
            let match = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count)).last,
            let baseIntValue = Int((self as NSString).substring(with: match.range))
        else { return self + "Project1" }
        
        let incrementedValueString = String(baseIntValue + 1)
        let valueToReplace = String(baseIntValue)
        let incremented = numberStr.replacingOccurrences(of: valueToReplace, with: incrementedValueString)
        return self.replacingOccurrences(of: numberStr, with: incremented)
    }
}
