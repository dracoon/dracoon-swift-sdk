//
//  SharesPasswordPolicies.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 27.04.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import Foundation

public struct SharesPasswordPolicies: Codable {
    
    public init(characterRules: CharacterRules?, minLength: Int?,
                rejectDictionaryWords: Bool?, rejectUserInfo: Bool?,
                rejectKeyboardPatterns: Bool?, updatedAt: String?, updatedBy: UserInfo?) {
        self.characterRules = characterRules
        self.minLength = minLength
        self.rejectDictionaryWords = rejectDictionaryWords
        self.rejectUserInfo = rejectUserInfo
        self.rejectKeyboardPatterns = rejectKeyboardPatterns
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
    /** Modification date (example: 2018-01-01T00:00:00) */
    public var updatedAt: String?
    public var updatedBy: UserInfo?
}
