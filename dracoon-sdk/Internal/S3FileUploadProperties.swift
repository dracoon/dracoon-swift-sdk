//
//  S3FileUploadProperties.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 18.12.24.
//  Copyright © 2024 Dracoon. All rights reserved.
//

import Foundation
import crypto_sdk

final class S3FileUploadProperties: @unchecked Sendable {
    
    private(set) var s3Urls = [PresignedUrl]()
    /*
     Chunk size from Constants or 5 MB
     5MB is least S3 chunk size
     5GB is maximum S3 chunk size
     */
    private(set) var eTags = [S3FileUploadPart]()
    private(set) var uploadId: String?
    private(set) var cipher: EncryptionCipher?
    
    func addS3URLs(_ s3Urls: [PresignedUrl]) {
        self.s3Urls.append(contentsOf: s3Urls)
    }
    
    func addETags(_ eTags: [S3FileUploadPart]) {
        self.eTags.append(contentsOf: eTags)
    }
    
    func setUploadId(_ uploadId: String) {
        self.uploadId = uploadId
    }
    
    func setCipher(_ cipher: EncryptionCipher) {
        self.cipher = cipher
    }
}
