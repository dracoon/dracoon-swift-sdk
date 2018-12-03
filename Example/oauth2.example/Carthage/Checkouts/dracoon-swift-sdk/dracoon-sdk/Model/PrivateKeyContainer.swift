//
// PrivateKeyContainer.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct PrivateKeyContainer: Codable {

    /** Version */
    public var version: String
    /** Private key */
    public var privateKey: String

    public init(privateKey: String, version: String) {
        self.privateKey = privateKey
        self.version = version
    }

}

