//
// UserUserPublicKey.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import crypto_sdk


public struct UserUserPublicKey: Codable, Sendable {

    /** Unique identifier for the user */
    public var _id: Int64?
    /** Public key container (private key and version) */
    public var publicKeyContainer: UserPublicKey


    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case publicKeyContainer
    }


}

