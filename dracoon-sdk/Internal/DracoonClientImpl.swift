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
    
    /// Initializes a DracoonClient
    ///
    /// - Parameters:
    ///   - serverUrl: The web address of a DRACOON instance
    ///   - authMode: The OAuth2 mode. Mode _authorizationCode_ can be used during initial code flow
    ///     and mode _accessRefreshToken_ once access and refresh token are retrieved.
    ///   - getEncryptionPassword: Function which returns the password the user's private key is encrypted with
    ///   - sessionConfiguration: Custom configuration can be passed here, otherwise default configuration is used.
    ///   - oauthClient: Custom [OAuthClient](x-source-tag://OAuthClient) implementation can be passed here, otherwise internal implementation is used.
    ///   - oauthCallback: The [OAuthTokenChangedDelegate](x-source-tag://OAuthTokenChangedDelegate) informs about token changes.
    ///   - rateLimitHandler: Custom [RateLimitInterceptor](x-source-tag://RateLimitInterceptor) implementation can be passed here, otherwise internal implementation is used.
    ///   - rateLimitCallback: The [RateLimitAppliedDelegate](x-source-tag://RateLimitAppliedDelegate) informs about rate limit changes.
    public init(serverUrl: URL,
                authMode: DracoonAuthMode,
                getEncryptionPassword: @Sendable @escaping () -> String?,
                sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default,
                oauthClient: OAuthClient? = nil,
                oauthCallback: OAuthTokenChangedDelegate? = nil,
                rateLimitHandler: RateLimitInterceptor? = nil,
                rateLimitCallback: RateLimitAppliedDelegate? = nil) {
        
        if sessionConfiguration.identifier != nil {
            fatalError("Initalization with background config is not supported.")
        }
        
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
        
        oAuthTokenManager = OAuthTokenManager(authMode: authMode,
                                              oAuthClient: oauthClient ?? OAuthClientImpl(serverUrl: trimmedUrl))
        oAuthTokenManager.setOAuthDelegate(oauthCallback)
        rateLimitInterceptor = rateLimitHandler ?? RateLimitManager()
        rateLimitInterceptor.setRateLimitAppliedDelegate(rateLimitCallback)
        let interceptors = Interceptor(interceptors: [rateLimitInterceptor, oAuthTokenManager])
        let session = Alamofire.Session(configuration: sessionConfiguration, interceptor: interceptors)
        oAuthTokenManager.startOAuthSession(session)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            if let secondsDate = DateFormatter.dracoonFormatter.date(from: dateStr) {
                return secondsDate
            } else if let millisecondsDate = DateFormatter.dracoonMillisecondsFormatter.date(from: dateStr) {
                return millisecondsDate
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Error decoding date string \(dateStr)")
        })
        let encoder = JSONEncoder()
        let crypto = Crypto()
        
        let requestConfig = DracoonRequestConfig(session: session, serverUrl: trimmedUrl, apiPath: DracoonConstants.API_PATH, oauthTokenManager: oAuthTokenManager, encoder: encoder, decoder: decoder)
        
        server = DracoonServerImpl(config: requestConfig)
        account = DracoonAccountImpl(config: requestConfig, crypto: crypto)
        config = DracoonConfigImpl(config: requestConfig)
        users = DracoonUsersImpl(config: requestConfig)
        groups = NotImplementedYet()
        settings = DracoonSettingsImpl(config: requestConfig)
        nodes = DracoonNodesImpl(requestConfig: requestConfig, crypto: crypto, account: account, config: config, getEncryptionPassword: getEncryptionPassword)
        shares = DracoonSharesImpl(requestConfig: requestConfig, nodes: nodes, account: account, server: server, getEncryptionPassword: getEncryptionPassword)
        subscriptions = DracoonSubscriptionsImpl(config: requestConfig)
    }
    
    let oAuthTokenManager: OAuthInterceptor
    
    let rateLimitInterceptor: RateLimitInterceptor
    
    public var server: DracoonServer
    
    public var account: DracoonAccount
    
    public var config: DracoonConfig
    
    public var users: DracoonUsers
    
    public var groups: DracoonGroups
    
    public var nodes: DracoonNodes
    
    public var shares: DracoonShares
    
    public var settings: DracoonSettings
    
    public var subscriptions: DracoonSubscriptions
    
    final class NotImplementedYet: DracoonGroups, Sendable {
    }
    
    public func getAccessToken() -> String? {
        return self.oAuthTokenManager.getAccessToken()
    }
    
    public func getRefreshToken() -> String? {
        return self.oAuthTokenManager.getRefreshToken()
    }
    
    public func revokeOAuthToken(completion: ((DracoonError?) -> Void)?) {
        self.oAuthTokenManager.revokeTokens(completion: completion)
    }
    
    public func restoreRateLimitExpiration(_ date: Date) {
        self.rateLimitInterceptor.restoreExpirationDate(date)
    }
}

public extension Formatter {
    static let dracoonFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    static let dracoonMillisecondsFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
}
