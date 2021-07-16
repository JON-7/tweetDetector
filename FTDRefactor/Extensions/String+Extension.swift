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
}
