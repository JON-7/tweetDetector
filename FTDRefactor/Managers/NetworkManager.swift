//
//  NetworkManager.swift
//  FTDRefactor
//
//  Created by Jon E on 8/18/20.
//  Copyright © 2020 Jon E. All rights reserved.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    // Network call to ocr api
    func OCRTweet(image: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        
        guard let url = URL(string: "https://ocr-text-extractor.p.rapidapi.com/detect-text-from-image-file") else {
            completion(.failure(.creatingUrl))
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        let header = ["content-type": "application/json",
                      "accept": "string",
                      // add ocr api key here
                      "x-rapidapi-key": ocrKey,
                      "x-rapidapi-host": "ocr-text-extractor.p.rapidapi.com"]
        request.allHTTPHeaderFields = header
        
        // api parameters
        let jsonObject = ["ImageContentInBase64": image,
                          "Language": "eng",
                          "DetectOrientation": false,
                          "Scale": false,
                          "IsTable": false,
                          "OcrEngine": "Version2"] as [String: Any]
        
        do {
            let requestBody = try JSONSerialization.data(withJSONObject: jsonObject, options: .fragmentsAllowed)
            request.httpBody = requestBody
        } catch {
            completion(.failure(.creatingData))
        }
        
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, responce, error) in
            
            guard let data = data else {
                completion(.failure(.noDataFound))
                return
            }
            
            // decoding the text parsed by the ocr
            guard let result = try? JSONDecoder().decode(OCRText.self, from: data) else { return }
            
            let fullText = result.parsedResults[0].parsedText?.replacingOccurrences(of: "\n", with: " ")
            let fullTextArray = fullText?.components(separatedBy: " ")
            var joinText = ""
            
            for n in 0..<fullTextArray!.count {
                joinText.append(fullTextArray?[n] ?? "" + " ")
            }
            
            if joinText != " " {
                completion(.success(String(fullText ?? "")))
            } else {
                completion(.failure(.noTextFound))
            }
        }.resume()
    }
    
    // Making a call to twitter's api that returns the users twitter id
    func getTwitterID(username: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard let url = URL(string: "https://api.twitter.com/2/users/by?usernames=\(username)") else {
            completion(.failure(.creatingUrl))
            return
        }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        // authorization header
        // add twitter bear token here
        request.setValue(bearToken, forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, responce, error) in
            guard let data = data else {
                completion(.failure(.noDataFound))
                return
            }
            // decoding the Twitter ID
            if let result = try? JSONDecoder().decode(TwitterID.self, from: data) {
                let twitterID = result.data[0].id
                completion(.success(twitterID))
            } else {
                completion(.failure(.noTwitterID))
            }
        }.resume()
    }
    
    // Twitter api call that returns the users tweets
    // passing the users Twitter id and time range of the tweet
    func getUserTweets(id: String, startTime: String, endTime: String, completion: @escaping (Result<[TweetData], NetworkError>) -> Void) {
        guard let url = URL(string: "https://api.twitter.com/2/users/\(id)/tweets?max_results=100&start_time=\(startTime)&end_time=\(endTime)&tweet.fields=created_at") else {
            completion(.failure(.creatingUrl))
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        // authorization header
        request.setValue(bearToken, forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, responce, error) in
            guard let data = data else {
                completion(.failure(.noDataFound))
                return
            }
            // decoding the tweet text and the date the tweet was created
            if let result = try? JSONDecoder().decode(Tweets.self, from: data) {
                let tweetResponse = result.data
                completion(.success(tweetResponse))
            } else {
                completion(.failure(.noUserTweets))
                return
            }
        }.resume()
    }
}
