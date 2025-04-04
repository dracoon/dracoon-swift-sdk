//
//  LoginPasswordPolicies.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 27.04.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import Foundation

public struct LoginPasswordPolicies: Codable, Sendable {
    
    public init(characterRules: CharacterRules?, minLength: Int?,
                rejectDictionaryWords: Bool?, rejectUserInfo: Bool?,
                rejectKeyboardPatterns: Bool?, numberOfArchivedPasswords: Int?,
                passwordExpiration: PasswordExpiration?, userLockout: UserLockout?,
                updatedAt: String?, updatedBy: UserInfo?) {
        self.characterRules = characterRules
        self.minLength = minLength
        self.rejectDictionaryWords = rejectDictionaryWords
        self.rejectUserInfo = rejectUserInfo
        self.rejectKeyboardPatterns = rejectKeyboardPatterns
        self.numberOfArchivedPasswords = numberOfArchivedPasswords
        self.passwordExpiration = passwordExpiration
        self.userLockout = userLockout
        self.updatedAt = updatedAt
        self.updatedBy = updatedBy
    }
    
    public init() {
        // Public initializer
    }
    
    public var characterRules: CharacterRules?
    /** Minimum number of characters a password must contain (must be between 1 and 1024) */
    public var minLength: Int?
    /** Determines whether a password must NOT contain word(s) from a dictionary */
    public var rejectDictionaryWords: Bool?
    /** Determines whether a password must NOT contain user info (first name, last name, email, user name) */
    public var rejectUserInfo: Bool?
    /** Determines whether a password must NOT contain keyboard patterns (e.g. qwertz, asdf; min. 4 character pattern) */
    public var rejectKeyboardPatterns: Bool?
    /** Number of passwords to archive (must be between 0 and 10; 0 means that password history is disabled) */
    public var numberOfArchivedPasswords: Int?
    public var passwordExpiration: PasswordExpiration?
    public var userLockout: UserLockout?
    /** Modification date (example: 2018-01-01T00:00:00) */
    public var updatedAt: String?
    public var updatedBy: UserInfo?
}
