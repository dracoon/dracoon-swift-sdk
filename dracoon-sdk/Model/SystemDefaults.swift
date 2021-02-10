//
// SystemDefaults.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/// - Tag: SystemDefaults
public struct SystemDefaults: Codable {

    /** Define which language should be default. */
    public var languageDefault: String?
    /** Default expiration period for Download Shares in days. */
    public var downloadShareDefaultExpirationPeriod: Int?
    /** Default expiration period for Upload Shares in days. */
    public var uploadShareDefaultExpirationPeriod: Int?
    /** Default expiration period for all uploaded files in days. */
    public var fileDefaultExpirationPeriod: Int?
    /** Defines if new users get the role Non Member Viewer by default [Since v4.12.0] */
    public var nonmemberViewerDefault: Bool?
    /** Defines if login fields should be hidden [Since v4.13.0] */
    public var hideLoginInputFields: Bool?


}

