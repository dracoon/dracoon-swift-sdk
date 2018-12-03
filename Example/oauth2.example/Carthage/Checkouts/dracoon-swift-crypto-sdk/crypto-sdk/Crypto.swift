//
//  Crypto.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public typealias Cipher = NSValue

public class Crypto : CryptoProtocol {
    
    private let crypto: CryptoFramework
    
    public init() {
        crypto = OpenSslCrypto()
    }
    
    // MARK: --- KEY MANAGEMENT ---
    
    public func generateUserKeyPair(password: String, version: String = CryptoConstants.DEFAULT_VERSION) throws -> UserKeyPair {
        
        guard !password.isEmpty else {
            throw CryptoError.generate("Password can't be empty")
        }
        
        guard version == CryptoConstants.DEFAULT_VERSION else {
            throw CryptoError.generate("Unknown key pair version")
        }
        
        guard let keyDictionary = crypto.createUserKeyPair(password),
            let publicKey = keyDictionary["public"] as? String,
            let privateKey = keyDictionary["private"] as? String else {
                throw CryptoError.generate("Error creating key pair")
        }
        
        guard crypto.canDecryptPrivateKey(privateKey, withPassword: password) else {
            throw CryptoError.generate("Error checking key pair")
        }
        
        let userPublicKey = UserPublicKey(publicKey: publicKey,
                                          version: version)
        
        let userPrivateKey = UserPrivateKey(privateKey: privateKey,
                                            version: version)
        
        let userKeyPair = UserKeyPair(publicKey: userPublicKey,
                                      privateKey: userPrivateKey)
        
        return userKeyPair
    }
    
    public func checkUserKeyPair(keyPair: UserKeyPair, password: String) -> Bool {
        
        guard
            keyPair.privateKeyContainer.version == CryptoConstants.DEFAULT_VERSION,
            keyPair.publicKeyContainer.version == CryptoConstants.DEFAULT_VERSION
            else {
                return false
        }
        
        return crypto.canDecryptPrivateKey(keyPair.privateKeyContainer.privateKey, withPassword: password)
    }
    
    // MARK: --- ASYMMETRIC ENCRYPTION AND DECRYPTION ---
    
    public func encryptFileKey(fileKey: PlainFileKey, publicKey: UserPublicKey) throws -> EncryptedFileKey {
        
        guard let iv = fileKey.iv, let tag = fileKey.tag else {
            throw CryptoError.encrypt("Incomplete FileKey")
        }
        
        guard let encryptedFileKey = crypto.encryptFileKey(fileKey.key, publicKey: publicKey.publicKey) else {
            throw CryptoError.encrypt("Error encrypting FileKey")
        }
        let encryptedFileKeyContainer = EncryptedFileKey(key: encryptedFileKey,
                                                         version: fileKey.version,
                                                         iv: iv,
                                                         tag: tag)
        return encryptedFileKeyContainer
    }
    
    public func decryptFileKey(fileKey: EncryptedFileKey, privateKey: UserPrivateKey, password: String) throws -> PlainFileKey {
        
        guard let decryptedFileKey = crypto.decryptFileKey(fileKey.key, privateKey: privateKey.privateKey, password: password) else {
            throw CryptoError.decrypt("Error decrypting FileKey")
        }
        let plainFileKeyContainer = PlainFileKey(key: decryptedFileKey, version: fileKey.version)
        plainFileKeyContainer.iv = fileKey.iv
        plainFileKeyContainer.tag = fileKey.tag
        return plainFileKeyContainer
    }
    
    // MARK: --- SYMMETRIC ENCRYPTION AND DECRYPTION ---
    
    public func generateFileKey(version: String = CryptoConstants.DEFAULT_VERSION) throws -> PlainFileKey {
        
        guard version == CryptoConstants.DEFAULT_VERSION else {
            throw CryptoError.generate("Unknown key pair version")
        }
        
        guard let key = crypto.createFileKey() else {
            throw CryptoError.generate("Error creating file key")
        }
        let fileKey = PlainFileKey(key: key, version: version)
        return fileKey
    }
    
    public func createEncryptionCipher(fileKey: PlainFileKey) throws -> FileEncryptionCipher {
        
        guard let vector = crypto.createInitializationVector() else {
            throw CryptoError.generate("Error creating IV")
        }
        fileKey.iv = vector
        
        guard let cipher = crypto.initializeEncryptionCipher(fileKey.key, vector: vector) else {
            throw CryptoError.generate("Error creating encryption cipher")
        }
        
        return FileEncryptionCipher(crypto: self.crypto, cipher: cipher, fileKey: fileKey)
    }
    
    public func createDecryptionCipher(fileKey: PlainFileKey) throws -> FileDecryptionCipher {
        
        guard let iv = fileKey.iv else {
            throw CryptoError.generate("FileKey has no IV")
        }
        
        guard let tag = fileKey.tag else {
            throw CryptoError.generate("FileKey has no authentication tag")
        }
        
        guard let cipher = crypto.initializeDecryptionCipher(fileKey.key, tag: tag, vector: iv) else {
            throw CryptoError.generate("Error creating decryption cipher")
        }
        
        return FileDecryptionCipher(crypto: self.crypto, cipher: cipher, fileKey: fileKey)
    }
    
}
