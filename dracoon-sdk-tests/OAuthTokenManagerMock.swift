//
//  OAuthTokenManagerMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 24.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
@testable import dracoon_sdk

class OAuthTokenManagerMock: OAuthInterceptor {
    
    var oAuthClient: OAuthClient
    var mode: DracoonAuthMode
    weak var delegate: OAuthTokenChangedDelegate?
    
    required init(authMode: DracoonAuthMode, oAuthClient: OAuthClient) {
        self.mode = authMode
        self.oAuthClient = oAuthClient
    }
    
    func setOAuthDelegate(_ delegate: OAuthTokenChangedDelegate?) {
        self.delegate = delegate
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        completion(false, TimeInterval())
    }
    
    func getAccessToken() -> String? {
        return "accessToken"
    }
    
    func getRefreshToken() -> String? {
        return "refreshToken"
    }
}
