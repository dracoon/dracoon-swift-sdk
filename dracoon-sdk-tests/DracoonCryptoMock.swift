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
    var checkKeyPairSuccess = true
    var decryptFileKeyCalled = false
    var encryptFileKeyCalled = false
    
    func generateUserKeyPair(password: String, version: UserKeyPairVersion) throws -> UserKeyPair {
        self.generateKeyPairCalled = true
        if let error = testError {
            throw error
        }
        let publicKey = UserPublicKey(publicKey: "public", version: .RSA2048)
        let privateKey = UserPrivateKey(privateKey: "private", version: .RSA2048)
        return UserKeyPair(publicKey: publicKey, privateKey: privateKey)
    }
    
    func checkUserKeyPair(keyPair: UserKeyPair, password: String) -> Bool {
        self.checkKeyPairCalled = true
        return self.checkKeyPairSuccess
    }
    
    func encryptFileKey(fileKey: PlainFileKey, publicKey: UserPublicKey) throws -> EncryptedFileKey {
        self.encryptFileKeyCalled = true
        if let error = testError {
            throw error
        }
        return EncryptedFileKey(key: "encryptedFileKey", version: .RSA2048_AES256GCM, iv: "iv", tag: "tag")
    }
    
    func decryptFileKey(fileKey: EncryptedFileKey, privateKey: UserPrivateKey, password: String) throws -> PlainFileKey {
        self.decryptFileKeyCalled = true
        if let error = testError {
            throw error
        }
        return CryptoMock.getPlainFileKey()
    }
    
    func generateFileKey(version: PlainFileKeyVersion) throws -> PlainFileKey {
        if let error = testError {
            throw error
        }
        return CryptoMock.getPlainFileKey()
    }
    
    func createEncryptionCipher(fileKey: PlainFileKey) throws -> EncryptionCipher {
        if let error = testError {
            throw error
        }
        return CryptoMock.getEncryptionCipher()
    }
    
    func createDecryptionCipher(fileKey: PlainFileKey) throws -> DecryptionCipher {
        if let error = testError {
            throw error
        }
        return CryptoMock.getDecyptionCipher()
    }
}

class TestEncryptionCipher {}
