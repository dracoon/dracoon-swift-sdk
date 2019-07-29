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
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
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
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
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
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
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
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
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
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: GenerateUserKeyPair
    
    func testGenerateUserKeyPair_returnsUserKeyPair() {
       
        let keyPair = try? self.account.generateUserKeyPair(password: "")
        
        XCTAssertNotNil(keyPair)
    }
    
    func testGenerateUserKeyPair_fails_throwsError() {
        
        (self.crypto as! DracoonCryptoMock).testError = DracoonError.keypair_failure(description: "test")
        
        XCTAssertThrowsError(try self.account.generateUserKeyPair(password: ""))
    }
    
    func testSetUserKeyPair() {
        
        self.setResponseModel(UserKeyPairContainer.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns UserKeyPair")
        
        self.account.setUserKeyPair(password: "", completion: { result in
            switch result {
            case.error(_):
                XCTFail()
            case .value(let response):
                XCTAssertNotNil(response)
                XCTAssertTrue((self.crypto as! DracoonCryptoMock).generateKeyPairCalled)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: DeleteUserKeyPair
    
    func testDeleteUserKeyPair() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        
        self.account.deleteUserKeyPair(completion: { response in
            if response.error != nil {
                XCTFail()
            } else {
                expectation.fulfill()
            }
        })
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
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
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
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
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
    }
    
//    func testDownloadUserAvatar() {
//
//        self.setResponseModel(Avatar.self, statusCode: 200)
//        let expectation = XCTestExpectation(description: "Returns Avatar")
//
//        self.account.downloadUserAvatar(targetUrl: URL(string:"/")!, completion: { result in
//            switch result {
//            case .error(_):
//                XCTFail()
//            case.value(let response):
//                XCTAssertNotNil(response)
//                expectation.fulfill()
//            }
//        })
//
//        self.testWaiter.wait(for: [expectation], timeout: 2.0)
//    }
    
    func testDownloadUserAvatar_downloadFails_retunsError() {
        
        MockURLProtocol.responseWithError(NSError(domain: "SDKTest", code: NSURLErrorTimedOut, userInfo: nil), statusCode: 400)
        let expectation = XCTestExpectation(description: "Returns error")
        
        self.account.downloadUserAvatar(targetUrl: URL(string:"/")!, completion: { result in
            switch result {
            case .error(_):
                expectation.fulfill()
            case.value(_):
                XCTFail()
            }
        })
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: UpdateUserAvatar
    
    func testUpdateUserAvatar() {

        self.setResponseModel(Avatar.self, statusCode: 200)

        let expectation = XCTestExpectation(description: "Returns Avatar")
        self.account.updateUserAvatar(fileUrl: URL(string: "/")!, completion: { result in
            switch result {
            case .error(_):
                XCTFail()
            case.value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })

        self.testWaiter.wait(for: [expectation], timeout: 2.0)
    }
    
    func testUpdateUserAvatar_withNoData_returnsError() {
        
        (FileUtils.fileHelper as! FileUtilsMock).returnedData = nil
        self.setResponseModel(Avatar.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns Avatar")
        self.account.updateUserAvatar(fileUrl: URL(string: "/")!, completion: { result in
            switch result {
            case .error(let error):
                switch error {
                case .read_data_failure(at: _):
                    expectation.fulfill()
                default:
                    XCTFail()
                }
                expectation.fulfill()
            case.value(_):
                XCTFail()
                
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
    }
    
    func testUpdateUserAvatar_withInvalidPath_returnsError() {
        
        (ValidatorUtils.validator as! ValidatorUtilsMock).pathExists = false
        self.setResponseModel(Avatar.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns Avatar")
        self.account.updateUserAvatar(fileUrl: URL(string: "/")!, completion: { result in
            switch result {
            case .error(let error):
                switch error {
                case .file_does_not_exist(at: _):
                    expectation.fulfill()
                default:
                    XCTFail()
                }
                expectation.fulfill()
            case.value(_):
                XCTFail()
                
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
    }
    
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
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
    }
}
