//
//  DracoonSdkTestCase.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 25.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import XCTest
import Alamofire
import crypto_sdk
@testable import dracoon_sdk

class DracoonSdkTestCase: XCTestCase {
    
    var crypto: Crypto!
    var requestConfig: DracoonRequestConfig!
    
    override func setUp() {
        super.setUp()

        self.crypto = Crypto() // TODO Mock
        
        MockURLProtocol.resetMockData()
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        let sessionManager = Alamofire.SessionManager(configuration: config)
        
        self.requestConfig = DracoonRequestConfig(sessionManager: sessionManager, serverUrl: URL(string: "https://dracoon.team")!, apiPath: "/v4", oauthTokenManager: OAuthTokenManagerMock(),
                                                 encoder: JSONEncoder(), decoder: JSONDecoder())
        
    }
    
    func setResponseModel<E: Encodable>(_ type: E.Type, statusCode: Int) {
        let responseModel = ResponseModelFactory.getTestResponseModel(type)!
        MockURLProtocol.responseWithModel(type, model: responseModel, statusCode: statusCode)
    }
}
