//
// UserAccount.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct UserAccount: Codable {

    public enum Gender: String, Codable { 
        case m = "m"
        case f = "f"
        case n = "n"
    }
    /** Unique identifier for the user */
    public var _id: Int64
    /** User login name */
    public var login: String
    /** User has changed the password */
    public var needsToChangePassword: Bool
    /** User first name */
    public var firstName: String
    /** User last name */
    public var lastName: String
    /** User lock status: * &#x60;0&#x60; - locked * &#x60;1&#x60; - Web access allowed * &#x60;2&#x60; - Web and mobile access allowed */
    public var lockStatus: Int
    /** User has manageable rooms */
    public var hasManageableRooms: Bool
    /** Customer information */
    public var customer: CustomerData
    /** List of user roles */
    public var userRoles: RoleList
    /** Authentication methods: * &#x60;sql&#x60; * &#x60;active_directory&#x60; * &#x60;radius&#x60; * &#x60;openid&#x60; */
    public var authMethods: [UserAuthMethod]
    /** If true, the user must change the &#x60;userName&#x60; at the first login. (default: false) */
    public var needsToChangeUserName: Bool?
    /** User has accepted EULA. Present, if EULA is system global active. cf. &#x60;GET config/settings&#x60; - &#x60;eula_active&#x60; */
    public var needsToAcceptEULA: Bool?
    /** Job title */
    public var title: String?
    /** Gender */
    public var gender: Gender?
    /** Expiration date */
    public var expireAt: Date?
    /** User has generated private key. Possible if **TripleCrypt™ technology** is active for this customer */
    public var isEncryptionEnabled: Bool?
    /** Last successful logon date */
    public var lastLoginSuccessAt: Date?
    /** Last failed logon date */
    public var lastLoginFailAt: Date?
    /** All groups the user is member of */
    public var userGroups: [UserGroup]?
    /** User attributes */
    public var userAttributes: UserAttributes?
    /** Email (not used) */
    public var email: String?
    /** Last successful logon IP address */
    public var lastLoginSuccessIp: String?
    /** Last failed logon IP address */
    public var lastLoginFailIp: String?


    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case login
        case needsToChangePassword
        case firstName
        case lastName
        case lockStatus
        case hasManageableRooms
        case customer
        case userRoles
        case authMethods
        case needsToChangeUserName
        case needsToAcceptEULA
        case title
        case gender
        case expireAt
        case isEncryptionEnabled
        case lastLoginSuccessAt
        case lastLoginFailAt
        case userGroups
        case userAttributes
        case email
        case lastLoginSuccessIp
        case lastLoginFailIp
    }


}

