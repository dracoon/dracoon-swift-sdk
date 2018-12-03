//
//  FileDecryptionCipher.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public class FileDecryptionCipher {
    
    private let crypto: CryptoFramework
    private let cipher: Cipher
    private let fileKey: PlainFileKey
    
    init(crypto: CryptoFramework, cipher: Cipher, fileKey: PlainFileKey) {
        self.crypto = crypto
        self.cipher = cipher
        self.fileKey = fileKey
    }
    
    public func processBlock(fileData: Data) throws -> Data {
        guard let plainData = self.crypto.decryptBlock(fileData, cipher: cipher) else {
            throw CryptoError.decrypt("Error processing data")
        }
        return plainData
    }
    
    public func doFinal() throws {
        guard self.crypto.finalizeDecryption(cipher) else {
            throw CryptoError.decrypt("Error finalizing decryption")
        }
    }
    
}
