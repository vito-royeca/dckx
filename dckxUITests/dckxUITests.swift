//
//  dckxUITests.swift
//  dckxUITests
//
//  Created by Vito Royeca on 2/13/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import XCTest
@testable import dckx

class dckxUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // comics
        snapshot("0Comics")

        XCUIApplication().toolbars["Toolbar"].children(matching: .other).element.children(matching: .other).element.children(matching: .button).element(boundBy: 1).tap()
        snapshot("1Comics")

        XCUIApplication().toolbars["Toolbar"].children(matching: .other).element.children(matching: .other).element.children(matching: .button).element(boundBy: 1).tap()
        snapshot("2Comics")

        // comics list
//        app.buttons["list.dash"].tap()
//        snapshot("1ComicsList")
//        app.navigationBars["Comics"].buttons["xmark.circle.fill"].tap()

        // what if 1
        app.tabBars["Tab Bar"].buttons["questionmark.diamond"].tap()
        snapshot("3What If")

        XCUIApplication().toolbars["Toolbar"].children(matching: .other).element.children(matching: .other).element.children(matching: .button).element(boundBy: 1).tap()
        snapshot("4What If")
    }
}
