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
        return "NO TEXT FOUND"
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

func getStartEndTime(ocrTime: String) -> [String: String] {
    if ocrTime == "" {
        return ["startTime": "", "endTime": ""]
    }
    
    // Twitter api time parameter format: 0000-00-00T00:00:00.000Z
    var startTime = ""
    var endTime = ""
    let ocrTimeArray = ocrTime.components(separatedBy: " ")
    // first element contains the hour and the minute
    let ocrHrMin = ocrTimeArray[0]
    let ocrMin = ocrHrMin.suffix(2)
    var ocrHour = ""
    let tempStrHr = ocrHrMin.dropLast(3)
    var tempIntHr = Int(tempStrHr) ?? 0
    
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

    var ocrMonth = ""
    let monthName = ocrTimeArray[2]

    // convert month to date type
    let monthDateFormatter = DateFormatter()
    monthDateFormatter.dateFormat = "MM"
    let date = monthDateFormatter.date(from: monthName)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM"
    ocrMonth = dateFormatter.string(from: date! as Date)
    
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
    
    let ocrYear = ocrTimeArray[4]
    
    startTime = "\(ocrYear)-\(ocrMonth)-\(ocrDay2)T\(ocrHour):\(ocrMin):00.000Z"
    endTime = "\(ocrYear)-\(ocrMonth)-\(ocrDay1)T\(ocrHour):\(ocrMin):00.000Z"
    
    return ["startTime": startTime, "endTime": endTime]
}
