//
//  FileEncryptionCipherTests.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import XCTest
@testable import crypto_sdk

class FileEncryptionCipherTests: XCTestCase {
    
    var crypto: Crypto?
    var testFileReader: TestFileReader?
    
    override func setUp() {
        super.setUp()
        crypto = Crypto()
        testFileReader = TestFileReader()
    }
    
    func testEncryptionCipher_withTestData_encryptsData() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "data/plain_file_key.json")
        plainFileKey!.iv = nil
        plainFileKey!.tag = nil
        let plainTestData = testFileReader?.readFile(fileName: "files/encrypted")
        
        let cipher = try? crypto!.createEncryptionCipher(fileKey: plainFileKey!)
        let data = try? cipher!.processBlock(fileData: plainTestData!)
        
        XCTAssertNoThrow(try cipher!.doFinal())
        XCTAssertNotNil(data)
    }
    
    func testEncryptionCipher_withTestData_writesIVAndTag() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "data/plain_file_key.json")
        plainFileKey!.iv = nil
        plainFileKey!.tag = nil
        let plainTestData = testFileReader?.readFile(fileName: "files/encrypted")
        
        let cipher = try? crypto!.createEncryptionCipher(fileKey: plainFileKey!)
        
        XCTAssertNotNil(plainFileKey!.iv)
        
        _ = try? cipher!.processBlock(fileData: plainTestData!)
        try? cipher!.doFinal()
        
        XCTAssertNotNil(plainFileKey!.tag)
    }
    
    func testEncryptionCipher_canDecryptEncryptedData() {
        let plainText = "TestABCDEFGH 123\nTestIJKLMNOP 456\nTestQRSTUVWX 789"
        let data = plainText.data(using: .utf8)
        
        let anotherFileKey = try! crypto!.generateFileKey()
        let encryptionCipher = try! crypto!.createEncryptionCipher(fileKey: anotherFileKey)
        let encData = try! encryptionCipher.processBlock(fileData: data!)
        try! encryptionCipher.doFinal()
        
        let decryptionCipher = try! crypto!.createDecryptionCipher(fileKey: anotherFileKey)
        let pData = try! decryptionCipher.processBlock(fileData: encData)
        
        XCTAssertNoThrow(try decryptionCipher.doFinal())
        XCTAssertEqual(plainText, String(data: pData, encoding: .utf8))
    }
}
