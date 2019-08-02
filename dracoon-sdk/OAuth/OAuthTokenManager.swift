//
//  OAuthTokenManager.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

protocol OAuthInterceptor: RequestAdapter, RequestRetrier {
    
    var oAuthClient: OAuthClient { get }
    var mode: DracoonAuthMode { get }
    
    init(authMode: DracoonAuthMode, oAuthClient: OAuthClient)
    
    func setOAuthDelegate(_ delegate: OAuthTokenChangedDelegate?)
    func getAccessToken() -> String?
    func getRefreshToken() -> String?
    
}

class OAuthTokenManager: OAuthInterceptor {
    
    var oAuthClient: OAuthClient
    var mode: DracoonAuthMode
    
    weak var delegate: OAuthTokenChangedDelegate?
    
    required init(authMode: DracoonAuthMode, oAuthClient: OAuthClient) {
        self.mode = authMode
        self.oAuthClient = oAuthClient
        self.getToken{_, _ in}
    }
    
    func setOAuthDelegate(_ delegate: OAuthTokenChangedDelegate?) {
        self.delegate = delegate
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if urlRequest.allHTTPHeaderFields?.contains(where: { $0.key == DracoonConstants.AUTHORIZATION_HEADER }) ?? false {
            return urlRequest
        }
        
        var accessToken:String?
        
        switch mode {
        case .accessToken(let token):
            accessToken = token
        case .authorizationCode(let clientId, let clientSecret, let authorizationCode):
            throw DracoonError.authorization_code_flow_in_progress(clientId: clientId, clientSecret: clientSecret, authorizationCode: authorizationCode)
        case .accessRefreshToken(_, _, let tokens):
            if tokens.assumeExpired || tokens.accessToken == nil {
                throw DracoonError.authorization_token_expired
            }
            
            accessToken = tokens.accessToken
        }
        
        var urlRequest = urlRequest
        
        if let accessToken = accessToken, urlRequest.url!.absoluteString.hasPrefix(oAuthClient.serverUrl.absoluteString) {
            urlRequest.setValue("\(DracoonConstants.AUTHORIZATION_TYPE) \(accessToken)", forHTTPHeaderField: DracoonConstants.AUTHORIZATION_HEADER)
        }
        
        return urlRequest
    }
    
    // prevents other failed requests to also try to get a new access token
    private let lock = NSRecursiveLock()
    // contains the completion handlers of the requests that wait for a new access token
    private var requestsToRetry: [RequestRetryCompletion] = []
    // indicates that a request is trying to get a new access token
    private var isRefreshing = false
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        // either we get an unauthorized response or the error code explicitly state that the token is expired or we are in code flow
        if isUnauthorized(request: request) || isExpiredOrCodeFlow(error: error) {
            lock.lock(); defer { lock.unlock() }
            requestsToRetry.append(completion)
            if !isRefreshing {
                
                getToken { [weak self] retry, time in
                    
                    guard let strongSelf = self else { return }
                    strongSelf.lock.lock()
                    defer {
                        strongSelf.isRefreshing = false
                        strongSelf.lock.unlock()
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(retry, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
                
            }
            
            
        } else {
            completion(false, 0.0)
        }
    }
    
    private func isUnauthorized(request: Alamofire.Request) -> Bool {
        guard let response = request.task?.response as? HTTPURLResponse else { return false }
        return response.statusCode == 401
    }
    
    private func isExpiredOrCodeFlow(error: Error) -> Bool {
        guard let dracoonError = error as? DracoonError else { return false }
        switch dracoonError {
        case .authorization_token_expired: fallthrough
        case .authorization_code_flow_in_progress(_, _, _): return true
        default: return false
        }
    }
    
    public func getAccessToken() -> String? {
        switch mode {
        case .authorizationCode(_, _, _):
            return nil
        case .accessToken(let accessToken):
            return accessToken
        case .accessRefreshToken(_, _, let tokens):
            return tokens.accessToken
        }
    }
    
    public func getRefreshToken() -> String? {
        switch mode {
        case .authorizationCode(_, _, _):
            return nil
        case .accessToken(_):
            return nil
        case .accessRefreshToken(_, _, let tokens):
            return tokens.refreshToken
        }
    }
    
    private func getToken(completion: @escaping RequestRetryCompletion) {
        guard !isRefreshing else { return }
        isRefreshing = true
        
        switch mode {
        case .accessRefreshToken(let clientId, let clientSecret, let tokens):
            oAuthClient.refreshAccessToken(clientId: clientId, clientSecret: clientSecret, refreshToken: tokens.refreshToken, delegate: self.delegate) { result in
                switch result {
                case .value(let tokens):
                    self.mode = .accessRefreshToken(clientId: clientId, clientSecret: clientSecret, tokens: DracoonTokens(oAuthTokens: tokens))
                    self.delegate?.tokenChanged(accessToken: tokens.access_token, refreshToken: tokens.refresh_token)
                    completion(true, 0)
                case .error:
                    completion(false, 0)
                }
                self.isRefreshing = false
            }
        case .authorizationCode(let clientId, let clientSecret, let authorizationCode):
            oAuthClient.getAccessToken(clientId: clientId, clientSecret: clientSecret, code: authorizationCode) { result in
                switch result {
                case .value(let tokens):
                    self.mode = .accessRefreshToken(clientId: clientId, clientSecret: clientSecret,tokens: DracoonTokens(oAuthTokens: tokens))
                    self.delegate?.tokenChanged(accessToken: tokens.access_token, refreshToken: tokens.refresh_token)
                    completion(true, 0)
                case .error:
                    completion(false, 0)
                }
                self.isRefreshing = false
            }
        case .accessToken:
            completion(false, 0)
            self.isRefreshing = false
        }
        
    }
}
