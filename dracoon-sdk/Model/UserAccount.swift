//
// UserAccount.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/// - Tag: UserAccount
public struct UserAccount: Codable {
    /** Unique identifier for the user */
    public var _id: Int64
    /** Username
     [Since version 4.13.0] */
    public var userName: String?
    /** User first name */
    public var firstName: String
    /** User last name */
    public var lastName: String
    /** Determines if  user is locked */
    public var isLocked: Bool
    /** User has manageable rooms */
    public var hasManageableRooms: Bool
    /** List of user roles */
    public var userRoles: RoleList
    /** IETF language tag
     [Since version 4.20.0] */
    public var language: String?
    /** User Authentication Data */
    public var authData: UserAuthData?
    /** If true, the user must set the email at the first login.
     [Since version 4.13.0] */
    public var mustSetEmail: Bool?
    /** User has accepted EULA. Present if EULA is system globally active.*/
    public var needsToAcceptEULA: Bool?
    /** Expiration date */
    public var expireAt: Date?
    /** User has generated private key. Possible if client-side encryption is active for this customer. */
    public var isEncryptionEnabled: Bool?
    /** Last successful logon date */
    public var lastLoginSuccessAt: Date?
    /** Last failed logon date */
    public var lastLoginFailAt: Date?
    /** Email */
    public var email: String?
    /** Phone number */
    public var phone: String?
    /** The id of the users Home Room **/
    public var homeRoomId: Int64?
    /** All groups the user is member of */
    public var userGroups: [UserGroup]?
    /** User attributes */
    public var userAttributes: UserAttributes?
    
    /** [Deprecated since v4.18.0]
     Job title */
    public var title: String?
    /** [Deprecated since 4.13.0]
     Please use authData.login instead.
     User login name */
    public var login: String?
    /** [Deprecated since v4.13.0]
     Authentication methods: * &#x60;sql&#x60; * &#x60;active_directory&#x60; * &#x60;radius&#x60; * &#x60;openid&#x60; */
    public var authMethods: [UserAuthMethod]?
    /** [Deprecated since v4.13.0]
     User has changed the password */
    public var needsToChangePassword: Bool?
    /** [Deprecated since v4.13.0]
     If true, the user must change the &#x60;userName&#x60; at the first login. (default: false) */
    public var needsToChangeUserName: Bool?
    /** [Deprecated since v4.12.0]
     Gender */
    public var gender: Gender?
    
    public enum Gender: String, Codable {
        case m = "m"
        case f = "f"
        case n = "n"
    }

    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case login
        case needsToChangePassword
        case firstName
        case lastName
        case isLocked
        case hasManageableRooms
        case userRoles
        case authData
        case authMethods
        case needsToChangeUserName
        case needsToAcceptEULA
        case title
        case gender
        case expireAt
        case isEncryptionEnabled
        case userGroups
        case userAttributes
        case email
        case homeRoomId
        case mustSetEmail
    }


}

