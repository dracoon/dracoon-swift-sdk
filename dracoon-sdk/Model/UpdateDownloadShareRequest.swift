//
//  UpdateDownloadShareRequest.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 07.04.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import Foundation

public struct UpdateDownloadShareRequest: Codable {
    
    /** Alias name */
    public var name: String?
    /** Access password */
    public var password: String?
    /** Expiration date / time */
    public var expiration: ObjectExpiration?
    /** User notes Use empty string to remove. */
    public var notes: String?
    /** Show creator first and last name. (default: false) */
    public var showCreatorName: Bool?
    /** Show creator email address. (default: false) */
    public var showCreatorUsername: Bool?
    /** Notify creator on every download. (default: false) */
    public var notifyCreator: Bool?
    /** Max allowed downloads */
    public var maxDownloads: Int?
    /** List of recipient FQTNsvE.123 / E.164 Format */
    public var textMessageRecipients: [String]?
    /** Language tag for messages to receiver.
     Example: de-DE */
    public var receiverLanguage: String?
    /** Country shorthand symbol (cf. ISO 3166-2) */
    public var defaultCountry: String?
    /** Set ‘true’ to reset ‘password’ for Download Share. */
    public var resetPassword: Bool?
    /** Set ‘true’ to reset ‘maxDownloads’ for Download Share. */
    public var resetMaxDownloads: Bool?
    
}
