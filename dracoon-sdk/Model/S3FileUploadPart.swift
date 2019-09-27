//
//  S3FileUploadPart.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

struct S3FileUploadPart: Codable {
    
    public var partNumber: Int32
    public var partEtag: String
    
}
