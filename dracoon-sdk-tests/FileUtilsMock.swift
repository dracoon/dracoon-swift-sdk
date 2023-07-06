//
//  FileUtilsMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 29.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
@testable import dracoon_sdk

class FileUtilsMock: FileHelper {
    
    var size: Int64 = 42 * 1024
    var returnsData = true
    
    func calculateFileSize(filePath: URL) -> Int64? {
        return size
    }
    
    func readData(_ fileUrl: URL) throws -> Data? {
        if returnsData {
            return Data(count: Int(size))
        }
        return nil
    }
    
    func readData(_ fileUrl: URL?, range: NSRange) throws -> Data? {
        if returnsData {
            return Data(count: Int(size))
        }
        return nil
    }
    
    func moveItem(at sourceUrl: URL, to targetUrl: URL) throws {
        
    }
    
    func removeItem(_ fileUrl: URL) throws {
        
    }
    
    
}
