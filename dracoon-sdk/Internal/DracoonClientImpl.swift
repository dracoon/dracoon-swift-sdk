//
//  DracoonClientImpl.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk


public class DracoonClientImpl: DracoonClient {
    
    fileprivate let oAuthTokenManager: OAuthTokenManager
    
    public init(serverUrl: URL,
                authMode: DracoonAuthMode,
                getEncryptionPassword: @escaping () -> String?,
                sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default,
                oauthClient: OAuthClient? = nil,
                oauthCallback: OAuthTokenChangedDelegate? = nil) {
        
        let trimmedUrl: URL
        if serverUrl.absoluteString.hasSuffix("/") {
            let stringRepresentation = String(serverUrl.absoluteString.dropLast())
            guard let newUrl = URL(string: stringRepresentation) else {
                fatalError("Invalid server address passed to Dracoon SDK: \(serverUrl)")
            }
            trimmedUrl = newUrl
        } else {
            trimmedUrl = serverUrl
        }
        
        let sessionManager = Alamofire.SessionManager(configuration: sessionConfiguration)
        
        oAuthTokenManager = OAuthTokenManager(authMode: authMode,
                                              oAuthClient: oauthClient ?? OAuthClientImpl(serverUrl: trimmedUrl, sessionManager: sessionManager))
        oAuthTokenManager.delegate = oauthCallback
        
        sessionManager.retrier = oAuthTokenManager
        sessionManager.adapter = oAuthTokenManager
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.dracoonFormatter)
        let encoder = JSONEncoder()
        let crypto = Crypto()
        
        let requestConfig = DracoonRequestConfig(sessionManager: sessionManager, serverUrl: trimmedUrl, apiPath: DracoonConstants.API_PATH, oauthTokenManager: oAuthTokenManager, encoder: encoder, decoder: decoder)
        
        server = DracoonServerImpl(config: requestConfig)
        account = DracoonAccountImpl(config: requestConfig, crypto: crypto)
        config = DracoonConfigImpl(config: requestConfig)
        users = NotImplementedYet()
        groups = NotImplementedYet()
        settings = DracoonSettingsImpl(config: requestConfig)
        nodes = DracoonNodesImpl(config: requestConfig, crypto: crypto, account: account, getEncryptionPassword: getEncryptionPassword)
        shares = DracoonSharesImpl(config: requestConfig, nodes: nodes, account: account, getEncryptionPassword: getEncryptionPassword)
    }
    
    public var server: DracoonServer
    
    public var account: DracoonAccount
    
    public var config: DracoonConfig
    
    public var users: DracoonUsers
    
    public var groups: DracoonGroups
    
    public var nodes: DracoonNodes
    
    public var shares: DracoonShares
    
    public var settings: DracoonSettings
    
    
    class NotImplementedYet: DracoonUsers, DracoonGroups {
    }
    
    public func getAccessToken() -> String? {
        return self.oAuthTokenManager.getAccessToken()
    }
    
    public func getRefreshToken() -> String? {
        return self.oAuthTokenManager.getRefreshToken()
    }
}

extension Formatter {
    static let dracoonFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
}
