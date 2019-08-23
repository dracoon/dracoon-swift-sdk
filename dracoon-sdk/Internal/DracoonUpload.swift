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
    func readData(_ path: URL?, range: NSRange) throws -> Data? {
        guard let path = path, let fileHandle = try? FileHandle(forReadingFrom: path) else {
            return nil
        }
        
        let offset = UInt64(range.location)
        let length = UInt64(range.length)
        let size = fileHandle.seekToEndOfFile()
        
        let maxLength = size - offset
        
        let secureLength = Int(min(length, maxLength))
        
        fileHandle.seek(toFileOffset: offset)
        let data = fileHandle.readData(ofLength: secureLength)
        
        return data
    }
}
