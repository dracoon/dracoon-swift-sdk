//
// PrivateKeyContainer.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import crypto_sdk

public struct PrivateKeyContainer: Codable, Sendable {

    /** Version */
    public var version: UserKeyPairVersion
    /** Private key */
    public var privateKey: String
    /** Creation date [Since 4.24.0] */
    public var createdAt: Date?
    /** Created by user [Since 4.24.0] */
    public var createdBy: Int64?

    public init(privateKey: String, version: UserKeyPairVersion) {
        self.privateKey = privateKey
        self.version = version
    }

}

