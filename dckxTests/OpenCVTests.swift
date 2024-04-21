//
//  OpenCVTests.swift
//  dckxTests
//
//  Created by Vito Royeca on 4/20/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import XCTest
import SwiftData
import SDWebImage
@testable import dckx

final class OpenCVTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testSplit()  {
        let expectation = XCTestExpectation(description: "Open a file asynchronously.")
        let url = "https://imgs.xkcd.com/comics/regular_expressions.png"

        SDWebImageDownloader.shared.downloadImage(with: URL(string: url)) { (image, data, error, completed) in
            if let fileName = SDImageCache.shared.cachePath(forKey: url) {
                OpenCVWrapper.split(fileName, 1) { dictionary in
                    for (key,value) in dictionary {
                        print("\(key): \(value)")
                    }
                }
            } else {
                XCTFail("filename not found")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
