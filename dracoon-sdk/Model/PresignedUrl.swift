//
//  PresignedUrl.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

public struct PresignedUrl: Codable {
    
    /** S3 presigned URL */
    public var url: String
    /** Corresponding part number */
    public var partNumber: Int32
    
}
