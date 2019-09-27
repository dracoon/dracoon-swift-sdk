//
//  DracoonClientTests.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 01.08.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import XCTest
@testable import dracoon_sdk

class DracoonClientTests: XCTestCase {
    
    var client: DracoonClientImpl!
    
    override func setUp() {
        super.setUp()
        
        let serverUrl = URL(string: "https://dracoon.team/")!
        
        client = DracoonClientImpl(serverUrl: serverUrl, authMode: .authorizationCode(clientId: "clientId", clientSecret: "clientSecret", authorizationCode: "authorizationCode"), getEncryptionPassword: {
            return "encryptionPassword"
        }, sessionConfiguration: URLSessionConfiguration.default, oauthClient: OAuthClientMock(serverUrl: serverUrl), oauthCallback: nil)
    }
    
    func testInit_ApiImplementationsAreInitialized() {
        
        XCTAssertTrue(self.client.server is DracoonServerImpl)
        XCTAssertTrue(self.client.account is DracoonAccountImpl)
        XCTAssertTrue(self.client.config is DracoonConfigImpl)
        XCTAssertTrue(self.client.nodes is DracoonNodesImpl)
        XCTAssertTrue(self.client.settings is DracoonSettingsImpl)
        XCTAssertTrue(self.client.shares is DracoonSharesImpl)
        XCTAssertTrue(self.client.oAuthTokenManager is OAuthTokenManager)
    }
    
    func test_returnsToken() {
        XCTAssert(self.client.oAuthTokenManager.getAccessToken() == self.client.getAccessToken())
        XCTAssert(self.client.oAuthTokenManager.getRefreshToken() == self.client.getRefreshToken())
    }
    
    
}
