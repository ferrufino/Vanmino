//
//  VanminoTests.swift
//  VanminoTests
//
//  Created by Gustavo Ferrufino on 2018-12-02.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import XCTest
@testable import Vanmino

class VanminoTests: XCTestCase {

    var hikesVC: HikesVC!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
       
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        hikesVC = nil
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        guard let hikesController = UIStoryboard(name: "Main", bundle: Bundle(for: HikesVC.self)).instantiateInitialViewController() as? HikesVC else {
            return XCTFail("Could not instantiate hikesController from main storyboard")
        }
        
        hikesController.loadViewIfNeeded()
        
        XCTAssertNotNil(hikesController.tableView, "HikeController should have a tableview")
        
        XCTAssertNotNil(hikesController.hikes.count,
                       "Hikes array cannot be empty")
    }
    
    func testHikeVC_HikesArrayNotEmpty() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        guard let hikesController = UIStoryboard(name: "Main", bundle: Bundle(for: HikesVC.self)).instantiateInitialViewController() as? HikesVC else {
            return XCTFail("Could not instantiate hikesController from main storyboard")
        }
        
        hikesController.loadViewIfNeeded()
        
        XCTAssertNotNil(hikesController.hikes.count,
                        "Hikes array cannot be empty")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
