//
//  DracoonTransferStorage.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 16.12.24.
//  Copyright © 2024 Dracoon. All rights reserved.
//

final class DracoonTransferStorage: @unchecked Sendable {
    
    private var uploads = [String : DracoonUpload]()
    private var downloads = [Int64 : FileDownload]()
    
    private let serialUploadQueue = DispatchQueue(label: "com.dracoon.transfer.uploadStorage")
    private let serialDownloadQueue = DispatchQueue(label: "com.dracoon.transfer.downloadStorage")
    
    func storeUpload(uploadId: String, upload: DracoonUpload) {
        self.serialUploadQueue.async {
            self.uploads[uploadId] = upload
        }
    }
    
    func removeUpload(uploadId: String) {
        self.serialUploadQueue.async {
            self.uploads.removeValue(forKey: uploadId)
        }
    }
    
    func getUpload(uploadId: String, completionHandler: @Sendable @escaping (DracoonUpload?) -> Void) {
        self.serialUploadQueue.async {
            completionHandler(self.uploads[uploadId])
        }
    }
    
    func resumeUploads() {
        for upload in self.uploads.values {
            if let fileUpload = upload as? FileUpload {
                fileUpload.resumeBackgroundUpload()
            }
        }
    }
    
    func storeDownload(nodeId: Int64, download: FileDownload) {
        self.serialDownloadQueue.async {
            self.downloads[nodeId] = download
        }
    }
    
    func removeDownload(nodeId: Int64) {
        self.serialDownloadQueue.async {
            self.downloads.removeValue(forKey: nodeId)
        }
    }
    
    func getDownload(nodeId: Int64, completionHandler: @Sendable @escaping (FileDownload?) -> Void) {
        self.serialDownloadQueue.async {
            completionHandler(self.downloads[nodeId])
        }
    }
    
    func resumeDownloads() {
        for download in self.downloads.values {
            download.resumeFromBackground()
        }
    }
}

