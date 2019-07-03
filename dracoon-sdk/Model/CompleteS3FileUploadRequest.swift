//
//  CompleteS3FileUploadRequest.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import crypto_sdk

struct CompleteS3FileUploadRequest: Codable {
    
    /** List of S3 file upload parts */
    public var parts: [S3FileUploadPart]
    
    /** Node conflict resolution strategy: * &#x60;autorename&#x60; * &#x60;overwrite&#x60; * &#x60;fail&#x60;  (default: &#x60;autorename&#x60;) */
    public var resolutionStrategy: CompleteUploadRequest.ResolutionStrategy?
    /** Preserve Download Share Links and point them to the new node. (default: false) */
    public var keepShareLinks: Bool?
    /** New file name to store with */
    public var fileName: String?
    /** Encrypted file key for shares out of encrypted rooms */
    public var fileKey: EncryptedFileKey?
    /** List of user file keys */
    //public var userFileKeyList: UserFileKeyList?
}
