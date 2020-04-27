//
//  SharesPasswordPolicies.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 27.04.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import Foundation

public struct SharesPasswordPolicies: Codable {
    
    var characterRules: CharacterRules?
    /** Minimum number of characters a password must contain (must be between 1 and 1024) */
    var minLength: Int?
    /** Determines whether a password must NOT contain word(s) from a dictionary */
    var rejectDictionaryWords: Bool?
    /** Determines whether a password must NOT contain user info (first name, last name, email, user name) */
    var rejectUserInfo: Bool?
    /** Determines whether a password must NOT contain keyboard patterns (e.g. qwertz, asdf; min. 4 character pattern) */
    var rejectKeyboardPatterns: Bool?
    /** Modification date (example: 2018-01-01T00:00:00) */
    var updatedAt: String?
    var updatedBy: UserInfo?
}
