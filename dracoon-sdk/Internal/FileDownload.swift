//
//  FileDownload.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

public final class FileDownload: NSObject, URLSessionDelegate, URLSessionDownloadDelegate, Sendable {
    
    let session: Session
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthInterceptor
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    let account: DracoonAccount
    let nodes: DracoonNodes
    let crypto: CryptoProtocol
    let getEncryptionPassword: @Sendable () -> String?
    
    let nodeId: Int64
    let targetUrl: URL
    
    private let properties = FileDownloadProperties()
    
    init(nodeId: Int64, targetUrl: URL, config: DracoonRequestConfig, account: DracoonAccount, nodes: DracoonNodes, crypto: CryptoProtocol, fileKey: EncryptedFileKey?, sessionConfig: URLSessionConfiguration?, getEncryptionPassword: @Sendable @escaping () -> String?, callback: DownloadCallback?) {
        self.session = config.session
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.oAuthTokenManager = config.oauthTokenManager
        self.encoder = config.encoder
        self.decoder = config.decoder
        self.account = account
        self.nodes = nodes
        self.crypto = crypto
        self.getEncryptionPassword = getEncryptionPassword
        
        self.nodeId = nodeId
        self.targetUrl = targetUrl
        
        self.properties.setSessionConfig(sessionConfig)
        self.properties.setFileKey(fileKey)
        self.properties.setCallback(callback)
    }
    
    public func start() {
        guard !self.properties.isDownloadStarted() else {
            return
        }
        self.properties.setDownloadStarted()
        self.requestDownload()
    }
    
    public func cancel() {
        guard self.properties.isDownloadStarted(),
              let downloadTask = self.properties.urlSessionTask,
        !self.properties.isDownloadCancelled() else {
            return
        }
        self.properties.setDownloadCancelled()
        downloadTask.cancel()
        self.properties.callback?.onCanceled?()
    }
    
    func resumeFromBackground() {
        self.properties.urlSessionTask?.resume()
    }
    
    private func getDownloadURL(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<DownloadTokenGenerateResponse>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/" + String(nodeId) + "/downloads"
        
        var urlRequest = URLRequest(url: URL(string: requestUrl)!)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        
        self.session.request(urlRequest)
            .validate()
            .decode(DownloadTokenGenerateResponse.self, decoder: self.decoder, completion: completion)
        
    }
    
    private func requestDownload() {
        self.getDownloadURL(nodeId: self.nodeId, completion: { result in
            switch result {
            case .value(let response):
                self.download(url: response.downloadUrl)
            case .error(let error):
                self.callOnError(error)
            }
        })
    }
    
    private func download(url: String) {
        let sessionConfiguration: URLSessionConfiguration
        if let sessionConfig = self.properties.downloadSessionConfig {
            sessionConfiguration = sessionConfig
        } else {
            sessionConfiguration = self.session.sessionConfiguration
        }
        
        let urlSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        let request = URLRequest(url: URL(string: url)!)
        let task = urlSession.downloadTask(with: request)
        self.nodes.getNode(nodeId: self.nodeId, completion: { result in
            switch result {
            case .error(let error):
                self.callOnError(error)
            case .value(let node):
                task.countOfBytesClientExpectsToReceive = node.size ?? 0
                self.properties.setSessionTask(task)
                task.resume()
            }
        })
    }
    
    private func handleProgress(_ progress: Progress) {
        if progress.totalUnitCount == -1 {
            if let fileSize = self.properties.fileSize {
                self.notifyProgress(completed: progress.completedUnitCount, total: fileSize)
            } else {
                self.properties.setFileSize(-1)
                self.retrieveFileSize()
            }
        } else {
            self.properties.callback?.onProgress?(Float(progress.fractionCompleted))
        }
    }
    
    private func retrieveFileSize() {
        self.nodes.getNode(nodeId: self.nodeId, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let node):
                self.properties.setFileSize(node.size)
            }
        })
    }
    
    private func notifyProgress(completed: Int64, total: Int64) {
        guard total > 0 else {
            return
        }
        let progress = Float(completed)/Float(total)
        self.properties.callback?.onProgress?(progress)
    }
    
    private func decryptDownloadedFile(fileKey: EncryptedFileKey, completion: (@Sendable (DracoonError?) -> Void)? = nil) {
        guard let encryptionPassword = self.getEncryptionPassword() else {
            self.callOnError(DracoonError.no_encryption_password)
            return
        }
        self.account.checkUserKeyPairPassword(version: fileKey.getUserKeyPairVersion() , password: encryptionPassword, completion: { result in
            switch result {
            case .error(let error):
                self.callOnError(error)
                completion?(error)
            case .value(let userKeyPair):
                do {
                    let privateKey = UserPrivateKey(privateKey: userKeyPair.privateKeyContainer.privateKey, version: userKeyPair.privateKeyContainer.version)
                    let plainFileKey = try self.crypto.decryptFileKey(fileKey: fileKey, privateKey: privateKey, password: encryptionPassword)
                    try self.decryptFile(fileKey: plainFileKey, fileUrl: self.targetUrl)
                    self.properties.callback?.onComplete?(self.targetUrl)
                    completion?(nil)
                } catch {
                    self.callOnError(error)
                    completion?(DracoonError.generic(error: error))
                }
            }
        })
    }
    
    private func decryptFile(fileKey: PlainFileKey, fileUrl: URL) throws {
        guard ValidatorUtils.pathExists(at: fileUrl.path) else {
            throw DracoonError.file_does_not_exist(at: fileUrl)
        }
        guard let inputStream = InputStream(fileAtPath: fileUrl.path) else {
            throw DracoonError.read_data_failure(at: fileUrl)
        }
        let decryptionCipher = try self.crypto.createDecryptionCipher(fileKey: fileKey)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: DracoonConstants.DECRYPTION_BUFFER_SIZE)
        inputStream.open()
        
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFilePath = tempPath.appendingPathComponent(UUID().uuidString)
        guard let outputStream = OutputStream(toFileAtPath: tempFilePath.path, append: false) else {
            self.callOnError(DracoonError.file_decryption_error(nodeId: self.nodeId))
            return
        }
        outputStream.open()
        
        defer {
            buffer.deallocate()
            inputStream.close()
            outputStream.close()
        }
        
        while inputStream.hasBytesAvailable {
            try autoreleasepool {
                let read = inputStream.read(buffer, maxLength: DracoonConstants.DECRYPTION_BUFFER_SIZE)
                if read > 0 {
                    var encData = Data()
                    encData.append(buffer, count: read)
                    let plainData = try decryptionCipher.processBlock(fileData: encData)
                    
                    _ = outputStream.write(data: plainData)
                } else if let error = inputStream.streamError {
                    throw error
                }
            }
        }
        
        try decryptionCipher.doFinal()
        
        try FileUtils.removeItem(fileUrl)
        try FileUtils.moveItem(at: tempFilePath, to: fileUrl)
    }
    
    // MARK: URLSessionDelegate
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        self.handleDownloadError(task: task, error: error)
        if session.configuration.identifier != nil {
            session.finishTasksAndInvalidate()
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.handleDownloadFinished(downloadTask: downloadTask, location: location)
        if session.configuration.identifier != nil {
            session.finishTasksAndInvalidate()
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else {
            return
        }
        let fractionCompleted = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        self.properties.callback?.onProgress?(fractionCompleted)
    }
    
    private func handleDownloadError(task: URLSessionTask, error: Error?) {
        guard let error = error else {
            return
        }
        guard let downloadTask = task as? URLSessionDownloadTask else {
            self.callOnError(error)
            return
        }
        guard let httpResponse = downloadTask.response as? HTTPURLResponse else {
            self.callOnError(error)
            return
        }
        let nsError = error as NSError
        if nsError.code == NSURLErrorCancelled {
            let reason = (nsError.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? NSNumber) ?? -1
            let userInfo = nsError.userInfo.mapValues({$0 as? String ?? nil})
            let dracoonError: DracoonError = DracoonError.background_download_cancelled(reason: reason.intValue, userInfo: userInfo)
            self.callOnError(dracoonError)
            return
        }
        let statusCode = httpResponse.statusCode
        switch statusCode {
        case DracoonErrorParser.HTTPStatusCode.FORBIDDEN:
            if httpResponse.allHeaderFields["X-Forbidden"] as? String == "403" {
                self.callOnError(DracoonError.api(error: DracoonSDKErrorModel(errorCode: DracoonApiCode.SERVER_MALICIOUS_FILE_DETECTED, httpStatusCode: statusCode)))
                return
            }
            fallthrough
        default:
            let errorResponse = ModelErrorResponse(code: statusCode, message: nil, debugInfo: nil, errorCode: nil)
            let errorCode = DracoonErrorParser.shared.parseApiErrorResponse(errorResponse, requestType: .other)
            self.callOnError(DracoonError.api(error: DracoonSDKErrorModel(errorCode: errorCode, httpStatusCode: statusCode)))
        }
    }
    
    private func handleDownloadFinished(downloadTask: URLSessionDownloadTask, location: URL) {
        self.copyDownloadedFile(from: location, to: self.targetUrl)
        self.handleDownloadFinished()
    }
    
    private func handleDownloadFinished() {
        if let fileKey = self.properties.fileKey {
            self.decryptDownloadedFile(fileKey: fileKey)
        } else {
            self.properties.callback?.onComplete?(self.targetUrl)
        }
    }
    
    private func copyDownloadedFile(from location: URL, to target: URL) {
        let fileManager = FileManager.default
        let directoryURL = target.deletingLastPathComponent()
        do {
            if !fileManager.fileExists(atPath: directoryURL.path) {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            }
            if fileManager.fileExists(atPath: target.path) {
                try fileManager.removeItem(at: target)
            }
        } catch {
            self.callOnError(error)
        }
        let fileCoordinator = NSFileCoordinator()
        var readingError: NSError?
        fileCoordinator.coordinate(readingItemAt: location, options: .forUploading, error: &readingError, byAccessor: { newURL in
            do {
                try FileManager.default.copyItem(at: newURL, to: target)
            }  catch {
                self.callOnError(error)
            }
        })
        if let error = readingError {
            self.callOnError(error)
        }
    }
    
    private func callOnError(_ error: Error) {
        self.properties.callback?.onError?(error)
    }
}
