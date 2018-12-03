//
//  FileDecryptionCipherTests.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import XCTest
@testable import crypto_sdk

class FileDecryptionCipherTests: XCTestCase {
    
    var crypto: Crypto?
    var testFileReader: TestFileReader?
    
    override func setUp() {
        super.setUp()
        crypto = Crypto()
        testFileReader = TestFileReader()
    }
    
    func testCreateDecryptionCipher_withoutIV_throwsError() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "data/plain_file_key.json")
        plainFileKey!.iv = nil
        let expectedError = CryptoError.generate("FileKey has no IV")
        
        XCTAssertThrowsError(try crypto!.createDecryptionCipher(fileKey: plainFileKey!)) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testCreateDecryptionCipher_withoutTag_throwsError() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "data/plain_file_key.json")
        plainFileKey!.tag = nil
        let expectedError = CryptoError.generate("FileKey has no authentication tag")
        
        XCTAssertThrowsError(try crypto!.createDecryptionCipher(fileKey: plainFileKey!)) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testCreateDecryptionCipher_decryptsFile() {
        let key = "9CnEFV3i92P3aDttUzvBWs71nUkGKDgcVpxw3TY64Aw="
        let iv = "pgq//CZzM0fGG0rM"
        let tag = "vVgfiUGv/7qJTGifVNDJfw=="
        let fileKey = PlainFileKey(key: key, version: CryptoConstants.DEFAULT_VERSION)
        fileKey.iv = iv
        fileKey.tag = tag
        
        guard let encryptedFile = testFileReader?.readFile(fileName: "files/encrypted") else {
            XCTFail()
            return
        }
        
        let cipher = try? crypto!.createDecryptionCipher(fileKey: fileKey)
        let decryptedData = try? cipher!.processBlock(fileData: encryptedFile)
        
        XCTAssertNoThrow(try cipher!.doFinal())
        XCTAssertNotNil(decryptedData)
        
    }
}

