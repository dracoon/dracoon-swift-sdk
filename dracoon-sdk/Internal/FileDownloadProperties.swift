//
//  FileDownloadProperties.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 18.12.24.
//  Copyright © 2024 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

final class FileDownloadProperties: @unchecked Sendable {
    
    private let queue = DispatchQueue(label: "com.dracoon.download.properties")
    
    private var started = false
    private(set) var urlSessionTask: URLSessionTask?
    private(set) var downloadSessionConfig: URLSessionConfiguration?
    private(set) var callback: DownloadCallback?
    private(set) var fileKey: EncryptedFileKey?
    private(set) var fileSize: Int64?
    
    func isDownloadStarted() -> Bool {
        self.queue.sync {
            return self.started
        }
    }
    
    func setDownloadStarted() {
        self.queue.sync {
            self.started = true
        }
    }
    
    func setSessionTask(_ task: URLSessionTask?) {
        self.urlSessionTask = task
    }
    
    func setSessionConfig(_ config: URLSessionConfiguration?) {
        self.downloadSessionConfig = config
    }
    
    func setCallback(_ callback: DownloadCallback?) {
        self.callback = callback
    }
    
    func setFileKey(_ fileKey: EncryptedFileKey?) {
        self.fileKey = fileKey
    }
    
    func setFileSize(_ fileSize: Int64?) {
        self.fileSize = fileSize
    }
    
    
}
