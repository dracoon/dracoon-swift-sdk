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
    
    // MARK: GetUserKeyPair
    
    func testGetUserKeyPair_returnsUserKeyPairContainer() {
        
        self.setResponseModel(UserKeyPairContainer.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns UserKeyPairContainer")
        self.account.getUserKeyPair(completion: { result in
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
    
    // MARK: DeleteUserKeyPair
    
    func testDeleteUserKeyPair() {
        
        let expectation = XCTestExpectation(description: "Returns without error")
        MockURLProtocol.response(with: 204)
        self.account.deleteUserKeyPair(completion: { response in
            if response.error != nil {
                XCTFail()
            } else {
                expectation.fulfill()
            }
        })
        XCTWaiter().wait(for: [expectation], timeout: 2.0)
    }
    
    func testDeleteUserKeyPair_offline_returnsError() {
        
        let expectation = XCTestExpectation(description: "Returns error")
        MockURLProtocol.responseWithError(NSError(domain: "SDKTest", code: NSURLErrorNotConnectedToInternet, userInfo: nil), statusCode: 400)
        
        self.account.deleteUserKeyPair(completion: { response in
            if response.error != nil {
                expectation.fulfill()
            } else {
                XCTFail()
            }
        })
        XCTWaiter().wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: GetUserAvatar
    
    func testGetUserAvatar_returnsAvatar() {
        
        self.setResponseModel(Avatar.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns Avatar")
        self.account.getUserAvatar(completion: { result in
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
    
    // MARK: UpdateUserAvatar
    
//    func testUpdateUserAvatar() {
//
//        self.setResponseModel(Avatar.self, statusCode: 200)
//
//        let expectation = XCTestExpectation(description: "Returns Avatar")
//        self.account.updateUserAvatar(fileUrl: URL(string: "/")!, completion: { result in
//            switch result {
//            case .error(let error):
//                XCTFail()
//            case.value(let response):
//                XCTAssertNotNil(response)
//                expectation.fulfill()
//            }
//            
//        })
//
//        XCTWaiter().wait(for: [expectation], timeout: 2.0)
//    }
    
    // MARK: DeleteUserAvatar
    
    func testDeleteUserAvatar() {
        
        self.setResponseModel(Avatar.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns Avatar")
        self.account.deleteUserAvatar(completion: { result in
            switch result {
            case .error(_):
                XCTFail()
            case .value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        XCTWaiter().wait(for: [expectation], timeout: 2.0)
    }
}
