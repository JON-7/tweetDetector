//
//  ScanImageVC.swift
//  FTDRefactor
//
//  Created by Jon E on 1/13/21.
//  Copyright © 2021 Jon E. All rights reserved.
//

import UIKit

class ScanImageVC: UIViewController {
    
    let imageView = UIImageView()
    var userImage = UIImage()
    let backButton = UIButton()
    let scanButton = FTDButton(text: "Scan")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CustomColors.myColors
        configureScanButton()
        configureImageView()
        configureBackButton()
    }
    
    func configureScanButton() {
        view.addSubview(scanButton)
        NSLayoutConstraint.activate([
            scanButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            scanButton.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.9),
            scanButton.heightAnchor.constraint(equalToConstant: 60),
            scanButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -40)
        ])
        scanButton.addTarget(self, action: #selector(showResults), for: .touchUpInside)
    }
    
    func configureImageView() {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = userImage
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 60),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            imageView.bottomAnchor.constraint(equalTo: scanButton.topAnchor, constant: -40)
        ])
    }
    
    func configureBackButton() {
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 25)
        backButton.setImage(UIImage(systemName: Images.backArrow, withConfiguration: buttonConfig), for: .normal)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0),
            backButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
    }
    
    @objc func dismissView() {
        let firstVC = FirstVC()
        firstVC.modalPresentationStyle = .fullScreen
        present(firstVC, animated: true)
    }
    
    @objc func showResults() {
        let resultVC = ResultVC()
        resultVC.image = self.userImage
        resultVC.modalPresentationStyle = .fullScreen
        present(resultVC, animated: true)
    }
}
