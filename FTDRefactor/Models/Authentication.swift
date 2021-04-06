//
//  Authentication.swift
//  FTDRefactor
//
//  Created by Jon E on 1/13/21.
//  Copyright © 2021 Jon E. All rights reserved.
//

import Foundation

struct Authentication {
    
    var ocrFullText: String?
    var ocrUsernameInfo: [String: Any]?
    var ocrUsername: String?
    var ocrDate: String?
    var ocrFormattedDate: String?
    var ocrTweetText: String?
    var apiTweetText: String?
    var twitterID: String?
    var tweetDate: String?
    var isDateReal = false
    var isBodyReal = false
    var isHandleReal = false
}
