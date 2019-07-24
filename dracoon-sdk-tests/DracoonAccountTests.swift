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
    
    func testThisIsRunning() {
        
        XCTAssertTrue(true)
    }
    
}
