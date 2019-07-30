//
//  DracoonServerTests.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 30.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import XCTest
import crypto_sdk
import Alamofire
@testable import dracoon_sdk

class DracoonServerTests: DracoonSdkTestCase {
    
    var server: DracoonServerImpl!
    
    override func setUp() {
        super.setUp()
        
        self.server = DracoonServerImpl(config: requestConfig)
    }
    
    func testGetServerVersion() {
        
        self.setResponseModel(SoftwareVersionData.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SoftwareVersionData")
        var calledValue = false
        
        self.server.getServerVersion(completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testGetServerTime() {
        
        self.setResponseModel(SdsServerTime.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SdsServerTime")
        var calledValue = false
        
        self.server.getServerTime(completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
         self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
}
