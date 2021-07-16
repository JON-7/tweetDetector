//
//  FTDButton.swift
//  FTDRefactor
//
//  Created by Jon E on 8/18/20.
//  Copyright © 2020 Jon E. All rights reserved.
//

import UIKit

class FTDButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(text: String) {
        super.init(frame: .zero)
        self.setTitle(text, for: .normal)
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.init(red: 76/255, green: 158/255, blue: 236/255, alpha: 1)
        layer.cornerRadius = 30
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.textAlignment = .center
    }
}
