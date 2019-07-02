//
//  GeneratePresignedUrlsRequest.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

struct GeneratePresignedUrlsRequest {
    
    /** Content-Length header size for each presigned URL (in bytes)
     MUST be >= 5 MB except the last part. */
    public var size: Int64
    /** First part number of a range of requested presigned URLs (for S3 it is: 1) */
    public var firstPartNumber: Int32
    /** Last part number of a range of requested presigned URLs */
    public var lastPartNumber: Int32
}
