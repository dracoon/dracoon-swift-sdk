//
//  S3FileUploadStatus.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

public struct S3FileUploadStatus: Codable {
    
    public enum S3UploadStatus: String, Codable {
        case transfer = "transfer"
        case finishing = "finishing"
        case done = "done"
        case error = "error"
    }
    
    public var status: String
    public var node: Node?
    public var errorDetails: ModelErrorResponse?
}
