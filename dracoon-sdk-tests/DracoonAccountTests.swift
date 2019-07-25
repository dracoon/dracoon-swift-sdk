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

class DracoonAccountTests: XCTestCase {
    
    var account: DracoonAccountImpl!
    
    override func setUp() {
        super.setUp()
        let crypto = Crypto() // TODO Mock
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        let sessionManager = Alamofire.SessionManager(configuration: config)
        
        let requestConfig = DracoonRequestConfig(sessionManager: sessionManager, serverUrl: URL(string: "https://dracoon.team")!, apiPath: "/v4", oauthTokenManager: OAuthTokenManagerMock(),
                                          encoder: JSONEncoder(), decoder: JSONDecoder())
        
        account = DracoonAccountImpl(config: requestConfig, crypto: crypto)
    }
    
    override func tearDown() {
       
    }
    
    func testGetUserAccount_responseTimesOut_returnsError() {
        MockURLProtocol.responseWithError(NSError(domain: "SDKTest", code: NSURLErrorTimedOut, userInfo: nil), statusCode: 400)
        
        let expectation = XCTestExpectation(description: "")
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
        
        let customerData = CustomerData(_id: 1, name: "Customer", isProviderCustomer: false, spaceLimit: 10000, spaceUsed: 1000, accountsLimit: 100, accountsUsed: 98, customerEncryptionEnabled: true, cntFiles: 2000000, cntFolders: 321, cntRooms: 10000)
        let userRoles = RoleList(items: [])
        
        let responseModel = UserAccount(_id: 22, login: "tr", needsToChangePassword: false, firstName: "Test", lastName: "Test", lockStatus: 0, hasManageableRooms: true, customer: customerData, userRoles: userRoles, authMethods: [], needsToChangeUserName: nil, needsToAcceptEULA: nil, title: nil, gender: nil, expireAt: nil, isEncryptionEnabled: true, lastLoginSuccessAt: nil, lastLoginFailAt: nil, userGroups: nil, userAttributes: nil, email: nil, lastLoginSuccessIp: nil, lastLoginFailIp: nil, homeRoomId: 2345)
        
        MockURLProtocol.responseWithModel(UserAccount.self, model: responseModel, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "")
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
    
    
    
}
