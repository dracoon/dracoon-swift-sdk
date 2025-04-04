//
//  FileUtils.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 29.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import CommonCrypto

protocol FileHelper: Sendable {
    func calculateFileSize(filePath: URL) -> Int64?
    func readData(_ fileUrl: URL) throws -> Data?
    func readData(_ fileUrl: URL?, range: NSRange) throws -> Data?
    func moveItem(at sourceUrl: URL, to targetUrl: URL) throws
    func removeItem(_ path: URL) throws
}

class FileUtils {
    
    nonisolated(unsafe) static var fileHelper: FileHelper = DracoonFileHelper()
    
    static func calculateFileSize(filePath: URL) -> Int64? {
        return self.fileHelper.calculateFileSize(filePath: filePath)
    }
    
    static func readData(_ fileUrl: URL) throws -> Data? {
        return try self.fileHelper.readData(fileUrl)
    }
    
    static func readData(_ fileUrl: URL?, range: NSRange) throws -> Data? {
        return try self.fileHelper.readData(fileUrl, range: range)
    }
    
    static func moveItem(at sourceUrl: URL, to targetUrl: URL) throws {
        try self.fileHelper.moveItem(at: sourceUrl, to: targetUrl)
    }
    
    static func removeItem(_ fileUrl: URL) throws {
        try self.fileHelper.removeItem(fileUrl)
    }
}

final class DracoonFileHelper: FileHelper {
   
    func calculateFileSize(filePath: URL) -> Int64? {
        do {
            let fileAttribute: [FileAttributeKey : Any] = try FileManager.default.attributesOfItem(atPath: filePath.path)
            let fileSize = fileAttribute[FileAttributeKey.size] as? Int64
            return fileSize
        } catch {}
        return nil
    }
    
    func readData(_ fileUrl: URL) throws -> Data? {
        return try Data(contentsOf: fileUrl)
    }
    
    func readData(_ fileUrl: URL?, range: NSRange) throws -> Data? {
        guard let fileUrl = fileUrl, let fileHandle = try? FileHandle(forReadingFrom: fileUrl) else {
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
    
    func removeItem(_ fileUrl: URL) throws {
        try FileManager.default.removeItem(at: fileUrl)
    }
}
