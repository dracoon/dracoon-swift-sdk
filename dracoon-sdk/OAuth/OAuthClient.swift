//
//  OAuthClient.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

/// - Tag: OAuthClient
public protocol OAuthClient {
    
    var serverUrl: URL { get }
    
    func getAccessToken(session: Session, clientId: String, clientSecret: String, code: String, completion: @escaping DataRequest.DecodeCompletion<OAuthTokens>)
    
    func refreshAccessToken(session: Session, clientId: String, clientSecret: String, refreshToken: String, delegate: OAuthTokenChangedDelegate?, completion: @escaping DataRequest.DecodeCompletion<OAuthTokens>)
}

class OAuthClientImpl: OAuthClient {
    
    let serverUrl: URL
    
    private let decoder = JSONDecoder()
    
    init(serverUrl: URL) {
        self.serverUrl = serverUrl
    }
    
    func getAccessToken(session: Session, clientId: String, clientSecret: String, code: String, completion: @escaping DataRequest.DecodeCompletion<OAuthTokens>) {
        let requestUrl = serverUrl.absoluteString + OAuthConstants.OAUTH_PATH + OAuthConstants.OAUTH_TOKEN_PATH
        
        let parameters: Parameters = [
            "client_id": clientId,
            "grant_type": OAuthConstants.OAuthGrantTypes.AUTHORIZATION_CODE,
            "code": code
        ]
        let headers: HTTPHeaders = [
            DracoonConstants.AUTHORIZATION_HEADER: OAuthHelper.createBasicAuthorizationString(clientId: clientId, clientSecret: clientSecret)
        ]
        
        session.request(requestUrl, method: .post, parameters: parameters, encoding: URLEncoding(destination: .queryString), headers: headers)
            .validate()
            .decode(OAuthTokens.self, decoder: decoder, completion: completion)
    }
    
    func refreshAccessToken(session: Session, clientId: String, clientSecret: String, refreshToken: String, delegate: OAuthTokenChangedDelegate?, completion: @escaping DataRequest.DecodeCompletion<OAuthTokens>) {
        
        let requestUrl = serverUrl.absoluteString + OAuthConstants.OAUTH_PATH + OAuthConstants.OAUTH_TOKEN_PATH
        
        let parameters: Parameters = [
            "client_id": clientId,
            "grant_type": OAuthConstants.OAuthGrantTypes.REFRESH_TOKEN,
            "refresh_token": refreshToken
        ]
        let headers: HTTPHeaders = [
            DracoonConstants.AUTHORIZATION_HEADER: OAuthHelper.createBasicAuthorizationString(clientId: clientId, clientSecret: clientSecret)
        ]
        
        session.request(requestUrl, method: .post, parameters: parameters, encoding: URLEncoding(destination: .queryString), headers: headers)
            .validate()
            .decode(OAuthTokens.self, decoder: decoder, completion: completion)
    }
}
