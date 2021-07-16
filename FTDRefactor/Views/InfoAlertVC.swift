//
//  InfoAlertVC.swift
//  FTDRefactor
//
//  Created by Jon E on 1/13/21.
//  Copyright © 2021 Jon E. All rights reserved.
//

import UIKit

class InfoAlertVC: UIViewController {
    
    let containerView = UIView()
    let acTitle = UILabel()
    let acMessage = UILabel()
    let acButton = FTDButton()
    let padding: CGFloat = 20
    let backgroundColor = CustomColors.myColors
    let textColor = CustomColors.textColor
    
    var alertTitle: String?
    var message: String?
    var buttonTitle: String?
    
    init(title: String, message: String, buttonTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.buttonTitle = buttonTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.95)
        configureContainerView()
        configureTitleLabel()
        configureMessageLabel()
        configureACButton()
    }
    
    func configureContainerView() {
        view.addSubview(containerView)
        containerView.backgroundColor = backgroundColor
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -padding),
            containerView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    func configureTitleLabel() {
        containerView.addSubview(acTitle)
        acTitle.translatesAutoresizingMaskIntoConstraints = false
        acTitle.text = alertTitle ?? "Alert"
        acTitle.textAlignment = .center
        acTitle.textColor = textColor
        acTitle.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        
        NSLayoutConstraint.activate([
            acTitle.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding + 10),
            acTitle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            acTitle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            acTitle.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configureACButton() {
        containerView.addSubview(acButton)
        acButton.translatesAutoresizingMaskIntoConstraints = false
        acButton.setTitle(buttonTitle, for: .normal)
        acButton.layer.cornerRadius = 25
        
        NSLayoutConstraint.activate([
            acButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding * 2),
            acButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            acButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            acButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configureMessageLabel() {
        containerView.addSubview(acMessage)
        acMessage.translatesAutoresizingMaskIntoConstraints = false
        acMessage.text = message ?? "NO MESSAGE"
        acMessage.textAlignment = .center
        acMessage.textColor = textColor
        acMessage.font = .preferredFont(forTextStyle: .title3)
        acMessage.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            acMessage.topAnchor.constraint(equalTo: acTitle.bottomAnchor, constant: padding * 1.5),
            acMessage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            acMessage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding)
        ])
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
}
