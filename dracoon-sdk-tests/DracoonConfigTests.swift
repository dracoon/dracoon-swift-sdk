//
//  DracoonConfigTests.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 30.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import XCTest
import crypto_sdk
import Alamofire
@testable import dracoon_sdk

class DracoonConfigTests: DracoonSdkTestCase {
    
    var config: DracoonConfigImpl!
    
    override func setUp() {
        super.setUp()
        
        self.config = DracoonConfigImpl(config: requestConfig)
}

    func testGetSystemDefaults() {
        
        self.setResponseModel(SystemDefaults.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SystemDefaults")
        var calledValue = false
        
        self.config.getSystemDefaults(completion: { result in
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
    
    func testGetGeneralSettings() {
        
        self.setResponseModel(GeneralSettings.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns GeneralSettings")
        var calledValue = false
        
        self.config.getSystemDefaults(completion: { result in
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
    
    func testGetInfrastructureProperties() {
        
        self.setResponseModel(InfrastructureProperties.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns InfrastructureProperties")
        var calledValue = false
        
        self.config.getSystemDefaults(completion: { result in
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
