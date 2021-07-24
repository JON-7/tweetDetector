//
//  ResultVC.swift
//  FTDRefactor
//
//  Created by Jon E on 8/21/20.
//  Copyright © 2020 Jon E. All rights reserved.
//

import UIKit

class ResultVC: UIViewController {
    
    var image = UIImage()
    var authentication = Authentication()
    let indicator = UIActivityIndicatorView.Style.large
    
    private var finalResultView = FinalResultViewController(authentication: Authentication())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CustomColors.myColors
        self.showSpinner()
        self.analyzeTweet()
    }
    
    private func addFinalResultView() {
        finalResultView = FinalResultViewController(authentication: authentication)
        addChild(finalResultView)
        view.addSubview(finalResultView.view)
        finalResultView.didMove(toParent: self)
        finalResultView.view.bounds = view.bounds
    }
    
    func analyzeTweet() {
        let group = DispatchGroup()
        let dispatchQueue = DispatchQueue.global(qos: .background)
        // formating to base64
        let imageFile = self.image.jpegData(compressionQuality: 0.8)?.base64EncodedString() ?? ""
        
        dispatchQueue.async {
            group.enter()
            // retrieving data from the ocr
            NetworkManager.shared.OCRTweet(image: imageFile) { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.presentErrors(title: "Error", message: error.rawValue, buttonTitle: "Scan again")
                    return
                case .success(let tweet):
                    self?.setOCRAuthentications(for: tweet)
                    if self?.authentication.ocrTweetText == "NO TEXT FOUND" {
                        self?.presentErrors(title: "No Text Found", message: "Please retake photo", buttonTitle: "Scan again")
                    }
                }
                
                NetworkManager.shared.getTwitterID(username: self?.authentication.ocrUsername ?? "") { [weak self] result in
                    switch result {
                    case .success(let twitterID):
                        self?.authentication.twitterID = twitterID
                        self?.authentication.isHandleReal = true
                    case .failure(let error):
                        self?.presentErrors(title: "Error", message: error.rawValue, buttonTitle: "Scan again")
                        return
                    }
                    
                    let formattedDate = getTweetTime(ocrTime: self?.authentication.ocrFormattedDate ?? "")
                    let tweetTimeFrame = getStartEndTime(tweetTime: formattedDate)
                    let startSearchTime = tweetTimeFrame["startTime"] ?? ""
                    let endSearchTime = tweetTimeFrame["endTime"] ?? ""
                    
                    NetworkManager.shared.getUserTweets(id: self?.authentication.twitterID ?? "", startTime: startSearchTime, endTime: endSearchTime) { [weak self] result in
                        switch result {
                        case .success(let tweets):
                            self?.setFinalResults(for: tweets)
                        case .failure(_):
                            self?.authentication.isDateReal = false
                            self?.authentication.apiTweetText = self?.authentication.ocrTweetText ?? "Tweet not found"
                        }
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                self.removeSpinner()
                self.addFinalResultView()
            }
        }
    }
    
    func setOCRAuthentications(for tweet: String) {
        self.authentication.ocrFullText = tweet
        self.authentication.ocrUsernameInfo = getUsernameAndIndex(ocrText: tweet)
        if self.authentication.ocrUsernameInfo == nil {
            self.presentErrors(title: "Error", message: "Username not found", buttonTitle: "Scan again")
            return
        }
        
        self.authentication.ocrUsername = self.authentication.ocrUsernameInfo?["username"] as? String ?? ""
        self.authentication.ocrDate = getDate(text: tweet)
        self.authentication.ocrFormattedDate = self.authentication.ocrDate?.replacingOccurrences(of: "-", with: " ")
        self.authentication.ocrTweetText = getText(text: tweet, date: self.authentication.ocrDate ?? "NO DATE" , usernameIndex: self.authentication.ocrUsernameInfo?["usernameIndex"] as! Int).trimmingCharacters(in: .whitespaces)
        
        if self.authentication.ocrTweetText == "ERROR" {
            return
        }
    }
    
    func setFinalResults(for tweets: [TweetData]) {
        for n in 0..<tweets.count {
            guard let a = self.authentication.ocrTweetText?.lowercased() else { return }
            let b = tweets[n].text.lowercased()

            if a.cleanString() == b.cleanString(){
                self.authentication.isBodyReal = true
                self.authentication.apiTweetText = tweets[n].text
                self.authentication.tweetDate = tweets[n].created_at
            }
        }
        
        if compareDate(twitterTime: self.authentication.tweetDate ?? "NO DATE" , OCRTime: self.authentication.ocrFormattedDate ?? "NO DATE" ) {
            self.authentication.isDateReal = true
        } else {
            self.authentication.isDateReal = false
            self.presentErrors(title: "Retake Photo", message: "Please retake the picture", buttonTitle: "OK")
        }
    }
    
    @objc func dismissView() {
        let first = FirstVC()
        first.modalPresentationStyle = .fullScreen
        present(first, animated: true)
    }
    
    func presentErrors(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertVC = InfoAlertVC(title: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            alertVC.acButton.addTarget(self, action: #selector(self.dismissVC), for: .touchUpInside)
            self.present(alertVC, animated: true)
        }
    }
    
    @objc func dismissVC() {
        let firstVC = FirstVC()
        firstVC.modalPresentationStyle = .fullScreen
        dismiss(animated: true)
        present(firstVC, animated: true)
    }
}
