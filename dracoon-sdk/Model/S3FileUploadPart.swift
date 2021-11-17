//
//  S3FileUploadPart.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

public struct S3FileUploadPart: Codable {
    
    public var partNumber: Int32
    public var partEtag: String
    
    public init(partNumber: Int32, partEtag: String) {
        self.partNumber = partNumber
        self.partEtag = partEtag
    }
    
}
