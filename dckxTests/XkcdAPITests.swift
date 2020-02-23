//
//  XkcdAPITests.swift
//  dckxTests
//
//  Created by Vito Royeca on 2/22/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import XCTest
import CoreData
import PromiseKit

class XkcdAPITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchLastComic() {
        let expectation = self.expectation(description: "perform concurrent tasks")
        
        
        firstly {
            XkcdAPI.mockInstance.fetchLastComic()
        }.done { comic in
            XCTAssertEqual(comic.num, 1)
        }.catch { error in
            XCTFail(error.localizedDescription)
        }
        
        waitForExpectations(timeout: 100.0, handler: nil)
    }

    func testFetchComic() {
        firstly {
            XkcdAPI.mockInstance.fetchComic(num: Int32(100))
        }.done { comic in
            XCTAssertEqual(comic.num, 100)
        }.catch { error in
            XCTFail(error.localizedDescription)
        }
    }

    func testFetchRandomComic() {
        firstly {
            XkcdAPI.mockInstance.fetchRandomComic()
        }.done { comic in
            XCTAssert(comic.num > 0)
        }.catch { error in
            XCTFail(error.localizedDescription)
        }
    }
    
    func testFetchAllComics() {
        
    }
}
