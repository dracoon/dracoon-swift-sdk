//
// UserKeyPairContainer.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import crypto_sdk

/// - Tag: UserKeyPairContainer
public struct UserKeyPairContainer: Codable {

    /** Private key container (private key and version) */
    public var privateKeyContainer: PrivateKeyContainer
    /** Public key container (private key and version) */
    public var publicKeyContainer: PublicKeyContainer

    public init(publicKeyContainer: PublicKeyContainer, privateKeyContainer: PrivateKeyContainer) {
        self.publicKeyContainer = publicKeyContainer
        self.privateKeyContainer = privateKeyContainer
    }
    
    public init(publicKey: String, publicVersion: UserKeyPairVersion, privateKey: String, privateVersion: UserKeyPairVersion) {
        self.publicKeyContainer = PublicKeyContainer(publicKey: publicKey,
                                                    version: publicVersion)
         self.privateKeyContainer = PrivateKeyContainer(privateKey: privateKey,
                                                      version: privateVersion)
    }

}

