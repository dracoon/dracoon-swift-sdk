//
//  S3FileUploadStatus.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

struct S3FileUploadStatus: Codable {
    
    public enum S3UploadStatus: String, Codable {
        case transfer = "transfer"
        case finishing = "finishing"
        case done = "done"
        case error = "error"
    }
    
    public var status: String
    public var fileName: String
    public var parentId: Int64
    public var size: Int64?
}
