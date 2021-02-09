//
// UserData.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct UserData: Codable {

    /** Unique identifier for the user */
    public var _id: Int64
    /** Username
     [Since version 4.13.0] */
    public var userName: String?
    /** User first name */
    public var firstName: String
    /** User last name */
    public var lastName: String
    /** User Authentication Data */
    public var authData: UserAuthData?
    /** Email (not used) */
    public var email: String
    /** Phone number */
    public var phone: String?
    /** Determines if  user is locked */
    public var isLocked: Bool
    /** Expiration date */
    public var expireAt: Date?
    /** User has manageable rooms */
    public var hasManageableRooms: Bool?
    /** User has generated private key. Possible if client-side encryption is active for this customer */
    public var isEncryptionEnabled: Bool?
    /** Last successful logon date */
    public var lastLoginSuccessAt: Date?
    /** Public key container (private key and version) */
    public var publicKeyContainer: PublicKeyContainer?
    /** List of user roles */
    public var userRoles: RoleList?
    /** User attributes */
    public var userAttributes: UserAttributes?
    
    /** [Deprecated since v4.18.0]
     Job title */
    public var title: String?
    /** [Deprecated since 4.13.0]
     User login name */
    public var login: String
    /** [Deprecated since v4.13.0]
     Please use authData.login instead.
     Authentication methods: * &#x60;sql&#x60; * &#x60;active_directory&#x60; * &#x60;radius&#x60; * &#x60;openid&#x60; */
    public var authMethods: [UserAuthMethod]
    /** [Deprecated since v4.12.0]
     Gender */
    public var gender: Gender?
    /** [Deprecated since v4.7.0]
     User lock status: * &#x60;0&#x60; - locked * &#x60;1&#x60; - Web access allowed * &#x60;2&#x60; - Web and mobile access allowed */
    public var lockStatus: Int
    
    public enum Gender: String, Codable {
        case m = "m"
        case f = "f"
        case n = "n"
    }

    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case login
        case firstName
        case lastName
        case isLocked
        case lockStatus
        case authData
        case authMethods
        case email
        case phone
        case title
        case gender
        case expireAt
        case hasManageableRooms
        case isEncryptionEnabled
        case lastLoginSuccessAt
        case publicKeyContainer
        case userRoles
        case userAttributes
    }


}

