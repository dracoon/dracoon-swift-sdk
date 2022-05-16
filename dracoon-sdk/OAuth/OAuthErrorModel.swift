//
//  OAuthErrorModel.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 13.05.22.
//  Copyright © 2022 Dracoon. All rights reserved.
//

import Foundation

public enum OAuthBadRequestErrorCode: String {
    case invalid_request
    case invalid_client
    case invalid_grant
    case unauthorized_client
    case unsupported_grant_type
    case invalid_scope
}

public struct OAuthErrorModel: Codable {
    
    public var error: String
    public var error_description: String?
    
    public func getErrorCode() -> OAuthBadRequestErrorCode? {
        return OAuthBadRequestErrorCode(rawValue: self.error)
    }
    
}
