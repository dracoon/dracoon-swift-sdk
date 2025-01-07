//
//  DracoonUpload.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import crypto_sdk

protocol DracoonUpload: Sendable {
    
    func start()
    func cancel()
    func resumeBackgroundUpload()
    
}

extension DracoonUpload {
    func encryptFile(crypto: CryptoProtocol, fileURL: URL) throws -> (url: URL, cipher: EncryptionCipher) {
        var cipher: EncryptionCipher
        do {
            let fileKey = try crypto.generateFileKey(version: PlainFileKeyVersion.AES256GCM)
            cipher = try crypto.createEncryptionCipher(fileKey: fileKey)
        } catch {
            throw DracoonError.encryption_cipher_failure
        }
        guard let inputStream = InputStream(url: fileURL) else {
            throw DracoonError.read_data_failure(at: fileURL)
        }
        let bufferSize = DracoonConstants.ENCRYPTION_BUFFER_SIZE
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        
        let outputUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(fileURL.lastPathComponent)
        FileManager.default.createFile(atPath: outputUrl.path, contents: nil, attributes: nil)
        guard let outputStream = OutputStream(toFileAtPath: outputUrl.path, append: true) else {
            throw DracoonError.write_data_failure(at: outputUrl)
        }
        inputStream.open()
        outputStream.open()
        defer {
            inputStream.close()
            outputStream.close()
            buffer.deallocate()
        }
        while inputStream.hasBytesAvailable {
            let read = inputStream.read(buffer, maxLength: bufferSize)
            if read > 0 {
                let plainData = Data(bytes: buffer, count: read)
                let encryptedData = try cipher.processBlock(fileData: plainData)
                _ = outputStream.write(data: encryptedData)
            } else if let error = inputStream.streamError {
                throw error
            }
            
        }
        try cipher.doFinal()
        
        return (outputUrl, cipher)
    }
}
