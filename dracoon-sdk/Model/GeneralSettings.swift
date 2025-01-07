//
// GeneralSettings.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/// - Tag: GeneralSettings
public struct GeneralSettings: Codable, Sendable {

    /** Allow sending of share passwords via SMS */
    public var sharePasswordSmsEnabled: Bool?
    /** Activation status of client-side encryption. Can only be enabled once; disabling is not possible. */
    public var cryptoEnabled: Bool?
    /** Enable email notification button */
    public var emailNotificationButtonEnabled: Bool?
    /** Each user has to confirm the EULA at first login. */
    public var eulaEnabled: Bool?
    /** Allow weak password
     A weak password has to fulfill the following criteria:
     * is at least 8 characters long
     * contains letters and numbers
     A strong password has to fulfill the following criteria in addition:
     * contains at least one special character
     * contains upper and lower case characters */
    public var weakPasswordEnabled: Bool?
    /** Defines if S3 is used as storage backend */
    public var useS3Storage: Bool?
    /** Defines if S3 tags are enabled [Since v4.9.0] */
    public var s3TagsEnabled: Bool?
    /** Defines if Homerooms are active [Since v4.10.0] */
    public var homeRoomsActive: Bool?
    /** Homeroom Parent ID [Since v4.10.0] */
    public var homeRoomParentId: Int64?
    
    /** [Deprecated since v4.12.0]
     Determines if the media server is enabled */
    public var mediaServerEnabled: Bool?



}

