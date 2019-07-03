//
//  PresignedUrlList.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

struct PresignedUrlList: Codable {
    
    /** List of presigned URLs */
    public var urls: [PresignedUrl]
}
