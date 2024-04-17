//
//  XkcdAPITests.swift
//  dckxTests
//
//  Created by Vito Royeca on 2/22/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import XCTest
import CoreData
@testable import dckx

class XkcdAPITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchLastComic() async throws {
        do {
            let comic = try await XkcdAPI.sharedInstance.fetchLastComic()
            print(comic.description)
        } catch {
            print(error)
            XCTFail("testFetchLastComic() failed")
        }
    }

    func testFetchFirstComic() async throws {
        do {
            let comic = try await XkcdAPI.sharedInstance.fetchComic(num: 1)
            print(comic.description)
        } catch {
            print(error)
            XCTFail("testFetchFirstComic() failed")
        }
    }

    func testFetchRandomComic() async throws {
        do {
            let random = Int.random(in: 1 ... 2900)
            let comic = try await XkcdAPI.sharedInstance.fetchComic(num: random)
            print(comic.description)
        } catch {
            print(error)
            XCTFail("testFetchComic() failed")
        }
    }

    func testFetchLastWhatIf() async throws {
        do {
            let whatIf = try await XkcdAPI.sharedInstance.fetchLastWhatIf()
            print(whatIf.description)
        } catch {
            print(error)
            XCTFail("testFetchLastWhatIf() failed")
        }
    }
    
    func testFetchFirstWhatIf() async throws {
        do {
            let whatIf = try await XkcdAPI.sharedInstance.fetchWhatIf(num: 1)
            print(whatIf.description)
        } catch {
            print(error)
            XCTFail("testFetchLastWhatIf() failed")
        }
    }
    
    func testFetchRandomWhatIf() async throws {
        do {
            let random = Int.random(in: 1 ... 162)
            let whatIf = try await XkcdAPI.sharedInstance.fetchWhatIf(num: random)
            print(whatIf.description)
        } catch {
            print(error)
            XCTFail("testFetchLastWhatIf() failed")
        }
    }
}
