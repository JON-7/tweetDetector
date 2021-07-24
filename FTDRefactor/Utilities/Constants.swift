//
//  Constants.swift
//  FTDRefactor
//
//  Created by Jon E on 7/13/21.
//  Copyright © 2021 Jon E. All rights reserved.
//

import UIKit

enum NetworkError: String, Error {
    case creatingUrl = "Could not create a url"
    case creatingData = "Could not create data"
    case noDataFound = "No data found"
    
    case noTextFound = "No text found. Please scan again"
    case noTwitterID = "This user could not be found"
    case noUserTweets = "No tweets found matching the pictured tweet"
}

enum CustomColors {
    static let myColors = UIColor(named: "myColors")
    static let textColor = UIColor(named: "textColors")
}

enum Images {
    static let detective = UIImage(named: "detective1")
    static let realTweetImage = UIImage(named: "realTweetImage")
    static let fakeTweetImage = UIImage(named: "fakeTweetImage")
    static let infoCircle = UIImage(systemName: "info.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .light, scale: .medium))
    static let backArrow = "arrow.backward"
}

enum ScanningTipsMessage {
    static let message = """
    - Make sure the tweet text, username, and date are all shown \n
    - Use good lighting \n
    - Take pictures as close as possible \n

    """
}

enum TweetDateRegex {
    static let hrMinRegex = "[0-9]*:[0-9]{2}"
    static let dayRegex = "[0-9]*,"
    static let monthRegex = "[aA-zZ]{3}"
    static let yearRegex = "[0-9]{4}"
}
