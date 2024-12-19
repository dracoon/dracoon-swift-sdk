//
//  FileUpload.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk
import CommonCrypto

public final class FileUpload: NSObject, DracoonUpload, URLSessionDataDelegate, Sendable {
    
    let session: Alamofire.Session
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthInterceptor
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    let account: DracoonAccount
    let resolutionStrategy: CompleteUploadRequest.ResolutionStrategy
    let request: CreateFileUploadRequest
    let fileUrl: URL
    let fileSize: Int64
    let crypto: CryptoProtocol?
    
    private let properties = FileUploadProperties()
    
    init(config: DracoonRequestConfig, request: CreateFileUploadRequest, fileUrl: URL, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy, crypto: CryptoProtocol?,
         sessionConfig: URLSessionConfiguration?, account: DracoonAccount, callback: UploadCallback?) {
        self.request = request
        self.session = config.session
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.oAuthTokenManager = config.oauthTokenManager
        self.decoder = config.decoder
        self.encoder = config.encoder
        self.crypto = crypto
        self.account = account
        self.fileUrl = fileUrl
        self.resolutionStrategy = resolutionStrategy
        self.fileSize = FileUtils.calculateFileSize(filePath: self.fileUrl) ?? 0
        
        self.properties.setSessionConfig(sessionConfig)
        self.properties.setCallback(callback)
    }
    
    public func start() {
        guard !self.properties.isUploadStarted() else {
            return
        }
        self.properties.setUploadStarted()
        self.createFileUpload(request: request, completion: { result in
            switch result {
            case .value(let response):
                self.properties.setUploadUrl(response.uploadUrl)
                if self.crypto == nil {
                    self.startChunkedUpload(uploadUrl: response.uploadUrl, fileURL: self.fileUrl)
                } else {
                    self.startEncryptedChunkedUpload(uploadUrl: response.uploadUrl)
                }
            case .error(let error):
                self.callOnError(error)
            }
        })
    }
    
    public func cancel() {
        guard self.properties.isUploadStarted(),
              let sessionTask = self.properties.urlSessionTask,
              !self.properties.isUploadCancelled() else {
            return
        }
        self.properties.setUploadCancelled()
        sessionTask.cancel()
        if let uploadUrl = self.properties.uploadUrl {
            self.deleteUpload(uploadUrl: uploadUrl, completion: { _ in
                self.properties.callback?.onCanceled?()
            })
        } else {
            self.properties.callback?.onCanceled?()
        }
    }
    
    func resumeBackgroundUpload() {
        self.properties.urlSessionTask?.resume()
    }
    
    private func createFileUpload(request: CreateFileUploadRequest, completion: @escaping DataRequest.DecodeCompletion<CreateFileUploadResponse>) {
        do {
            var createRequest = request
            if self.fileSize > 0 {
                createRequest.size = self.fileSize
            }
            let jsonBody = try encoder.encode(createRequest)
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(CreateFileUploadResponse.self, decoder: self.decoder, requestType: .createUpload, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    private func startChunkedUpload(uploadUrl: String, fileURL: URL, encryptedFileKey: EncryptedFileKey? = nil) {
        let sessionConfiguration: URLSessionConfiguration
        if let sessionConfig = self.properties.uploadSessionConfig {
            sessionConfiguration = sessionConfig
        } else {
            sessionConfiguration = self.session.sessionConfiguration
        }
        let urlSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        var urlRequest = URLRequest(url: URL(string: uploadUrl)!)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.addValue("application/octet-stream", forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
        let task = urlSession.uploadTask(with: urlRequest, fromFile: fileURL)
        if self.fileSize > 0 {
            task.countOfBytesClientExpectsToSend = self.fileSize
        }
        self.properties.setSessionTask(task)
        task.resume()
    }
    
    private func startEncryptedChunkedUpload(uploadUrl: String) {
        guard let crypto = self.crypto else {
            self.callOnError(DracoonError.encryption_cipher_failure)
            return
        }
        do {
            let result = try self.encryptFile(crypto: crypto, fileURL: self.fileUrl)
            self.encryptFileKey(cipher: result.cipher, completion: { response in
                switch response {
                case .error(let error):
                    self.callOnError(error)
                case .value(let fileKey):
                    self.properties.setFileKey(fileKey)
                    self.startChunkedUpload(uploadUrl: uploadUrl, fileURL: result.url, encryptedFileKey: fileKey)
                }
            })
        } catch {
            self.callOnError(error)
        }
    }
    
    private func encryptFileKey(cipher: EncryptionCipher, completion: @Sendable @escaping (Dracoon.Result<EncryptedFileKey>) -> Void) {
        guard let crypto = self.crypto else {
            return
        }
        self.account.getUserKeyPair(completion: { result in
            switch result {
            case .error(let error):
                completion(Dracoon.Result.error(error))
                return
            case .value(let userKeyPair):
                do {
                    let publicKey = UserPublicKey(publicKey: userKeyPair.publicKeyContainer.publicKey, version: userKeyPair.publicKeyContainer.version)
                    let encryptedFileKey = try crypto.encryptFileKey(fileKey: cipher.fileKey, publicKey: publicKey)
                    completion(Dracoon.Result.value(encryptedFileKey))
                } catch CryptoError.encrypt(let message){
                    completion(Dracoon.Result.error(DracoonError.filekey_encryption_failure(description: message)))
                } catch {
                    completion(Dracoon.Result.error(DracoonError.generic(error: error)))
                }
            }
        })
    }
    
    private func completeUpload(uploadUrl: String, encryptedFileKey: EncryptedFileKey?) {
        var completeRequest = CompleteUploadRequest()
        completeRequest.fileName = self.request.name
        completeRequest.resolutionStrategy = self.resolutionStrategy
        completeRequest.fileKey = encryptedFileKey
        
        self.sendCompleteRequest(uploadUrl: uploadUrl, request: completeRequest, session: self.session, completion: { result in
            switch result {
            case .value(let node):
                self.properties.callback?.onComplete?(node)
            case .error(let error):
                self.callOnError(error)
            }
        })
    }
    
    private func sendCompleteRequest(uploadUrl: String, request: CompleteUploadRequest, session: Session, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        do {
            let jsonBody = try encoder.encode(request)
            var urlRequest = URLRequest(url: URL(string: uploadUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            session.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    private func deleteUpload(uploadUrl: String, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        self.session.request(uploadUrl, method: .delete, parameters: Parameters())
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
    
    private func callOnError(_ error: Error) {
        self.properties.callback?.onError?(error)
    }
    
    // MARK: URLSessionDataDelegate
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.handleUploadCompletion(session, task: task, didCompleteWithError: error)
    }
    
    private func handleUploadCompletion(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            self.callOnError(DracoonError.generic(error: error))
        } else if let response = task.response as? HTTPURLResponse, response.statusCode >= 400 {
            self.callOnError(DracoonError.upload_failed(statusCode: response.statusCode))
        } else {
            self.completeUpload(uploadUrl: self.properties.uploadUrl!, encryptedFileKey: self.properties.encryptedFileKey)
        }
        if session.configuration.identifier != nil {
            session.finishTasksAndInvalidate()
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        self.handleUploadProgress(totalBytesSent: totalBytesSent)
    }
    
    private func handleUploadProgress(totalBytesSent: Int64) {
        guard self.fileSize > 0 else {
            return
        }
        let fractionCompleted = Float(totalBytesSent)/Float(self.fileSize)
        self.properties.callback?.onProgress?(fractionCompleted)
    }
}
