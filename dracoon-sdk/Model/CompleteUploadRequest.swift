//
// CompleteUploadRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import crypto_sdk

/// - Tag: CompleteUploadRequest
public struct CompleteUploadRequest: Codable {

    /// - Tag: CompleteUploadRequest.ResolutionStrategy
    public enum ResolutionStrategy: String, Codable { 
        case autorename = "autorename"
        case overwrite = "overwrite"
        case fail = "fail"
    }
    
    public init() {
        // Public initializer
    }
    
    /** Node conflict resolution strategy: * &#x60;autorename&#x60; * &#x60;overwrite&#x60; * &#x60;fail&#x60;  (default: &#x60;autorename&#x60;) */
    public var resolutionStrategy: ResolutionStrategy?
    /** Preserve Download Share Links and point them to the new node. (default: false) */
    public var keepShareLinks: Bool?
    /** New file name to store with */
    public var fileName: String?
    /** Encrypted file key for shares out of encrypted rooms */
    public var fileKey: EncryptedFileKey?
    /** List of user file keys */
    public var userFileKeyList: UserFileKeyList?



}

