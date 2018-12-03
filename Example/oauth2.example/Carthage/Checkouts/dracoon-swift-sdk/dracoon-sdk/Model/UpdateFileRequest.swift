//
// UpdateFileRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct UpdateFileRequest: Codable {

    /** File name */
    public var name: String?
    /** Expiration date / time */
    public var expiration: ObjectExpiration?
    /** Expiration date / time */
    public var classification: Int?
    /** User notes Use empty string to remove. */
    public var notes: String?



}

