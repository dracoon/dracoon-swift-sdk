//
//  UpdateUploadShareRequest.swift
//  dracoon-sdk
//
//  Copyright © 2020 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: UpdateUploadShareRequest
public struct UpdateUploadShareRequest: Codable, Sendable {
    
    /** Alias name */
    public var name: String?
    /** Password */
    public var password: String?
    /** Expiration date / time */
    public var expiration: ObjectExpiration?
    /** Number of days after which uploaded files expire */
    public var filesExpiryPeriod: Int?
    /** Internal notes. Limited to 255 characters. */
    public var internalNotes: String?
    /** User notes. Use empty string to remove. Limited to 255 characters. */
    public var notes: String?
    /** Show creator first and last name. */
    public var showCreatorName: Bool?
    /** Show creator email address. */
    public var showCreatorUsername: Bool?
    /** Notify creator on every upload. (default: false) */
    public var notifyCreator: Bool?
    /** Allow display of already uploaded files (default: false) */
    public var showUploadedFiles: Bool?
    /** Maximal amount of files to upload */
    public var maxSlots: Int?
    /** Maximal total size of uploaded files (in bytes) */
    public var maxSize: Int64?
    /** List of recipient FQTNs E.123 / E.164 Format */
    public var textMessageRecipients: [String]?
    /** Language tag for messages to receiver.
     Example: de-DE */
    public var receiverLanguage: String?
    /** Country shorthand symbol (cf. ISO 3166-2) */
    public var defaultCountry: String?
    /** Set ‘true’ to reset ‘password’ for Upload Share. */
    public var resetPassword: Bool?
    /** Set ‘true’ to reset ‘filesExpiryPeriod’ for Upload Share. */
    public var resetFilesExpiryPeriod: Bool?
    /** Set ‘true’ to reset ‘maxSlots’ for Upload Share. */
    public var resetMaxSlots: Bool?
    /** Set ‘true’ to reset ‘maxSize’ for Upload Share. */
    public var resetMaxSize: Bool?
}
