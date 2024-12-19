//
//  FileUploadProperties.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 18.12.24.
//  Copyright © 2024 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

final class FileUploadProperties: @unchecked Sendable {
    
    private let queue = DispatchQueue(label: "com.dracoon.upload.properties")
    
    private var started = false
    private var cancelled = false
    private(set) var urlSessionTask: URLSessionTask?
    private(set) var uploadSessionConfig: URLSessionConfiguration?
    private(set) var encryptedFileKey: EncryptedFileKey?
    private(set) var callback: UploadCallback?
    private(set) var uploadUrl: String?
    
    func isUploadStarted() -> Bool {
        self.queue.sync {
            return self.started
        }
    }
    
    func setUploadStarted() {
        self.queue.sync {
            self.started = true
        }
    }
    
    func isUploadCancelled() -> Bool {
        self.queue.sync {
            return self.cancelled
        }
    }
    
    func setUploadCancelled() {
        self.queue.sync {
            self.cancelled = true
        }
    }
    
    func setSessionTask(_ task: URLSessionTask?) {
        self.urlSessionTask = task
    }
    
    func setSessionConfig(_ config: URLSessionConfiguration?) {
        self.uploadSessionConfig = config
    }
    
    func setFileKey(_ fileKey: EncryptedFileKey?) {
        self.encryptedFileKey = fileKey
    }
    
    func setCallback(_ callback: UploadCallback?) {
        self.callback = callback
    }
    
    func setUploadUrl(_ uploadUrl: String?) {
        self.uploadUrl = uploadUrl
    }
    
}
