//
//  AiScene_OSXTests.swift
//  AiScene-OSXTests
//
//  Created by Max Bilbow on 20/04/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Cocoa
import XCTest

class AiScene_OSXTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        testExample()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample(fn: () -> ()) {
        // This is an example of a performance test case.
        self.measureBlock() {
           fn() // Put the code you want to measure the time of here.
            
        }
    }
    
}
