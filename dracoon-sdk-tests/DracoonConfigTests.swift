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
        
        self.config.getSystemDefaults(completion: { result in
            switch result {
            case .error(_):
                XCTFail()
            case .value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
    }
    
    func testGetGeneralSettings() {
        
        self.setResponseModel(GeneralSettings.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns GeneralSettings")
        
        self.config.getSystemDefaults(completion: { result in
            switch result {
            case .error(_):
                XCTFail()
            case .value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
    }
    
    func testGetInfrastructureProperties() {
        
        self.setResponseModel(InfrastructureProperties.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns InfrastructureProperties")
        
        self.config.getSystemDefaults(completion: { result in
            switch result {
            case .error(_):
                XCTFail()
            case .value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
    }
        
}
