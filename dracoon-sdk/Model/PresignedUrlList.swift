//
//  PresignedUrlList.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

public struct PresignedUrlList: Codable, Sendable {
    
    /** List of presigned URLs */
    public var urls: [PresignedUrl]
}
