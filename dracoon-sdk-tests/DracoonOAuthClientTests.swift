//
//  DracoonOAuthClientTests.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 16.05.22.
//  Copyright © 2022 Dracoon. All rights reserved.
//

import Foundation
import XCTest
import Alamofire
@testable import dracoon_sdk

class DracoonOAuthClientTests: XCTestCase {
    
    var oAuthClient: OAuthClientImpl!
    var testSession: Alamofire.Session!
    
    let testWaiter = XCTWaiter()
    
    override func setUp() {
        super.setUp()
        
        MockURLProtocol.resetMockData()
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        let session = Alamofire.Session(configuration: config)
        self.testSession = session
        
        let testOAuthClient = OAuthClientImpl(serverUrl: URL(string:"https://dracoon.team")!)
        self.oAuthClient = testOAuthClient
    }
    
    func testGetAccessToken_withValidParameters_returnsTokens() {
        
        let tokens = OAuthTokens(access_token: "access", token_type: "type", refresh_token: "refresh", expires_in: 3600, scope: "")
        MockURLProtocol.responseWithModel(OAuthTokens.self, model: tokens, statusCode: 200)
        
        
        let expectation = XCTestExpectation(description: "Returns OAuthTokens")
        var gotNonErrorResponse = false
        
        self.oAuthClient.getAccessToken(session: self.testSession, clientId: "validId", clientSecret: "validSecret", code: "validCode", completion: { result in
            switch result {
            case .value(let response):
                gotNonErrorResponse = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            case .error(_):
                break
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(gotNonErrorResponse)
    }
    
    func testRefreshAccessToken_withValidParameters_returnsTokens() {
        
        let tokens = OAuthTokens(access_token: "access", token_type: "type", refresh_token: "refresh", expires_in: 3600, scope: "")
        MockURLProtocol.responseWithModel(OAuthTokens.self, model: tokens, statusCode: 200)
        
        
        let expectation = XCTestExpectation(description: "Returns OAuthTokens")
        var gotNonErrorResponse = false
        
        self.oAuthClient.refreshAccessToken(session: self.testSession, clientId: "validId", clientSecret: "validSecret", refreshToken: "validRefreshToken", delegate: nil, completion: { result in
            switch result {
            case .value(let response):
                gotNonErrorResponse = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            case .error(_):
                break
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(gotNonErrorResponse)
    }
    
    func testGetAccessToken_withInvalidParameters_returnsOAuthError() {
        
        let errorModel = OAuthErrorModel(error: OAuthBadRequestErrorCode.invalid_client.rawValue)
        MockURLProtocol.responseWithModel(OAuthErrorModel.self, model: errorModel, statusCode: 400)
        
        let expectation = XCTestExpectation(description: "Returns OAuthError")
        var gotErrorResponse = false
        
        self.oAuthClient.getAccessToken(session: self.testSession, clientId: "invalidId", clientSecret: "invalidSecret", code: "validCode", completion: { result in
            switch result {
            case .value(_):
               break
            case .error(let error):
                switch error {
                case .oauth_error(errorModel: let returnModel):
                    XCTAssert(returnModel.getErrorCode() == errorModel.getErrorCode())
                    gotErrorResponse = true
                default:
                    break
                }
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(gotErrorResponse)
    }
    
    func testGetAccessToken_failsWithUnknownError_returnsOAuthErrorUnknown() {
        
        let testStatusCode = 404
        MockURLProtocol.response(with: testStatusCode)
        
        let expectation = XCTestExpectation(description: "Returns OAuthError")
        var gotErrorResponse = false
        
        self.oAuthClient.getAccessToken(session: self.testSession, clientId: "invalidId", clientSecret: "invalidSecret", code: "validCode", completion: { result in
            switch result {
            case .value(_):
               break
            case .error(let error):
                switch error {
                case .oauth_error_unknown(statusCode: let statusCode, description: _):
                    XCTAssert(testStatusCode == statusCode)
                    gotErrorResponse = true
                default:
                    break
                }
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(gotErrorResponse)
    }
    
    func testRefreshAccessToken_withInValidParameters_returnsOAuthError() {
        
        let errorModel = OAuthErrorModel(error: OAuthBadRequestErrorCode.invalid_grant.rawValue)
        MockURLProtocol.responseWithModel(OAuthErrorModel.self, model: errorModel, statusCode: 400)
        
        let expectation = XCTestExpectation(description: "Returns OAuthError")
        var gotErrorResponse = false
        
        self.oAuthClient.refreshAccessToken(session: self.testSession, clientId: "validId", clientSecret: "validSecret", refreshToken: "invalidRefreshToken", delegate: nil, completion: { result in
            switch result {
            case .value(_):
               break
            case .error(let error):
                switch error {
                case .oauth_error(errorModel: let returnModel):
                    XCTAssert(returnModel.getErrorCode() == errorModel.getErrorCode())
                    gotErrorResponse = true
                default:
                    break
                }
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(gotErrorResponse)
    }
    
}
