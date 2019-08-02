//
//  OAuthHelper.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

public class OAuthHelper {
    
    public static func createAuthorizationUrl(serverUrl: URL, clientId: String, state: String, deviceName: String?) -> URL {
        if !ValidatorUtils.isValid(serverUrl: serverUrl) {
            fatalError("Invalid server url")
        }
        precondition(!clientId.isEmpty)
        precondition(!state.isEmpty)
        let base = serverUrl.absoluteString + OAuthConstants.OAUTH_PATH + OAuthConstants.OAUTH_AUTHORIZE_PATH
        
        var query = "response_type=" + OAuthConstants.OAUTH_FLOW + "&"
            + "client_id=" + clientId + "&"
            + "state=" + state
        
        if let name = deviceName {
            let base64String = Data(name.utf8).base64EncodedString()
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
