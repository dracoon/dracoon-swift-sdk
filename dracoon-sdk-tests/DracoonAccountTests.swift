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
        var calledError = false
        
        let expectation = XCTestExpectation(description: "Returns connection timeout error")
        self.account.getUserAccount(completion: { result in
            switch result {
            case .error(let error):
                switch error {
                case .connection_timeout:
                    calledError = true
                    expectation.fulfill()
                default:
                    break
                }
            case.value(_):
                break
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledError)
    }
    
    func testGetUserAccount_returnsUserAccountModel() {
        
        self.setResponseModel(UserAccount.self, statusCode: 200)
        var calledValue = false
        
        let expectation = XCTestExpectation(description: "Returns UserAccountModel")
        self.account.getUserAccount(completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    // MARK: GetCustomerAccount
    
    func testGetCustomerAccount_responseTimesOut_returnsError() {
        MockURLProtocol.responseWithError(NSError(domain: "SDKTest", code: NSURLErrorTimedOut, userInfo: nil), statusCode: 400)
        var calledError = false
        
        let expectation = XCTestExpectation(description: "Returns connection timeout error")
        self.account.getCustomerAccount(completion: { result in
            switch result {
            case .error(let error):
                calledError = true
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
        XCTAssertTrue(calledError)
    }
    
    func testGetCustomerAccount_returnsCustomerAccountModel() {
        
        self.setResponseModel(CustomerData.self, statusCode: 200)
        var calledValue = false
        
        let expectation = XCTestExpectation(description: "Returns CustomerAccountModel")
        self.account.getCustomerAccount(completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    // MARK: GetUserKeyPair
    
    func testGetUserKeyPair_returnsUserKeyPairContainer() {
        
        self.setResponseModel(UserKeyPairContainer.self, statusCode: 200)
        var calledValue = false
        
        let expectation = XCTestExpectation(description: "Returns UserKeyPairContainer")
        self.account.getUserKeyPair(completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
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
    
    // MARK: SetUserKeyPair
    
    func testSetUserKeyPair() {
        
        self.setResponseModel(UserKeyPairContainer.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns UserKeyPair")
        var calledValue = false
        
        self.account.setUserKeyPair(password: "", completion: { result in
            switch result {
            case.error(_):
                break
            case .value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                XCTAssertTrue((self.crypto as! DracoonCryptoMock).generateKeyPairCalled)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testSetUserKeyPair_creatingKeyPairFails_returnsError() {
        
        self.setResponseModel(UserKeyPairContainer.self, statusCode: 200)
        (self.crypto as! DracoonCryptoMock).testError = DracoonError.keypair_failure(description: "test")
        let expectation = XCTestExpectation(description: "Returns error")
        var calledError = false
        
        self.account.setUserKeyPair(password: "", completion: { result in
            switch result {
            case.error(_):
                calledError = true
                expectation.fulfill()
            case .value(_):
               break
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledError)
    }
    
    // MARK: CheckUserKeyPair
    
    func testCheckUserKeyPair_returnsKeyPair() {
        
        self.setResponseModel(UserKeyPairContainer.self, statusCode: 200)
        var calledValue = false
        
        let expectation = XCTestExpectation(description: "Returns UserKeyPairContainer")
        self.account.checkUserKeyPairPassword(password: "password", completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
        XCTAssertTrue((self.crypto as! DracoonCryptoMock).checkKeyPairCalled)
    }
    
    func testCheckUserKeyPair_passwordWrong_returnsError() {
        
        (self.crypto as! DracoonCryptoMock).checkKeyPairSuccess = false
        self.setResponseModel(UserKeyPairContainer.self, statusCode: 200)
        var calledError = false
        
        let expectation = XCTestExpectation(description: "Returns UserKeyPairContainer")
        self.account.checkUserKeyPairPassword(password: "password", completion: { result in
            switch result {
            case .error(_):
                calledError = true
                expectation.fulfill()
            case.value(_):
                break
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledError)
    }
    
    func testCheckUserKeyPair_getKeyPairFails_returnsError() {
        
        let error = NSError(domain: "SDKTest", code: NSURLErrorTimedOut, userInfo: nil)
        MockURLProtocol.responseWithError(error, statusCode: 400)
        var calledError = false
        
        let expectation = XCTestExpectation(description: "Returns UserKeyPairContainer")
        self.account.checkUserKeyPairPassword(password: "password", completion: { result in
            switch result {
            case .error(_):
                calledError = true
                expectation.fulfill()
            case.value(_):
                break
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledError)
    }
    
    // MARK: DeleteUserKeyPair
    
    func testDeleteUserKeyPair() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        self.account.deleteUserKeyPair(completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
    func testDeleteUserKeyPair_offline_returnsError() {
        
        let expectation = XCTestExpectation(description: "Returns error")
        MockURLProtocol.responseWithError(NSError(domain: "SDKTest", code: NSURLErrorNotConnectedToInternet, userInfo: nil), statusCode: 400)
        var calledError = false
        
        self.account.deleteUserKeyPair(completion: { response in
            if response.error != nil {
                calledError = true
                expectation.fulfill()
            }
        })
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledError)
    }
    
    // MARK: GetUserAvatar
    
    func testGetUserAvatar_returnsAvatar() {
        
        self.setResponseModel(Avatar.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns Avatar")
        var calledValue = false
        
        self.account.getUserAvatar(completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testDownloadUserAvatar() {

        self.setResponseModel(Avatar.self, statusCode: 200)
        let targetUrl = Bundle(for: FileDownload.self).resourceURL!.appendingPathComponent("testUpload")
        let expectation = XCTestExpectation(description: "Returns Avatar")

        
        self.account.downloadUserAvatar(targetUrl: targetUrl, completion: { result in
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
    
    func testDownloadUserAvatar_downloadFails_retunsError() {
        
        MockURLProtocol.responseWithError(NSError(domain: "SDKTest", code: NSURLErrorTimedOut, userInfo: nil), statusCode: 400)
        let expectation = XCTestExpectation(description: "Returns error")
        var calledError = false
        
        self.account.downloadUserAvatar(targetUrl: URL(string:"/")!, completion: { result in
            switch result {
            case .error(_):
                calledError = true
                expectation.fulfill()
            case.value(_):
                break
            }
        })
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledError)
    }
    
    // MARK: UpdateUserAvatar
    
    func testUpdateUserAvatar() {

        self.setResponseModel(Avatar.self, statusCode: 200)
        var calledValue = false

        let expectation = XCTestExpectation(description: "Returns Avatar")
        self.account.updateUserAvatar(fileUrl: URL(string: "/")!, completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })

        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testUpdateUserAvatar_withNoData_returnsError() {
        
        (FileUtils.fileHelper as! FileUtilsMock).returnedData = nil
        self.setResponseModel(Avatar.self, statusCode: 200)
        var calledError = false
        
        let expectation = XCTestExpectation(description: "Returns Avatar")
        self.account.updateUserAvatar(fileUrl: URL(string: "/")!, completion: { result in
            switch result {
            case .error(let error):
                switch error {
                case .read_data_failure(at: _):
                    calledError = true
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
        XCTAssertTrue(calledError)
    }
    
    func testUpdateUserAvatar_withInvalidPath_returnsError() {
        
        (ValidatorUtils.validator as! ValidatorUtilsMock).pathExists = false
        self.setResponseModel(Avatar.self, statusCode: 200)
        var calledError = false
        
        let expectation = XCTestExpectation(description: "Returns Avatar")
        self.account.updateUserAvatar(fileUrl: URL(string: "/")!, completion: { result in
            switch result {
            case .error(let error):
                switch error {
                case .file_does_not_exist(at: _):
                    calledError = true
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
        XCTAssertTrue(calledError)
    }
    
    // MARK: DeleteUserAvatar
    
    func testDeleteUserAvatar() {
        
        self.setResponseModel(Avatar.self, statusCode: 200)
        var calledValue = false
        
        let expectation = XCTestExpectation(description: "Returns Avatar")
        self.account.deleteUserAvatar(completion: { result in
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
