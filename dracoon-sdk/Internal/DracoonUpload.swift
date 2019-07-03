//
//  DracoonUpload.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

protocol DracoonUpload {
    
    func start()
    func cancel()
    
}

extension DracoonUpload {
    func calculateFileSize(filePath: URL) -> Int64? {
        do {
            let fileAttribute: [FileAttributeKey : Any] = try FileManager.default.attributesOfItem(atPath: filePath.path)
            let fileSize = fileAttribute[FileAttributeKey.size] as? Int64
            return fileSize
        } catch {}
        return nil
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
}
