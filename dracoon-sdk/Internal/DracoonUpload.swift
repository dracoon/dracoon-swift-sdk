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
}
