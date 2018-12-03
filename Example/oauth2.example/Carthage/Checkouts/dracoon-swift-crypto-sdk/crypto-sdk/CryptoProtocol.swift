//
//  CryptoProtocol.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public protocol CryptoProtocol {
    func generateUserKeyPair(password: String, version: String) throws -> UserKeyPair
    func checkUserKeyPair(keyPair: UserKeyPair, password: String) -> Bool
    func encryptFileKey(fileKey: PlainFileKey, publicKey: UserPublicKey) throws -> EncryptedFileKey
    func decryptFileKey(fileKey: EncryptedFileKey, privateKey: UserPrivateKey, password: String) throws -> PlainFileKey
    func generateFileKey(version: String) throws -> PlainFileKey
    func createEncryptionCipher(fileKey: PlainFileKey) throws -> FileEncryptionCipher
    func createDecryptionCipher(fileKey: PlainFileKey) throws -> FileDecryptionCipher
}
