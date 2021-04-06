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
    let resultLabel = UILabel()
    let usernameLabel = UILabel()
    let usernameResultLabel = UILabel()
    let tweetLabel = UILabel()
    let tweetLabelResult = UILabel()
    let dateLabel = UILabel()
    let dateResultLabel = UILabel()
    let scanAgainButton = FTDButton(text: "Scan Again")
    var authentication = Authentication()
    let indicator = UIActivityIndicatorView.Style.large
    let resultImage = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "myColors")
        self.showSpinner()
        self.analyzeTweet()
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
                    self?.authentication.ocrFullText = tweet
                    self?.authentication.ocrUsernameInfo = self?.getUsername(ocrText: tweet)
                    if self?.authentication.ocrUsernameInfo == nil {
                        self?.presentErrors(title: "Error", message: "Username not found", buttonTitle: "Scan again")
                        return
                    }
                    
                    self?.authentication.ocrUsername = self?.authentication.ocrUsernameInfo?["username"] as? String ?? ""
                    self?.authentication.ocrDate = self?.getDate(text: tweet) ?? "NO DATE"
                    self?.authentication.ocrFormattedDate = self?.authentication.ocrDate?.replacingOccurrences(of: "-", with: " ")
                    self?.authentication.ocrTweetText = self?.getText(text: tweet, date: self?.authentication.ocrDate ?? "NO DATE" , usernameIndex: self?.authentication.ocrUsernameInfo?["usernameIndex"] as! Int).trimmingCharacters(in: .whitespaces) ?? "NO DATE"
                    
                    if self?.authentication.ocrTweetText == "ERROR" {
                        return
                    }
                }
                
                NetworkManager.shared.getTwitterID(username: self?.authentication.ocrUsernameInfo?["username"] as! String) { [weak self] result in
                    switch result {
                    case .success(let twitterID):
                        self?.authentication.twitterID = twitterID
                        self?.authentication.isHandleReal = true
                    case .failure(let error):
                        self?.presentErrors(title: "Error", message: error.rawValue, buttonTitle: "Scan again")
                        return
                    }
                    
                    let start = self?.getStartEndTime(ocrTime: self?.authentication.ocrFormattedDate ?? "" )["startTime"] ?? "0"
                    let end = self?.getStartEndTime(ocrTime: self?.authentication.ocrFormattedDate ?? "" )["endTime"] ?? "0"
                    
                    NetworkManager.shared.getUserTweets(id: self?.authentication.twitterID ?? "", startTime: start, endTime: end) { [weak self] result in
                        switch result {
                        case .success(let tweets):
                            for n in 0..<tweets.count {
                                
                                guard let a = self?.authentication.ocrTweetText?.lowercased() else { return }
                                let b = tweets[n].text.lowercased()
                                if ((a.contains(b))) {
                                    self?.authentication.isBodyReal = true
                                    self?.authentication.apiTweetText = tweets[n].text
                                    self?.authentication.tweetDate = tweets[n].created_at
                                }
                            }
                            
                            //check to see if the two dates are a match
                            
                            if self!.compareDate(twitterTime: self!.authentication.tweetDate ?? "NO DATE" , OCRTime: self!.authentication.ocrFormattedDate ?? "NO DATE" ) {
                                self!.authentication.isDateReal = true
                            } else {
                                self!.authentication.isDateReal = false
                                self?.presentErrors(title: "Error", message: "Please retake the picture", buttonTitle: "OK")
                            }
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
                self.configureView()
            }
        }
    }
    
    func configureScanButton() {
        view.addSubview(scanAgainButton)
        NSLayoutConstraint.activate([
            scanAgainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanAgainButton.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.9),
            scanAgainButton.heightAnchor.constraint(equalToConstant: 60),
            scanAgainButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -40)
        ])
        scanAgainButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
    }
    
    func configureResultLabel() {
        view.addSubview(resultLabel)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont.boldSystemFont(ofSize: 35)
        resultLabel.textColor = UIColor(named: "textColors")
        
        if authentication.isBodyReal && authentication.isDateReal && authentication.isHandleReal {
            resultLabel.text = "REAL TWEET"
            resultLabel.textColor = .systemGreen
        } else {
            resultLabel.text = "FAKE TWEET"
            resultLabel.textColor = .systemRed
        }
        
        
        
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 10),
            resultLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20),
            resultLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configureImage() {
        view.addSubview(resultImage)
        resultImage.translatesAutoresizingMaskIntoConstraints = false
        resultImage.contentMode = .scaleAspectFit
        if authentication.isBodyReal && authentication.isDateReal && authentication.isHandleReal {
            resultImage.image = UIImage(named: "realTweetImage")
        } else {
            resultImage.image = UIImage(named: "fakeTweetImage")
        }
        
        NSLayoutConstraint.activate([
            resultImage.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 5),
            resultImage.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 30),
            resultImage.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -30),
            resultImage.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    func configureUsernameLabel() {
        view.addSubview(usernameLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.attributedText = NSAttributedString(string: "Username", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        usernameLabel.font = .boldSystemFont(ofSize: 30)
        
        if authentication.isHandleReal {
            usernameLabel.textColor = .systemGreen
        } else {
            usernameLabel.textColor = .systemRed
        }
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: resultImage.bottomAnchor, constant: 10),
            usernameLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
        ])
    }
    
    func configureUsernameResult() {
        view.addSubview(usernameResultLabel)
        usernameResultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let str = authentication.ocrUsername ?? "USERNAME NOT FOUND"
        
        usernameResultLabel.text = str
        usernameResultLabel.font = .systemFont(ofSize: 30, weight: .thin)
        
        NSLayoutConstraint.activate([
            usernameResultLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor),
            usernameResultLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            usernameResultLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 10),
        ])
    }
    
    func configureTweetLabel() {
        view.addSubview(tweetLabel)
        tweetLabel.translatesAutoresizingMaskIntoConstraints = false
        tweetLabel.attributedText = NSAttributedString(string: "Tweet", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        tweetLabel.font = .boldSystemFont(ofSize: 30)
        
        if authentication.isBodyReal {
            tweetLabel.textColor = .systemGreen
        } else {
            tweetLabel.textColor = .systemRed
        }
        
        NSLayoutConstraint.activate([
            tweetLabel.topAnchor.constraint(equalTo: usernameResultLabel.bottomAnchor, constant: 10),
            tweetLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
        ])
    }
    
    func configureTweetResult() {
        view.addSubview(tweetLabelResult)
        tweetLabelResult.translatesAutoresizingMaskIntoConstraints = false
        tweetLabelResult.numberOfLines = 10
        
        var str = ""
        if authentication.isBodyReal {
            str = authentication.apiTweetText ?? "TWEET NOT FOUND"
        } else {
            str = authentication.ocrTweetText ?? "TWEET NOT FOUND"
        }
        
        tweetLabelResult.text = str
        tweetLabelResult.font = .systemFont(ofSize: 30, weight: .thin)
        tweetLabelResult.adjustsFontSizeToFitWidth = true
        
        if str.count > 120 {
            NSLayoutConstraint.activate([
                tweetLabelResult.topAnchor.constraint(equalTo: tweetLabel.bottomAnchor),
                tweetLabelResult.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
                tweetLabelResult.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20),
                tweetLabelResult.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25)
            ])
        } else {
            NSLayoutConstraint.activate([
                tweetLabelResult.topAnchor.constraint(equalTo: tweetLabel.bottomAnchor),
                tweetLabelResult.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
                tweetLabelResult.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20),
            ])
        }
    }
    
    func configureDateLabel() {
        view.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.attributedText = NSAttributedString(string: "Date", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        dateLabel.font = .boldSystemFont(ofSize: 30)
        
        if authentication.isDateReal {
            dateLabel.textColor = .systemGreen
        } else {
            dateLabel.textColor = .systemRed
        }
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: tweetLabelResult.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
        ])
    }
    
    func configureDateResult() {
        view.addSubview(dateResultLabel)
        dateResultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let str = authentication.ocrFormattedDate ?? "DATE NOT FOUND"
        dateResultLabel.text = str
        dateResultLabel.font = .systemFont(ofSize: 30, weight: .thin)
        
        NSLayoutConstraint.activate([
            dateResultLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            dateResultLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20),
            dateResultLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor)
        ])
    }
    
    func configureView() {
        configureScanButton()
        configureResultLabel()
        configureImage()
        configureUsernameLabel()
        configureUsernameResult()
        configureTweetLabel()
        configureTweetResult()
        configureDateLabel()
        configureDateResult()
    }
    
    func getUsername(ocrText: String) -> [String: Any] {
        var username = ""
        var usernameIndex = 0
        let wordArray: [String] = ocrText.components(separatedBy: " ")
        
        // assigning username to the first index that contains the @ symbol
        for word in 0..<wordArray.count {
            if wordArray[word].contains("@") {
                username = wordArray[word]
                username.removeFirst()
                // retrieving the idex inorder to get the tweet text
                usernameIndex = word
                break
            } else {
                username = "NO NAME FOUND"
            }
        }
        return ["username": username, "usernameIndex": usernameIndex]
    }
    
    func getDate(text: String) -> String {
        let datePattern = "[0-9]*[:][0-9]{2}.([AaPP][Mm]).[aA-zZ]{3}.[0-9]*[,].[0-9]{4}"
        do {
            let regex = try NSRegularExpression(pattern: datePattern)
            let result = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            let mapped = result.map {
                String(text[Range($0.range, in: text)!])
            }
            let date = mapped.joined()
            return date
            
        } catch {
            return "DATE NOT FOUND"
        }
    }
    
    
    func getText(text: String, date: String, usernameIndex: Int) -> String {
        var tweetDate = ""
        var finalText = ""
        var dateIndex = 0
        
        tweetDate.append(date)
        // replacing the index that contains the data inorder to get the index where the tweet text ends
        let nameFound = text.replacingOccurrences(of: tweetDate, with: "DATEFOUND")
        
        var nameFoundArray: [String] = nameFound.components(separatedBy: " ")
        nameFoundArray.append(nameFound)
        
        for found in 0..<nameFoundArray.count {
            if nameFoundArray[found].contains("DATEFOUND") {
                dateIndex = found
                break
            }
        }
        
        if dateIndex == 0 {
            presentErrors(title: "ERROR", message: "Please take a closer picture", buttonTitle: "Scan again")
            return "ERROR"
        }
        
        nameFoundArray.removeLast(nameFoundArray.count - dateIndex)
        nameFoundArray.removeFirst(usernameIndex + 1)
        
        for n in 0..<nameFoundArray.count {
            finalText.append(nameFoundArray[n] + " ")
        }
        
        return finalText
    }
    
    
    func compareDate(twitterTime: String, OCRTime: String) -> Bool{
        
        //MARK: Time from the Twitter API
        //Format: 2021-01-07T15:00:41.000Z
        let twTimeArray = twitterTime.components(separatedBy: "-")
        
        if twTimeArray.count < 2 {
            //self.presentErrors(title: "Error", message: "Please retake photo", buttonTitle: "OK")
            return false
        }
        
        let tempTwDay = twTimeArray[2]
        
        
        let hrsMinSec = tempTwDay.components(separatedBy: ":")
        
        // min
        let twMin = hrsMinSec[1]
        
        //MARK: Time from the OCR API
        //Format: 3:00 PM · Jan 7, 2021
        
        let ocrTimeArray = OCRTime.components(separatedBy: " ")
        
        let ocrHrMin = ocrTimeArray[0]
        
        // minute
        let ocrMin = ocrHrMin.suffix(2)
        
        
        // comparing the two dates
        
        return ((twMin == ocrMin) ? true: false)
    }
    
    @objc func dismissView() {
        let first = FirstVC()
        first.modalPresentationStyle = .fullScreen
        present(first, animated: true)
    }
    
    // this is used to get the users tweets from the date in the photo
    //
    func getStartEndTime(ocrTime: String) -> [String: String] {
        // Twitter api time parameter format: 0000-00-00T00:00:00.000Z
        var startTime = ""
        var endTime = ""
        let ocrTimeArray = ocrTime.components(separatedBy: " ")
        // first element contains the hour and the minute
        let ocrHrMin = ocrTimeArray[0]
        
        // minute
        let ocrMin = ocrHrMin.suffix(2)
        
        // hour
        var ocrHour = ""
        let tempStrHr = ocrHrMin.dropLast(3)
        var tempIntHr = Int(tempStrHr) ?? 0
        
        // making sure that hour has the format: 00
        if ocrTimeArray[1] == "PM" {
            tempIntHr += 12
            ocrHour = String(tempIntHr)
        } else {
            if tempIntHr < 10 {
                ocrHour = "0" + tempStrHr
            } else {
                ocrHour = String(tempIntHr)
            }
        }
        
        // month
        var ocrMonth = ""
        let monthName = ocrTimeArray[2]
        
        // retrieving the number associated with the name of the month
        switch monthName {
        case "Jan":
            ocrMonth = "01"
        case "Feb":
            ocrMonth = "02"
        case "Mar":
            ocrMonth = "03"
        case "Apr":
            ocrMonth = "04"
        case "May":
            ocrMonth = "05"
        case "Jun":
            ocrMonth = "06"
        case "Jul":
            ocrMonth = "07"
        case "Aug":
            ocrMonth = "08"
        case "Sep":
            ocrMonth = "09"
        case "Oct":
            ocrMonth = "10"
        case "Nov":
            ocrMonth = "11"
        case "Dec":
            ocrMonth = "12"
        default:
            ocrMonth = "0"
        }
        
        // day
        var ocrDay1 = ""
        var ocrDay2 = ""
        var tempStrDay = ocrTimeArray[3]
        tempStrDay.removeLast()
        
        var tempIntDay1 = Int(tempStrDay) ?? 0
        tempIntDay1 += 1
        
        var tempIntDay2 = Int(tempStrDay) ?? 0
        tempIntDay2 -= 1
        
        // making sure that day has two digits
        if tempIntDay1 > 9 {
            ocrDay1 = String(tempIntDay1)
        } else {
            ocrDay1 = "0" + String(tempIntDay1)
        }
        
        if tempIntDay2 > 9 {
            ocrDay2 = String(tempIntDay2)
        } else {
            ocrDay2 = "0" + String(tempIntDay2)
        }
        
        // year
        let ocrYear = ocrTimeArray[4]
        
        startTime = "\(ocrYear)-\(ocrMonth)-\(ocrDay2)T\(ocrHour):\(ocrMin):00.000Z"
        endTime = "\(ocrYear)-\(ocrMonth)-\(ocrDay1)T\(ocrHour):\(ocrMin):00.000Z"
        
        return ["startTime": startTime, "endTime": endTime]
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
