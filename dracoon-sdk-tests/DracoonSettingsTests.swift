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
        var calledValue = false
        
        self.settings.getServerSettings(completion: { result in
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
    
    func testUpdateCustomerSettings() {
        
        self.setResponseModel(CustomerSettingsResponse.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns CustomerSettingsResponse")
        var calledValue = false
        
        let request = CustomerSettingsRequest(homeRoomParentName: "home", homeRoomQuota: 5000000000, homeRoomsActive: true)
        
        self.settings.updateServerSettings(request: request, completion: { result in
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
