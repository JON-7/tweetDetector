//
//  FinalResultViewController.swift
//  FTDRefactor
//
//  Created by Jon E on 7/14/21.
//  Copyright © 2021 Jon E. All rights reserved.
//

import UIKit

class FinalResultViewController: UIViewController {
    
    let authentication: Authentication!
    let tweetResultTitle = UILabel()
    let tweetResultImage = UIImageView()
    var usernameResultView = UIView()
    var tweetTextResultView = UIView()
    var dateResultView = UIView()
    let scanAgainButton = FTDButton(text: "Scan Again")
    
    init(authentication: Authentication) {
        self.authentication = authentication
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureResultTitleAndImage()
        configureUsernameResult()
        configureDateResult()
        configureScanAgainButton()
        configureTweetTextResult()
    }
    
    private func configureResultTitleAndImage() {
        view.addSubview(tweetResultTitle)
        tweetResultTitle.translatesAutoresizingMaskIntoConstraints = false
        tweetResultTitle.textAlignment = .center
        tweetResultTitle.font = UIFont.boldSystemFont(ofSize: 35)
        tweetResultTitle.textColor = CustomColors.textColor
        
        view.addSubview(tweetResultImage)
        tweetResultImage.translatesAutoresizingMaskIntoConstraints = false
        tweetResultImage.contentMode = .scaleAspectFit
        
        if authentication.isBodyReal && authentication.isDateReal && authentication.isHandleReal {
            tweetResultTitle.text = "REAL TWEET"
            tweetResultTitle.textColor = .systemGreen
            tweetResultImage.image = Images.realTweetImage
        } else {
            tweetResultTitle.text = "FAKE TWEET"
            tweetResultTitle.textColor = .systemRed
            tweetResultImage.image = Images.fakeTweetImage
        }
        
        NSLayoutConstraint.activate([
            tweetResultTitle.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 10),
            tweetResultTitle.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            tweetResultTitle.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20),
            tweetResultTitle.heightAnchor.constraint(equalToConstant: 30),
            
            tweetResultImage.topAnchor.constraint(equalTo: tweetResultTitle.bottomAnchor, constant: 5),
            tweetResultImage.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 30),
            tweetResultImage.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -30),
            tweetResultImage.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func configureUsernameResult() {
        let usernameResult = ResultTweetSectionView(title: "Username", resultText: authentication.ocrUsername ?? "", isAuthenticationFieldReal: authentication.isHandleReal)
        usernameResultView = usernameResult
        view.addSubview(usernameResultView)
        usernameResultView.translatesAutoresizingMaskIntoConstraints = false
        
        usernameResultView.topAnchor.constraint(equalTo: tweetResultImage.bottomAnchor, constant: 10).isActive = true
        usernameResultView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20).isActive = true
        usernameResultView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20).isActive = true
        
        usernameResultView.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.09).isActive = true
    }
    
    private func configureDateResult() {
        let dateResult = ResultTweetSectionView(title: "Date", resultText: authentication.ocrFormattedDate ?? "", isAuthenticationFieldReal: authentication.isDateReal)
        dateResultView = dateResult
        view.addSubview(dateResultView)
        dateResultView.translatesAutoresizingMaskIntoConstraints = false
        
        dateResultView.topAnchor.constraint(equalTo: usernameResultView.bottomAnchor, constant: 10).isActive = true
        dateResultView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20).isActive = true
        dateResultView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20).isActive = true
        dateResultView.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.09).isActive = true
    }
    
    private func configureTweetTextResult() {
        let tweetTextResult = ResultTweetSectionView(title: "Tweet", resultText: authentication.apiTweetText ?? "", isAuthenticationFieldReal: authentication.isBodyReal)
        tweetTextResultView = tweetTextResult
        view.addSubview(tweetTextResultView)
        tweetTextResultView.translatesAutoresizingMaskIntoConstraints = false
        
        tweetTextResultView.topAnchor.constraint(equalTo: dateResultView.bottomAnchor, constant: 20).isActive = true
        tweetTextResultView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20).isActive = true
        tweetTextResultView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20).isActive = true
        
        if authentication.apiTweetText?.count ?? 0 > 120 {
            tweetTextResult.resultTextLabel.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.2).isActive = true
        }
    }
    
    private func configureScanAgainButton() {
        view.addSubview(scanAgainButton)
        NSLayoutConstraint.activate([
            scanAgainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanAgainButton.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.9),
            scanAgainButton.heightAnchor.constraint(equalToConstant: 60),
            scanAgainButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -40)
        ])
        scanAgainButton.addTarget(self, action: #selector(showHomeView), for: .touchUpInside)
    }
    
    @objc func showHomeView() {
        let first = FirstVC()
        first.modalPresentationStyle = .fullScreen
        present(first, animated: true)
    }
}
