//
// DownloadShare.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/// - Tag: DownloadShare
public struct DownloadShare: Codable {

    /** Share ID */
    public var _id: Int64
    /** Source node ID */
    public var nodeId: Int64
    /** Share access key to generate secure link */
    public var accessKey: String
    /** Downloads counter (incremented on each download) */
    public var cntDownloads: Int
    /** Creation date */
    public var createdAt: Date
    /** Created by user info */
    public var createdBy: UserInfo
    /** Alias name */
    public var name: String?
    /** User notes Use empty string to remove. */
    public var notes: String?
    /** Show creator first and last name. (default: false) */
    public var showCreatorName: Bool?
    /** Show creator email address. (default: false) */
    public var showCreatorUsername: Bool?
    /** Is share protected by password */
    public var isProtected: Bool?
    /** Expiration date */
    public var expireAt: Date?
    /** Max allowed downloads */
    public var maxDownloads: Int?
    /** Path to shared download node */
    public var nodePath: String?
    /** Base64 encoded qr code image data */
    public var dataUrl: String?
    /** Encrypted share (this only applies to shared files, not folders) */
    public var isEncrypted: Bool?
    /** Internal notes. Limited to 255 characters.
     [Since version 4.11.0] */
    public var internalNotes: String?
    /** Node type */
    public var nodeType: String?
    
    /** [Deprecated since v4.20.0] Notify creator on every download. (default: false) */
    public var notifyCreator: Bool?


    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case nodeId
        case accessKey
        case notifyCreator
        case cntDownloads
        case createdAt
        case createdBy
        case name
        case notes
        case showCreatorName
        case showCreatorUsername
        case isProtected
        case expireAt
        case maxDownloads
        case nodePath
        case dataUrl
        case isEncrypted
        case internalNotes
        case nodeType
    }


}

