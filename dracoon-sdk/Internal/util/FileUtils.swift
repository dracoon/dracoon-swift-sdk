//
//  FileUtils.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 29.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import CommonCrypto

protocol FileHelper {
    func calculateFileSize(filePath: URL) -> Int64?
    func calculateMD5(_ data: Data) -> String
    func readData(_ path: URL?, range: NSRange) throws -> Data?
    func moveItem(at sourceUrl: URL, to targetUrl: URL) throws
    func removeItem(_ path: URL) throws
}

class FileUtils {
    
    private static var fileHelper: FileHelper = DracoonFileHelper()
    
    static func calculateFileSize(filePath: URL) -> Int64? {
        return self.fileHelper.calculateFileSize(filePath: filePath)
    }
    
    static func calculateMD5(_ data: Data) -> String {
        return self.fileHelper.calculateMD5(data)
    }
    
    static func readData(_ path: URL?, range: NSRange) throws -> Data? {
        return try self.readData(path, range: range)
    }
    
    static func moveItem(at sourceUrl: URL, to targetUrl: URL) throws {
        try self.fileHelper.moveItem(at: sourceUrl, to: targetUrl)
    }
    
    static func removeItem(_ path: URL) throws {
        try self.fileHelper.removeItem(path)
    }
}

class DracoonFileHelper: FileHelper {
   
    func calculateFileSize(filePath: URL) -> Int64? {
        do {
            let fileAttribute: [FileAttributeKey : Any] = try FileManager.default.attributesOfItem(atPath: filePath.path)
            let fileSize = fileAttribute[FileAttributeKey.size] as? Int64
            return fileSize
        } catch {}
        return nil
    }
    
    func calculateMD5(_ data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ =  data.withUnsafeBytes( { (rawBufferPointer: UnsafeRawBufferPointer) in
            let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
            guard let pointer = bufferPointer.baseAddress else {
                return
            }
            CC_MD5(pointer, CC_LONG(data.count), &digest)
        })
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
    
    func readData(_ path: URL?, range: NSRange) throws -> Data? {
        guard let path = path, let fileHandle = try? FileHandle(forReadingFrom: path) else {
            return nil
        }
        
        let offset = UInt64(range.location)
        let length = UInt64(range.length)
        let size = fileHandle.seekToEndOfFile()
        
        let maxLength = size - offset
        
        guard maxLength > 0 else {
            return nil
        }
        
        let secureLength = Int(min(length, maxLength))
        
        fileHandle.seek(toFileOffset: offset)
        let data = fileHandle.readData(ofLength: secureLength)
        
        return data
    }
    
    func moveItem(at sourceUrl: URL, to targetUrl: URL) throws {
        try FileManager.default.moveItem(at: sourceUrl, to: targetUrl)
    }
    
    func removeItem(_ path: URL) throws {
        try FileManager.default.removeItem(at: path)
    }
}
