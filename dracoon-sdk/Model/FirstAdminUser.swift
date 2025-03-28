//
// FirstAdminUser.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct FirstAdminUser: Codable, Sendable {

    /** User first name */
    public var firstName: String
    /** User last name */
    public var lastName: String
    /** Username [Since v4.13.0] */
    public var userName: String?
    /** User Authentication Data */
    public var authData: UserAuthData?
    /** IETF language tag */
    public var receiverLanguage: String?
    /** Notify user about his new account
     default: true for basic auth type, false for active_directory, openid and radius auth types */
    public var notifyUser: Bool?
    /** Email  */
    public var email: String?
    /** Phone number */
    public var phone: String?
    
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
     An initial password may be preset */
    public var password: String?
    /** [Deprecated since v4.13.0]
     User has changed the password */
    public var needsToChangePassword: Bool?
    /** [Deprecated since v4.13.0]
     If true, the user must change the &#x60;userName&#x60; at the first login. (default: false) */
    public var needsToChangeUserName: Bool?
    /** [Deprecated since v4.12.0]
     Gender */
    public var gender: Gender?
    
    public enum Gender: String, Codable, Sendable {
        case m = "m"
        case f = "f"
        case n = "n"
    }



}

