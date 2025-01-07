//
//  DracoonSettingsTests.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 30.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import XCTest
import crypto_sdk
import Alamofire
@testable import dracoon_sdk

class DracoonSettingsTests: DracoonSdkTestCase {
    
    var settings: DracoonSettingsImpl!
    
    override func setUp() {
        super.setUp()
        
        self.settings = DracoonSettingsImpl(config: requestConfig)
    }
    
    func testGetCustomerSettings() {
        
        self.setResponseModel(CustomerSettingsResponse.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns CustomerSettingsResponse")
        let testState = TestState()
        
        self.settings.getServerSettings(completion: { result in
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
    
    func testGetCustomerSettings_withUnexpectedReturnModel_returnsDecodeError() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns error")
        let testState = TestState()
        
        self.settings.getServerSettings(completion: { result in
            switch result {
            case .error(let error):
                switch error {
                case .decode(error: _, statusCode: _):
                    testState.onErrorCalled = true
                    expectation.fulfill()
                default:
                    break
                }
                break
            case .value(_):
                break
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    func testUpdateCustomerSettings() {
        
        self.setResponseModel(CustomerSettingsResponse.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns CustomerSettingsResponse")
        let testState = TestState()
        
        let request = CustomerSettingsRequest(homeRoomParentName: "home", homeRoomQuota: 5000000000, homeRoomsActive: true)
        
        self.settings.updateServerSettings(request: request, completion: { result in
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
