//
//  DracoonValidatorTests.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 02.08.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import XCTest
@testable import dracoon_sdk

class DracoonValidatorTests: XCTestCase {
    
    override func setUp() {
        ValidatorUtils.validator = DracoonValidator()
    }
    
    func testServerUrl_withValidUrl_returnsTrue() {
        let serverUrl = URL(string: "https://dracoon.team")!
        XCTAssertTrue(ValidatorUtils.isValid(serverUrl: serverUrl))
    }
    
    func testServerUrl_withWrongScheme_returnsFalse() {
        let serverUrl = URL(string: "scheme://dracoon.team")!
        XCTAssertFalse(ValidatorUtils.isValid(serverUrl: serverUrl))
    }
    
    func testServerUrl_withNoScheme_returnsFalse() {
        let serverUrl = URL(string: "dracoon.team")!
        XCTAssertFalse(ValidatorUtils.isValid(serverUrl: serverUrl))
    }
    
    func testServerUrl_withPath_returnsFalse() {
        let serverUrl = URL(string: "https://dracoon.team/path")!
        XCTAssertFalse(ValidatorUtils.isValid(serverUrl: serverUrl))
    }
    
    func testServerUrl_withUser_returnsFalse() {
        let serverUrl = URL(string: "https://user@dracoon.team")!
        XCTAssertFalse(ValidatorUtils.isValid(serverUrl: serverUrl))
    }
    
    func testServerUrl_withQuery_returnsFalse() {
        let serverUrl = URL(string: "https://dracoon.team?query")!
        XCTAssertFalse(ValidatorUtils.isValid(serverUrl: serverUrl))
    }
    
    func testNodeId_withValidId_returnsTrue() {
        XCTAssertTrue(ValidatorUtils.isValid(nodeId: 42))
    }
    
    func testNodeId_withNegativeId_returnsFalse() {
        XCTAssertFalse(ValidatorUtils.isValid(nodeId: -42))
    }
    
    func testNodeId_withZeroAsId_returnsFalse() {
        XCTAssertFalse(ValidatorUtils.isValid(nodeId: 0))
    }
    
    func testNodeIds_withValidIds_returnsTrue() {
        let nodeIds = [Int64(42), Int64(1337)]
        XCTAssertTrue(ValidatorUtils.isValid(nodeIds: nodeIds))
    }
    
    func testNodeIds_withAnInvalidId_returnsFalse() {
        let nodeIds = [Int64(42), Int64(0)]
        XCTAssertFalse(ValidatorUtils.isValid(nodeIds: nodeIds))
    }
    
}
