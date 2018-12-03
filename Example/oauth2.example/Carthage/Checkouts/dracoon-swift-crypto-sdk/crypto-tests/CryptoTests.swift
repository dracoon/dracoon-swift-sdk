//
//  CryptoTests.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import XCTest
@testable import crypto_sdk

class CryptoTests: XCTestCase {
    
    var crypto: Crypto?
    var testFileReader: TestFileReader?
    
    override func setUp() {
        super.setUp()
        crypto = Crypto()
        testFileReader = TestFileReader()
    }
    
    // MARK: Generate UserKeyPair
    
    func testGenerateUserKeyPair_withPassword_returnsKeyPairContainers() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        
        XCTAssertNotNil(userKeyPair.publicKeyContainer)
        XCTAssertNotNil(userKeyPair.privateKeyContainer)
        XCTAssert(userKeyPair.publicKeyContainer.publicKey.starts(with: "-----BEGIN PUBLIC KEY-----"))
        XCTAssert(userKeyPair.privateKeyContainer.privateKey.starts(with: "-----BEGIN ENCRYPTED PRIVATE KEY-----"))
    }
    
    func testGenerateUserKeyPair_withSpecialCharacterPassword_returnsKeyPairContainers() {
        let password = "~ABC123§DEF%F456!"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        
        XCTAssertNotNil(userKeyPair.publicKeyContainer)
        XCTAssertNotNil(userKeyPair.privateKeyContainer)
        XCTAssert(userKeyPair.publicKeyContainer.publicKey.starts(with: "-----BEGIN PUBLIC KEY-----"))
        XCTAssert(userKeyPair.privateKeyContainer.privateKey.starts(with: "-----BEGIN ENCRYPTED PRIVATE KEY-----"))
    }
    
    func testGenerateUserKeyPair_withoutVersion_usesDefaultVersion() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        
        XCTAssertEqual(userKeyPair.publicKeyContainer.version, CryptoConstants.DEFAULT_VERSION)
        XCTAssertEqual(userKeyPair.privateKeyContainer.version, CryptoConstants.DEFAULT_VERSION)
    }
    
    func testGenerateUserKeyPair_withEmptyPassword_throwsError() {
        let expectedError = CryptoError.generate("Password can't be empty")
        
        XCTAssertThrowsError(try crypto!.generateUserKeyPair(password: "")) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testGenerateUserKeyPair_withUnknownVersion_throwsError() {
        let password = "ABC123DEFF456"
        let expectedError = CryptoError.generate("Unknown key pair version")
        
        XCTAssertThrowsError(try crypto!.generateUserKeyPair(password: password, version: "Z")) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    // MARK: Check PrivateKey
    
    func testCheckUserKeyPair_withCorrectInput_returnsTrue() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        
        XCTAssertTrue(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: password))
    }
    
    func testCheckUserKeyPair_withUnknownVersion_returnsFalse() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        userKeyPair.privateKeyContainer.version = "Z"
        
        XCTAssertFalse(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: password))
    }
    
    func testCheckUserKeyPair_withInvalidPrivateKey_returnsFalse() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        userKeyPair.privateKeyContainer = UserPrivateKey(privateKey: "ABCDEFABCDEF", version: CryptoConstants.DEFAULT_VERSION)
        
        XCTAssertFalse(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: password))
    }
    
    func testCheckUserKeyPair_withInvalidPassword_returnsFalse() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        
        XCTAssertFalse(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: "0123456789"))
    }
    
    // MARK: FileKey decryption and encryption
    
    func testDecryptFileKey_withWrongPassword_throwsError() {
        let password = "wrongPassword"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "data/enc_file_key.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "data/private_key.json")
        let expectedError = CryptoError.decrypt("Error decrypting FileKey")
        
        XCTAssertThrowsError(try crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testDecryptFileKey_withCorrectPassword_returnsPlainFileKey() {
        let password = "Pass1234!"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "data/enc_file_key.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "data/private_key.json")
        
        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(plainFileKey)
        XCTAssertEqual(plainFileKey!.iv, encryptedFileKey!.iv)
        XCTAssertEqual(plainFileKey!.tag, encryptedFileKey!.tag)
        XCTAssertEqual(plainFileKey!.version, encryptedFileKey!.version)
    }
    
    func testEncryptFileKey_withMissingIV_throwsError() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "data/plain_file_key.json")
        plainFileKey?.iv = nil
        let userPublicKey = testFileReader?.readPublicKey(fileName: "data/public_key.json")
        let expectedError = CryptoError.encrypt("Incomplete FileKey")
        
        XCTAssertThrowsError(try crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testEncryptFileKey_withMissingTag_throwsError() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "data/plain_file_key.json")
        plainFileKey?.tag = nil
        let userPublicKey = testFileReader?.readPublicKey(fileName: "data/public_key.json")
        let expectedError = CryptoError.encrypt("Incomplete FileKey")
        
        XCTAssertThrowsError(try crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testEncryptFileKey_canDecryptEncryptedKey() {
        let password = "Pass1234!"
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "data/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "data/public_key.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "data/private_key.json")
        
        let encryptedKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        let decryptedKey = try? crypto!.decryptFileKey(fileKey: encryptedKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(decryptedKey)
        XCTAssertEqual(decryptedKey!.key, plainFileKey!.key)
    }
    
    // MARK: Generate FileKey
    
    func testGenerateFileKey_withUnknownVersion_throwsError() {
        let expectedError = CryptoError.generate("Unknown key pair version")
        
        XCTAssertThrowsError(try crypto!.generateFileKey(version: "Z")) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testGenerateFileKey_returnsPlainFileKey() {
        let base64EncodedAES256KeyCharacterCount = 44
        
        let plainFileKey = try? crypto!.generateFileKey()
        
        XCTAssertNotNil(plainFileKey)
        XCTAssertNotNil(plainFileKey!.key)
        XCTAssert(plainFileKey!.key.count == base64EncodedAES256KeyCharacterCount)
        XCTAssertEqual(plainFileKey!.version, CryptoConstants.DEFAULT_VERSION)
        XCTAssertNil(plainFileKey!.iv)
        XCTAssertNil(plainFileKey!.tag)
    }
}
