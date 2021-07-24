//
//  String+Extension.swift
//  FTDRefactor
//
//  Created by Jon E on 7/13/21.
//  Copyright © 2021 Jon E. All rights reserved.
//

import UIKit

extension String {
    var underLined: NSAttributedString {
        NSMutableAttributedString(string: self, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
    
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func cleanString() -> String {
        let specialCharacterSet = CharacterSet(charactersIn: "• ' ’")
        var cleanString = self.components(separatedBy: .whitespacesAndNewlines).joined()
        cleanString = cleanString.components(separatedBy: specialCharacterSet).joined()
        return cleanString
    }
}
