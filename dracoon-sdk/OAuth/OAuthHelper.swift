//
//  OAuthHelper.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

public class OAuthHelper {
    
    /// Creates the OAuth Authorization url.
    ///
    /// - Parameters:
    ///   - serverUrl: Basic DRACOON URL.
    ///   - clientId: The OAuth client ID.
    ///   - state: Value used to associate a Client session with.
    ///   - userAgentInfo: The userAgentInfo can be used to provide information about the application or device..
    public static func createAuthorizationUrl(serverUrl: URL, clientId: String, state: String, userAgentInfo: String? = nil) throws -> URL {
        guard ValidatorUtils.isValid(serverUrl: serverUrl) else {
            throw DracoonError.invalidParameter(description: "Invalid server url")
        }
        guard !clientId.isEmpty else {
            throw DracoonError.invalidParameter(description: "ClientId is empty")
        }
        guard !state.isEmpty else {
            throw DracoonError.invalidParameter(description: "State is empty")
        }
        
        let base = serverUrl.absoluteString + OAuthConstants.OAUTH_PATH + OAuthConstants.OAUTH_AUTHORIZE_PATH
        
        var query = "response_type=" + OAuthConstants.OAUTH_FLOW + "&"
            + "client_id=" + clientId + "&"
            + "state=" + state
        
        if let info = userAgentInfo {
            let base64String = Data(info.utf8).base64EncodedString()
            if let userAgentInfo = base64String.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
                                                .replacingOccurrences(of: "+", with: "%2B")
                                                .replacingOccurrences(of: "/", with: "%2F")
                                                .replacingOccurrences(of: "=", with: "%3D") {
                query = query + "&" + "user_agent_info=" + userAgentInfo
            }
        }
        
        let url = URL(string: base + "?" + query)!
        return url
    }
    
    public static func createBasicAuthorizationString(clientId: String, clientSecret: String) -> String {
        return "Basic \(Data((clientId + ":" + clientSecret).utf8).base64EncodedString())"
    }
    
    public static func extractAuthorizationState(fromUrl url: URL) -> String? {
        return extractAuthorizationData(fromUrl:url, name:"state")
    }
    
    public static func extractAuthorizationCode(fromUrl url: URL) -> String? {
        return extractAuthorizationData(fromUrl:url, name:"code")
    }
    
    private static func extractAuthorizationData(fromUrl url: URL, name: String) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        return components.queryItems?.first(where: { $0.name == name })?.value
    }
}
