//
//  OAuthClientMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 24.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
@testable import dracoon_sdk
import Alamofire

class OAuthClientMock: OAuthClient {
    var serverUrl: URL
    
    init(serverUrl: URL) {
        self.serverUrl = serverUrl
    }
    
    func getAccessToken(session: Session, clientId: String, clientSecret: String, code: String, completion: @escaping DataRequest.DecodeCompletion<OAuthTokens>) {
        completion(Dracoon.Result.value(OAuthTokens(access_token: "accessToken", token_type: "test", refresh_token: "refreshToken", expires_in: TimeInterval(), scope: "scope")))
    }
    
    func refreshAccessToken(session: Session, clientId: String, clientSecret: String, refreshToken: String, delegate: OAuthTokenChangedDelegate?, completion: @escaping DataRequest.DecodeCompletion<OAuthTokens>) {
        completion(Dracoon.Result.value(OAuthTokens(access_token: "accessToken", token_type: "test", refresh_token: "refreshToken", expires_in: TimeInterval(), scope: "scope")))
    }
    
    
}
