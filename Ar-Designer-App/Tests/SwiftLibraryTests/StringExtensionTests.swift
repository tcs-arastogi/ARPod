//
//  StringExtensionTests.swift
//  AROrganizer
//
//  Created by Valeriy Jefimov on 7/6/22.
//

import XCTest
@testable import AROrganizer

class StringExtensionTests: XCTestCase {
    
    func testIncrementProject() {
        testIncrement(initial: "Project1", expected: "Project2")
    }
    
    func testIncrementEmpty() {
        testIncrement(initial: "", expected: "Project1")
    }
    
    func testIncrement001() {
        testIncrement(initial: "001", expected: "002")
    }
    
    func testIncrement120_22_99() {
        testIncrement(initial: "120-22-99", expected: "120-22-100")
    }
    
    func testIncrement120_BB_9() {
        testIncrement(initial: "120-BB-9", expected: "120-BB-10")
    }
    
    func testIncrement_Project_1() {
        testIncrement(initial: "Project-1", expected: "Project-2")
    }
    
    func testIncrementPointed() {
        testIncrement(initial: "120.1", expected: "220.2")
    }
    
    private func testIncrement(initial: String, expected: String) {
        XCTAssertEqual(initial.incrementedName, expected)
    }
}
