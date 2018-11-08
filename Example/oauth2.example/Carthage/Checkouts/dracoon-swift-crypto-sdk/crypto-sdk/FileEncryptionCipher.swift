//
//  FileEncryptionCipher.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public class FileEncryptionCipher {
    
    private let crypto: CryptoFramework
    private let cipher: Cipher
    public let fileKey: PlainFileKey
    
    init(crypto: CryptoFramework, cipher: Cipher, fileKey: PlainFileKey) {
        self.crypto = crypto
        self.cipher = cipher
        self.fileKey = fileKey
    }
    
    public func processBlock(fileData: Data) throws -> Data {
        guard let encryptedData = self.crypto.encryptBlock(fileData, cipher: self.cipher, fileKey: self.fileKey.key) else {
            throw CryptoError.encrypt("Error encrypting block")
        }
        return encryptedData
    }
    
    public func doFinal() throws {
        guard let tag = self.crypto.finalizeEncryption(self.cipher) else {
            throw CryptoError.encrypt("Error finalizing encryption")
        }
        self.fileKey.tag = tag
    }
    
}
