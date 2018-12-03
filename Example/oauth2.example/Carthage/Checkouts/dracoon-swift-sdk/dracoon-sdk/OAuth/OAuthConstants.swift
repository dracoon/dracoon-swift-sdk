//
//  OAuthConstants.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public struct OAuthConstants {
    
    public static let OAUTH_PATH = "/oauth";
    
    public static let OAUTH_AUTHORIZE_PATH = "/authorize";
    public static let OAUTH_TOKEN_PATH = "/token";
    
    public static let OAUTH_FLOW = "code";
    
    public struct OAuthGrantTypes {
        public static let AUTHORIZATION_CODE = "authorization_code";
        public static let REFRESH_TOKEN = "refresh_token";
    }
}
