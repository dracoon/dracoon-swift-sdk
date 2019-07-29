//
//  DracoonCryptoMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 29.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import crypto_sdk
@testable import dracoon_sdk

class DracoonCryptoMock: CryptoProtocol {
    
    var testError: DracoonError?
    var generateKeyPairCalled = false
    var checkKeyPairCalled = false
    
    func generateUserKeyPair(password: String, version: String) throws -> UserKeyPair {
        self.generateKeyPairCalled = true
        if let error = testError {
            throw error
        }
        let publicKey = UserPublicKey(publicKey: "public", version: "test")
        let privateKey = UserPrivateKey(privateKey: "private", version: "test")
        return UserKeyPair(publicKey: publicKey, privateKey: privateKey)
    }
    
    func checkUserKeyPair(keyPair: UserKeyPair, password: String) -> Bool {
        self.checkKeyPairCalled = true
        return true
    }
    
    func encryptFileKey(fileKey: PlainFileKey, publicKey: UserPublicKey) throws -> EncryptedFileKey {
        if let error = testError {
            throw error
        }
        return EncryptedFileKey(key: "encryptedFileKey", version: "test", iv: "iv", tag: "tag")
    }
    
    func decryptFileKey(fileKey: EncryptedFileKey, privateKey: UserPrivateKey, password: String) throws -> PlainFileKey {
        if let error = testError {
            throw error
        }
        return CryptoMock.getPlainFileKey()
    }
    
    func generateFileKey(version: String) throws -> PlainFileKey {
        if let error = testError {
            throw error
        }
        return CryptoMock.getPlainFileKey()
    }
    
    func createEncryptionCipher(fileKey: PlainFileKey) throws -> FileEncryptionCipher {
        if let error = testError {
            throw error
        }
        return CryptoMock.getEncryptionCipher()
    }
    
    func createDecryptionCipher(fileKey: PlainFileKey) throws -> FileDecryptionCipher {
        if let error = testError {
            throw error
        }
        return CryptoMock.getDecyptionCipher()
    }
}
