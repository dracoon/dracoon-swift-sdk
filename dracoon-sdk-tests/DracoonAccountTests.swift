//
//  DracoonAccountTests.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 24.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import XCTest
import crypto_sdk
import Alamofire
@testable import dracoon_sdk

class DracoonAccountTests: DracoonSdkTestCase {
    
    var account: DracoonAccountImpl!
    
    override func setUp() {
        super.setUp()
        
        self.account = DracoonAccountImpl(config: requestConfig, crypto: crypto)
    }
    
    // MARK: GetUserAccount
    
    func testGetUserAccount_responseTimesOut_returnsError() {
        MockURLProtocol.responseWithError(NSError(domain: "SDKTest", code: NSURLErrorTimedOut, userInfo: nil), statusCode: 400)
        
        let expectation = XCTestExpectation(description: "Returns connection timeout error")
        self.account.getUserAccount(completion: { result in
            switch result {
            case .error(let error):
                switch error {
                case .connection_timeout:
                    expectation.fulfill()
                default:
                    XCTFail()
                }
            case.value(_):
                XCTFail()
            }
            
        })
        
        XCTWaiter().wait(for: [expectation], timeout: 2.0)
    }
    
    func testGetUserAccount_returnsUserAccountModel() {
        
        self.setResponseModel(UserAccount.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns UserAccountModel")
        self.account.getUserAccount(completion: { result in
            switch result {
            case .error(_):
                XCTFail()
            case.value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        XCTWaiter().wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: GetCustomerAccount
    
    func testGetCustomerAccount_responseTimesOut_returnsError() {
        MockURLProtocol.responseWithError(NSError(domain: "SDKTest", code: NSURLErrorTimedOut, userInfo: nil), statusCode: 400)
        
        let expectation = XCTestExpectation(description: "Returns connection timeout error")
        self.account.getCustomerAccount(completion: { result in
            switch result {
            case .error(let error):
                switch error {
                case .connection_timeout:
                    expectation.fulfill()
                default:
                    XCTFail()
                }
            case.value(_):
                XCTFail()
            }
            
        })
        
        XCTWaiter().wait(for: [expectation], timeout: 2.0)
    }
    
    func testGetCustomerAccount_returnsCustomerAccountModel() {
        
        self.setResponseModel(CustomerData.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns CustomerAccountModel")
        self.account.getCustomerAccount(completion: { result in
            switch result {
            case .error(_):
                XCTFail()
            case.value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        XCTWaiter().wait(for: [expectation], timeout: 2.0)
    }
    
    
}
