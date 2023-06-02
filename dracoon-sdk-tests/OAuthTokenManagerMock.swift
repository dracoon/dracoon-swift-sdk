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
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(Result.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        completion(.doNotRetry)
    }
    
    func startOAuthSession(_ session: Session) {}
    
    func getAccessToken() -> String? {
        return "accessToken"
    }
    
    func getRefreshToken() -> String? {
        return "refreshToken"
    }
    
    func revokeTokens(completion: ((DracoonError?) -> Void)?) {}
}
