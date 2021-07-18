//
//  TwitterAPITests.swift
//  FTDRefactorTests
//
//  Created by Jon E on 7/16/21.
//  Copyright © 2021 Jon E. All rights reserved.
//

import XCTest
@testable import FTDRefactor

class TwitterAPISearchTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSearchingForTweet_WhenGivenSuccessfullResponse_ShouldReturnTrue() {
        
        var numberOfTweets = 0
        let expectation = self.expectation(description: "Tweet search Responce Expectation")
        NetworkManager.shared.getUserTweets(id: "33857883", startTime: "2021-02-21T16:03:00.000Z", endTime: "2021-02-23T16:03:00.000Z") { result in
            switch result {
            case .success(let tweets):
                numberOfTweets = tweets.count
            case .failure(_):
                numberOfTweets = 0
            }
            XCTAssertGreaterThan(numberOfTweets, 0, "The number of tweets should be greater than zero but it was not and returned FALSE")
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 5)
    }
    
    func testSearchingForTweet_WhenGivenUnsuccessfullResponse_ShouldReturnFalse() {
        var numberOfTweets = 0
        let expectation = self.expectation(description: "Tweet search Responce Expectation")
        NetworkManager.shared.getUserTweets(id: "1", startTime: "2000-02-21T16:03:00.000Z", endTime: "2029-02-23T16:03:00.000Z") { result in
            switch result {
            case .success(let tweets):
                numberOfTweets = tweets.count
            case .failure(_):
                numberOfTweets = 0
            }
            XCTAssertFalse(numberOfTweets > 0)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 5)
    }
    
}
