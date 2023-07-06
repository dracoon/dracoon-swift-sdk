//
// UploadShare.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/// - Tag: UploadShare
public struct UploadShare: Codable {
    
    /** Share ID */
    public var _id: Int64
    /** Target room or folder ID */
    public var targetId: Int64
    /** Alias name */
    public var name: String
    /** Is share protected by password */
    public var isProtected: Bool
    /** Share access key to generate secure link */
    public var accessKey: String
    /** Creation date */
    public var createdAt: Date
    /** Created by user info */
    public var createdBy: UserInfo
    /** Path to shared upload node */
    public var targetPath: String?
    /** Expiration date */
    public var expireAt: Date?
    /** Encryption state */
    public var isEncrypted: Bool?
    /** User notes Use empty string to remove. */
    public var notes: String?
    /** Number of days after which uploaded files expire */
    public var filesExpiryPeriod: Int?
    /** Total amount of existing files uploaded with this share. */
    public var cntFiles: Int?
    /** Total amount of uploads conducted with this share. */
    public var cntUploads: Int?
    /** Allow display of already uploaded files (default: false) */
    public var showUploadedFiles: Bool?
    /** Base64 encoded qr code image data */
    public var dataUrl: String?
    /** Maximal amount of files to upload */
    public var maxSlots: Int?
    /** Maximal total size of uploaded files (in bytes) */
    public var maxSize: Int64?
    /** Show creator first and last name.
     [Since version 4.11.0] */
    public var showCreatorName: Bool?
    /** Show creator email address.
     [Since version 4.11.0] */
    public var showCreatorUsername: Bool?
    /** Internal notes. Limited to 255 characters.
     [Since version 4.11.0] */
    public var internalNotes: String?
    /** Node type */
    public var targetType: String?
    
    /** [Deprecated since v4.20.0] Notify creator on every upload. (default: false) */
    public var notifyCreator: Bool?
    
    
    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case targetId
        case name
        case isProtected
        case accessKey
        case expireAt
        case notifyCreator
        case createdAt
        case createdBy
        case targetPath
        case isEncrypted
        case notes
        case filesExpiryPeriod
        case cntFiles
        case cntUploads
        case showUploadedFiles
        case dataUrl
        case maxSlots
        case maxSize
        case showCreatorName
        case showCreatorUsername
        case internalNotes
        case targetType
    }
    
    
}

