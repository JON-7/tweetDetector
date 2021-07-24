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

func getUsernameAndIndex(ocrText: String) -> [String: Any] {
    var username = ""
    var usernameIndex = 0
    let wordArray: [String] = ocrText.components(separatedBy: " ")
    
    // assigning username to the first index that contains the @ symbol
    for word in 0..<wordArray.count {
        if wordArray[word].contains("@") {
            username = wordArray[word]
            username.removeFirst()
            usernameIndex = word
            break
        } else {
            username = "NO NAME FOUND"
        }
    }
    return ["username": username, "usernameIndex": usernameIndex]
}

func getDate(text: String) -> String {
    let datePattern = "[0-9]*[:][0-9]{2}.([AaPP][Mm]).*[aA-zZ]{3}.[0-9]*[,].[0-9]{4}"

    guard let dateFound = text.matches(for: datePattern).first else {
        return "NO DATE FOUND"
    }
    return dateFound
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
        return "NO TEXT FOUND"
    }
    
    nameFoundArray.removeLast(nameFoundArray.count - dateIndex)
    nameFoundArray.removeFirst(usernameIndex + 1)
    
    for n in 0..<nameFoundArray.count {
        finalText.append(nameFoundArray[n] + " ")
    }
    
    let trimmedTweetText = finalText.trimmingCharacters(in: .whitespaces)
    
    return trimmedTweetText
}

func compareDate(twitterTime: String, OCRTime: String) -> Bool{
    //MARK: Time from the Twitter API
    //Format: 2021-01-07T15:00:41.000Z
    let twTimeArray = twitterTime.components(separatedBy: "-")
    
    if twTimeArray.count < 2 {
        return false
    }
    
    let tempTwDay = twTimeArray[2]
    let hrsMinSec = tempTwDay.components(separatedBy: ":")
    let twMin = hrsMinSec[1]
    
    //MARK: Time from the OCR API
    //Format: 3:00 PM · Jan 7, 2021
    let ocrTimeArray = OCRTime.components(separatedBy: " ")
    let ocrHrMin = ocrTimeArray[0]
    let ocrMin = ocrHrMin.suffix(2)
    
    return ((twMin == ocrMin) ? true: false)
}

func getStartEndTime(tweetTime: String) -> [String: String] {
    
    let tweetDate = tweetTime
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let date = dateFormatter.date(from: tweetDate) ?? Date()
    
    let dayBeforeDate = date.addingTimeInterval(-86400)
    let dayAfterDate = date.addingTimeInterval(86400)

    let dateToStringFormmater = DateFormatter()
    dateToStringFormmater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let dayBeforeString = dateToStringFormmater.string(from: dayBeforeDate) + ".000Z"
    let dayAfterString = dateToStringFormmater.string(from: dayAfterDate) + ".000Z"
    
    return ["startTime": dayBeforeString, "endTime": dayAfterString]
}

func getTweetTime(ocrTime: String) -> String {
    let yearDetected = ocrTime.matches(for: TweetDateRegex.yearRegex).first ?? ""
    let monthDetected = ocrTime.matches(for: TweetDateRegex.monthRegex).first ?? ""
    let hrMinsDetected = ocrTime.matches(for: TweetDateRegex.hrMinRegex).first ?? ""
    let rawDayDetected = ocrTime.matches(for: TweetDateRegex.dayRegex).first ?? ""
    var dayDetected = rawDayDetected.replacingOccurrences(of: ",", with: "")
    
    let tweetHour = getTweetHour(for: hrMinsDetected)
    let tweetMin = hrMinsDetected.suffix(2)
    let tweetMonth = formatMonthNameToDigit(month: monthDetected)
    
    if dayDetected.count == 1 {
        dayDetected = "0" + dayDetected
    }
    
    let tweetDate = "\(yearDetected)-\(tweetMonth)-\(dayDetected)T\(tweetHour):\(tweetMin):00.000Z"
    
    return tweetDate
}

func getTweetHour(for time: String) -> Int {
    var hour = 0
    if time.count == 4 {
        hour = Int(time.prefix(1)) ?? 110
        hour += 12
    } else {
        hour = Int(time.prefix(2)) ?? 0
    }
    return hour
}

func formatMonthNameToDigit(month: String) -> String {
    let monthDateFormatter = DateFormatter()
    monthDateFormatter.dateFormat = "MM"
    let date = monthDateFormatter.date(from: month) ?? Date()
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM"
    return dateFormatter.string(from: date as Date)
}
