//
//  PasswordPoliciesConfig.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 27.04.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import Foundation

public enum PasswordCharacterRules: String, Codable {
    case alpha
    case uppercase
    case lowercase
    case numeric
    case special
    case all
    case none
}

public struct CharacterRules: Codable {
    /** Characters which a password must contain:
    alpha - at least one alphabetical character (uppercase OR lowercase)
    uppercase - at least one uppercase character
    lowercase - at least one lowercase character
    numeric - at least one numeric character
    special - at least one special character (letters and digits excluded)
    all - combination of uppercase, lowercase, numeric and special */
    public var mustContainCharacters: [PasswordCharacterRules]
    /** Number of characteristics to enforce
    e.g. from ["uppercase", "lowercase", "numeric", "special"]
    all 4 character sets can be enforced; but also only 2 of them
    (must be between 0 and 4) */
    public var numberOfCharacteristicsToEnforce: Int?
    
    public init(mustContainCharacters: [PasswordCharacterRules],
                numberOfCharacteristicsToEnforce: Int?) {
        self.mustContainCharacters = mustContainCharacters
        self.numberOfCharacteristicsToEnforce = numberOfCharacteristicsToEnforce
    }
}

public struct PasswordExpiration: Codable {
    /** Determines whether password expiration is enabled */
    public var enabled: Bool
    /** Maximum allowed password age (in days) */
    public var maxPasswordAge: Int?
    
    public init(enabled: Bool, maxPasswordAge: Int?) {
        self.enabled = enabled
        self.maxPasswordAge = maxPasswordAge
    }
}

public struct UserLockout: Codable {
    /** Determines whether user lockout is enabled */
    public var enabled: Bool
    /** Maximum allowed number of failed login attempts */
    public var maxNumberOfLoginFailures: Int?
    /** Amount of minutes a user has to wait to make another login attempt after maxNumberOfLoginFailures has been exceeded */
    public var lockoutPeriod: Int?
    
    public init(enabled: Bool, maxNumberOfLoginFailures: Int?, lockoutPeriod: Int?) {
        self.enabled = enabled
        self.maxNumberOfLoginFailures = maxNumberOfLoginFailures
        self.lockoutPeriod = lockoutPeriod
    }
}

/// - Tag: PasswordPoliciesConfig
public struct PasswordPoliciesConfig: Codable {
    public var loginPasswordPolicies: LoginPasswordPolicies?
    public var sharesPasswordPolicies: SharesPasswordPolicies?
    public var encryptionPasswordPolicies: EncryptionPasswordPolicies?
}
