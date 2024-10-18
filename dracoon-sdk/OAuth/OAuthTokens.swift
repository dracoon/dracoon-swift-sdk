//
//  OAuthTokens.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

public struct OAuthTokens: Codable {
    
    var access_token: String
    var token_type: String
    var refresh_token: String
    var expires_in: TimeInterval
    var scope: String
}

public enum OAuthTokenType: String, Codable {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
}


public struct DracoonTokens: Sendable {
    
    public init(refreshToken: String, accessToken: String? = nil, timestamp: Date = Date(), accessTokenValidity: TimeInterval = 3600/*one hour*/) {
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.accessTokenValidity = accessTokenValidity
        self.timestamp = timestamp
    }
    
    internal init(oAuthTokens: OAuthTokens) {
        self.accessToken = oAuthTokens.access_token
        self.refreshToken = oAuthTokens.refresh_token
        self.accessTokenValidity = oAuthTokens.expires_in
        self.timestamp = Date()
    }
    
    var accessToken: String?
    var refreshToken: String
    var accessTokenValidity: TimeInterval
    var timestamp: Date
    
    var expiresIn : TimeInterval {
        let expire = timestamp
            .addingTimeInterval(accessTokenValidity)
        return Date().timeIntervalSince(expire)
    }
    
    var assumeExpired: Bool {
        
        let expire = timestamp
            .addingTimeInterval(accessTokenValidity)
        return Date().compare(expire) == .orderedDescending
    }
}
