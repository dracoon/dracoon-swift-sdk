//
//  FileUtilsMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 29.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

@testable import dracoon_sdk

class FileUtilsMock: FileHelper {
    
    var returnedData: Data? = Data()
    
    func calculateFileSize(filePath: URL) -> Int64? {
        return 42 * 1024
    }
    
    func calculateMD5(_ data: Data) -> String {
        return "md5"
    }
    
    func readData(_ fileUrl: URL) throws -> Data? {
        return self.returnedData
    }
    
    func readData(_ fileUrl: URL?, range: NSRange) throws -> Data? {
        return self.returnedData
    }
    
    func moveItem(at sourceUrl: URL, to targetUrl: URL) throws {
        
    }
    
    func removeItem(_ fileUrl: URL) throws {
        
    }
    
    
}
