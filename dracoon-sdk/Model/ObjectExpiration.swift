//
// ObjectExpiration.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct ObjectExpiration: Codable, Sendable {

    /** enabled / disabled */
    public var enableExpiration: Bool
    /** Expiration date */
    public var expireAt: String?

    public init(enableExpiration: Bool, expireAt: String?) {
        self.enableExpiration = enableExpiration
        self.expireAt = expireAt
    }

}

