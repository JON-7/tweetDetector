//
//  ErrorMessage.swift
//  FTDRefactor
//
//  Created by Jon E on 1/17/21.
//  Copyright © 2021 Jon E. All rights reserved.
//

import Foundation

enum NetworkError: String, Error {
    case creatingUrl = "Could not create a url"
    case creatingData = "Could not create data"
    case noDataFound = "No data found"
    
    case noTextFound = "No text found. Please scan again"
    case noTwitterID = "This user could not be found"
    case noUserTweets = "No tweets found matching the pictured tweet"
}
