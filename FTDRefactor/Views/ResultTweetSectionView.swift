//
//  ResultTweetSectionView.swift
//  FTDRefactor
//
//  Created by Jon E on 7/14/21.
//  Copyright © 2021 Jon E. All rights reserved.
//

import UIKit

class ResultTweetSectionView: UIView {
    
    var resultText: String!
    var isAuthenticationFieldReal: Bool!
    let resultTitleLabel = UILabel()
    let resultTextLabel = UILabel()
    var title: String!
    
    init(title: String, resultText: String, isAuthenticationFieldReal: Bool) {
        super.init(frame: .zero)
        self.title = title
        self.resultText = resultText
        self.isAuthenticationFieldReal = isAuthenticationFieldReal
        configureResultTitle()
        configureResultText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureResultTitle() {
        addSubview(resultTitleLabel)
        resultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        resultTitleLabel.attributedText = NSAttributedString(string: title, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        resultTitleLabel.font = .boldSystemFont(ofSize: 30)
        
        if isAuthenticationFieldReal {
            resultTitleLabel.textColor = .systemGreen
        } else {
            resultTitleLabel.textColor = .systemRed
        }
        
        resultTitleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        resultTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        resultTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    private func configureResultText() {
        addSubview(resultTextLabel)
        resultTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let resultText = resultText ?? "\(title ?? "Result") NOT FOUND"
        resultTextLabel.text = resultText
        resultTextLabel.font = .systemFont(ofSize: 30, weight: .thin)
        resultTextLabel.numberOfLines = 10
        resultTextLabel.adjustsFontSizeToFitWidth = true
        
        resultTextLabel.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 5).isActive = true
        resultTextLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        resultTextLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 0)
    }
}
