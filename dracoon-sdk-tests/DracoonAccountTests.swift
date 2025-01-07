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
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns connection timeout error")
        self.account.getUserAccount(completion: { result in
            switch result {
            case .error(let error):
                switch error {
                case .connection_timeout:
                    testState.onErrorCalled = true
                    expectation.fulfill()
                default:
                    break
                }
            case.value(_):
                break
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    func testGetUserAccount_returnsUserAccountModel() {
        
        self.setResponseModel(UserAccount.self, statusCode: 200)
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns UserAccountModel")
        self.account.getUserAccount(completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    // MARK: GetCustomerAccount
    
    func testGetCustomerAccount_responseTimesOut_returnsError() {
        MockURLProtocol.responseWithError(NSError(domain: "SDKTest", code: NSURLErrorTimedOut, userInfo: nil), statusCode: 400)
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns connection timeout error")
        self.account.getCustomerAccount(completion: { result in
            switch result {
            case .error(let error):
                testState.onErrorCalled = true
                switch error {
                case .connection_timeout:
                    expectation.fulfill()
                default:
                    break
                }
            case.value(_):
                break
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    func testGetCustomerAccount_returnsCustomerAccountModel() {
        
        self.setResponseModel(CustomerData.self, statusCode: 200)
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns CustomerAccountModel")
        self.account.getCustomerAccount(completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    // MARK: GetUserKeyPair
    
    func testGetUserKeyPair_returnsUserKeyPairContainer() {
        
        self.setResponseModel(UserKeyPairContainer.self, statusCode: 200)
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns UserKeyPairContainer")
        self.account.getUserKeyPair(completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    // MARK: GenerateUserKeyPair
    
    func testGenerateUserKeyPair_returnsUserKeyPair() {
        
        let keyPair = try? self.account.generateUserKeyPair(version: .RSA2048, password: "")
        
        XCTAssertNotNil(keyPair)
    }
    
    func testGenerateUserKeyPair_fails_throwsError() {
        
        (self.crypto as! DracoonCryptoMock).testError = DracoonError.keypair_failure(description: "test")
        
        XCTAssertThrowsError(try self.account.generateUserKeyPair(version: .RSA2048, password: ""))
    }
    
    // MARK: SetUserKeyPair
    
    func testSetUserKeyPair() {
        
        self.setResponseModel(UserKeyPairContainer.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns UserKeyPair")
        let testState = TestState()
        
        self.account.setUserKeyPair(version: .RSA2048, password: "", completion: { result in
            switch result {
            case.error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue((self.crypto as! DracoonCryptoMock).generateKeyPairCalled)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testSetUserKeyPair_creatingKeyPairFails_returnsError() {
        
        self.setResponseModel(UserKeyPairContainer.self, statusCode: 200)
        (self.crypto as! DracoonCryptoMock).testError = DracoonError.keypair_failure(description: "test")
        let expectation = XCTestExpectation(description: "Returns error")
        let testState = TestState()
        
        self.account.setUserKeyPair(version: .RSA2048, password: "", completion: { result in
            switch result {
            case.error(_):
                testState.onErrorCalled = true
                expectation.fulfill()
            case .value(_):
                break
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    // MARK: CheckUserKeyPair
    
    func testCheckUserKeyPair_returnsKeyPair() {
        
        self.setResponseModel(UserKeyPairContainer.self, statusCode: 200)
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns UserKeyPairContainer")
        self.account.checkUserKeyPairPassword(password: "password", completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
        XCTAssertTrue((self.crypto as! DracoonCryptoMock).checkKeyPairCalled)
    }
    
    func testCheckUserKeyPair_passwordWrong_returnsError() {
        
        (self.crypto as! DracoonCryptoMock).checkKeyPairSuccess = false
        self.setResponseModel(UserKeyPairContainer.self, statusCode: 200)
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns UserKeyPairContainer")
        self.account.checkUserKeyPairPassword(password: "password", completion: { result in
            switch result {
            case .error(_):
                testState.onErrorCalled = true
                expectation.fulfill()
            case.value(_):
                break
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    func testCheckUserKeyPair_getKeyPairFails_returnsError() {
        
        let error = NSError(domain: "SDKTest", code: NSURLErrorTimedOut, userInfo: nil)
        MockURLProtocol.responseWithError(error, statusCode: 400)
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns UserKeyPairContainer")
        self.account.checkUserKeyPairPassword(password: "password", completion: { result in
            switch result {
            case .error(_):
                testState.onErrorCalled = true
                expectation.fulfill()
            case.value(_):
                break
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    // MARK: DeleteUserKeyPair
    
    func testDeleteUserKeyPair() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        let testState = TestState()
        testState.onErrorCalled = true
        
        self.account.deleteUserKeyPair(completion: { response in
            if response.error == nil {
                testState.onErrorCalled = false
                expectation.fulfill()
            }
        })
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(testState.onErrorCalled)
    }
    
    func testDeleteUserKeyPair_offline_returnsError() {
        
        let expectation = XCTestExpectation(description: "Returns error")
        MockURLProtocol.responseWithError(NSError(domain: "SDKTest", code: NSURLErrorNotConnectedToInternet, userInfo: nil), statusCode: 400)
        let testState = TestState()
        
        self.account.deleteUserKeyPair(completion: { response in
            if response.error != nil {
                testState.onErrorCalled = true
                expectation.fulfill()
            }
        })
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    // MARK: GetUserAvatar
    
    func testGetUserAvatar_returnsAvatar() {
        
        self.setResponseModel(Avatar.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns Avatar")
        let testState = TestState()
        
        self.account.getUserAvatar(completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testDownloadUserAvatar() {
        
        self.setResponseModel(Avatar.self, statusCode: 200)
        let targetUrl = Bundle(for: DracoonAccountTests.self).resourceURL!.appendingPathComponent("testUpload")
        let expectation = XCTestExpectation(description: "Returns Avatar")
        
        
        self.account.downloadUserAvatar(targetUrl: targetUrl, completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
    }
    
    func testDownloadUserAvatar_downloadFails_returnsError() {
        
        MockURLProtocol.responseWithError(NSError(domain: "SDKTest", code: NSURLErrorTimedOut, userInfo: nil), statusCode: 400)
        let expectation = XCTestExpectation(description: "Returns error")
        let testState = TestState()
        
        self.account.downloadUserAvatar(targetUrl: URL(string:"/")!, completion: { result in
            switch result {
            case .error(_):
                testState.onErrorCalled = true
                expectation.fulfill()
            case.value(_):
                break
            }
        })
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    // MARK: UpdateUserAvatar
    
    func testUpdateUserAvatar() {
        
        self.setResponseModel(Avatar.self, statusCode: 200)
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns Avatar")
        self.account.updateUserAvatar(fileUrl: URL(string: "/")!, completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testUpdateUserAvatar_withNoData_returnsError() {
        
        (FileUtils.fileHelper as! FileUtilsMock).returnsData = false
        self.setResponseModel(Avatar.self, statusCode: 200)
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns Avatar")
        self.account.updateUserAvatar(fileUrl: URL(string: "/")!, completion: { result in
            switch result {
            case .error(let error):
                switch error {
                case .read_data_failure(at: _):
                    testState.onErrorCalled = true
                    expectation.fulfill()
                default:
                    break
                }
                expectation.fulfill()
            case.value(_):
                break

            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    func testUpdateUserAvatar_withInvalidPath_returnsError() {
        
        (ValidatorUtils.validator as! ValidatorUtilsMock).pathExists = false
        self.setResponseModel(Avatar.self, statusCode: 200)
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns Avatar")
        self.account.updateUserAvatar(fileUrl: URL(string: "/")!, completion: { result in
            switch result {
            case .error(let error):
                switch error {
                case .file_does_not_exist(at: _):
                    testState.onErrorCalled = true
                    expectation.fulfill()
                default:
                    break
                }
                expectation.fulfill()
            case.value(_):
                break
                
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    // MARK: DeleteUserAvatar
    
    func testDeleteUserAvatar() {
        
        self.setResponseModel(Avatar.self, statusCode: 200)
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns Avatar")
        self.account.deleteUserAvatar(completion: { result in
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
    
    // MARK: GetProfileAttributes
    
    func testGetProfileAttributes_returnsAttributesResponseModel() {
        
        self.setResponseModel(AttributesResponse.self, statusCode: 200)
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns AttributesResponse model")
        self.account.getProfileAttributes(completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testUpdateProfileAttributes_returnsAttributesResponseModel() {
        
        self.setResponseModel(ProfileAttributes.self, statusCode: 204)
        let testState = TestState()
        
        let expectation = XCTestExpectation(description: "Returns AttributesResponse model")
        let request = ProfileAttributesRequest(items: [KeyValueEntry(key: "key", value: "value")])
        self.account.updateProfileAttributes(request: request, completion: { response in
            testState.onValueCalled = true
            XCTAssertNotNil(response)
            expectation.fulfill()
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testDeleteProfileAttribute_returnsDracoonResponse() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        let testState = TestState()
        testState.onErrorCalled = true
        
        self.account.deleteProfileAttributes(key: "key", completion: { response in
            if response.error == nil {
                testState.onErrorCalled = false
                expectation.fulfill()
            }
        })
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(testState.onErrorCalled)
    }
}
