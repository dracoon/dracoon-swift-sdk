//
//  UserAuthData.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 09.02.21.
//  Copyright © 2021 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: UserAuthData
public struct UserAuthData: Codable, Sendable {
    
    public enum UserAuthenticationMethod: String, Codable, Sendable {
        case basic
        case active_directory
        case radius
        case openid
    }
    
    /** Authentication method */
    public var method: UserAuthenticationMethod
    /** User login name */
    public var login: String?
    /** Password (only relevant for basic authentication type)
     NOT your Active Directory, OpenID or RADIUS password! */
    public var password: String?
    /** Determines whether user has to change his / her password
     default: true for basic auth type, false for active_directory, openid and radius auth types*/
    public var mustChangePassword: Bool?
    /** ID of the user's Active Directory */
    public var adConfigId: Int?
    /** ID of the user's OIDC provider */
    public var oidConfigId: Int?
}
