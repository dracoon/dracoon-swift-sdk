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
        let testState = TestState()
        
        self.config.getSystemDefaults { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        }
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testGetGeneralSettings() {
        
        self.setResponseModel(GeneralSettings.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns GeneralSettings")
        let testState = TestState()
        
        self.config.getGeneralSettings(completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testGetInfrastructureProperties() {
        
        self.setResponseModel(InfrastructureProperties.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns InfrastructureProperties")
        let testState = TestState()
        
        self.config.getInfrastructureProperties(completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testGetClassificationPolicies() {
        
        self.setResponseModel(ClassificationPoliciesConfig.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns ClassificationPoliciesConfig")
        let testState = TestState()
        
        self.config.getClassificationPolicies(completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testGetPasswordPolicies() {
        
        self.setResponseModel(PasswordPoliciesConfig.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns PasswordPoliciesConfig")
        let testState = TestState()
        
        self.config.getPasswordPolicies(completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
        
}
