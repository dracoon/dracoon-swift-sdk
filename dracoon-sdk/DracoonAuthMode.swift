//
//  DracoonAuthMode.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public enum DracoonAuthMode: Sendable {
    case authorizationCode(clientId: String, clientSecret: String, authorizationCode: String)
    case accessToken(accessToken: String)
    case accessRefreshToken(clientId: String, clientSecret: String, tokens: DracoonTokens)
}
