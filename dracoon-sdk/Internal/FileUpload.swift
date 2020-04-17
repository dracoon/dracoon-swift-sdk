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

public class FileUpload: DracoonUpload {
    
    let sessionManager: Alamofire.SessionManager
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthInterceptor
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    let account: DracoonAccount
    var request: CreateFileUploadRequest
    let resolutionStrategy: CompleteUploadRequest.ResolutionStrategy
    let fileUrl: URL
    
    var urlSessionTask: URLSessionTask?
    var callback: UploadCallback?
    let crypto: CryptoProtocol?
    var isCanceled = false
    var uploadUrl: String?
    
    init(config: DracoonRequestConfig, request: CreateFileUploadRequest, fileUrl: URL, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy, crypto: CryptoProtocol?,
         sessionConfig: URLSessionConfiguration?, account: DracoonAccount) {
        self.request = request
        if let uploadSessionConfig = sessionConfig {
            let uploadSessionManager = SessionManager(configuration: uploadSessionConfig)
            uploadSessionManager.retrier = config.sessionManager.retrier
            uploadSessionManager.adapter = config.sessionManager.adapter
            self.sessionManager = uploadSessionManager
        } else {
            self.sessionManager = config.sessionManager
        }
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.oAuthTokenManager = config.oauthTokenManager
        self.decoder = config.decoder
        self.encoder = config.encoder
        self.crypto = crypto
        self.account = account
        self.fileUrl = fileUrl
        self.resolutionStrategy = resolutionStrategy
    }
    deinit {
        self.callback = nil
    }
    
    public func start() {
        self.createFileUpload(request: request, completion: { result in
            switch result {
            case .value(let response):
                self.uploadUrl = response.uploadUrl
                if self.crypto == nil {
                    self.startChunkedUpload(uploadUrl: response.uploadUrl)
                } else {
                    self.startEncryptedChunkedUpload(uploadUrl: response.uploadUrl)
                }
                
            case .error(let error):
                self.callback?.onError?(error)
            }
        })
    }
    
    public func cancel() {
        guard !isCanceled else {
            return
        }
        self.isCanceled = true
        if let uploadUrl = self.uploadUrl {
            self.deleteUpload(uploadUrl: uploadUrl, completion: { _ in
                self.callback?.onCanceled?()
            })
        } else {
            self.callback?.onCanceled?()
        }
    }
    
    func createFileUpload(request: CreateFileUploadRequest, completion: @escaping DataRequest.DecodeCompletion<CreateFileUploadResponse>) {
        do {
            let jsonBody = try encoder.encode(request)
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .decode(CreateFileUploadResponse.self, decoder: self.decoder, requestType: .createUpload, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func startChunkedUpload(uploadUrl: String) {
        var urlRequest = URLRequest(url: URL(string: uploadUrl)!)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        self.sessionManager.upload(multipartFormData: { (multipartData) in
            multipartData.append(self.fileUrl, withName: "file")
        }, usingThreshold: UInt64(DracoonConstants.UPLOAD_CHUNK_SIZE), with: urlRequest, encodingCompletion: { encodingResult in
            switch (encodingResult) {
            case .success(let request, _, _):
                self.urlSessionTask = request.task
                request.uploadProgress(closure: { (progress) in
                    self.callback?.onProgress?(Float(progress.fractionCompleted))
                })
                request.responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success(_):
                        self.completeUpload(uploadUrl: uploadUrl, encryptedFileKey: nil)
                    case .failure(let error):
                        self.callback?.onError?(DracoonError.generic(error: error))
                    }
                })
            case .failure(let error):
                self.callback?.onError?(DracoonError.generic(error: error))
            }
        })
    }
    
    func startEncryptedChunkedUpload(uploadUrl: String) {
        
        let totalFileSize = FileUtils.calculateFileSize(filePath: self.fileUrl) ?? 0 as Int64
        
        var cipher: EncryptionCipher?
        if let crypto = self.crypto {
            do {
                let fileKey = try crypto.generateFileKey(version: CryptoConstants.DEFAULT_VERSION)
                cipher = try crypto.createEncryptionCipher(fileKey: fileKey)
            } catch {
                self.callback?.onError?(DracoonError.encryption_cipher_failure)
                return
            }
            
        }
        self.createNextChunk(uploadUrl: uploadUrl, offset: 0, fileSize: totalFileSize, cipher: cipher, completion: {
            if let crypto = self.crypto, let cipher = cipher {
                self.account.getUserKeyPair(completion: { result in
                    switch result {
                    case .error(let error):
                        self.callback?.onError?(error)
                        return
                    case .value(let userKeyPair):
                        do {
                            let publicKey = UserPublicKey(publicKey: userKeyPair.publicKeyContainer.publicKey, version: userKeyPair.publicKeyContainer.version)
                            let encryptedFileKey = try crypto.encryptFileKey(fileKey: cipher.fileKey, publicKey: publicKey)
                            self.completeUpload(uploadUrl: uploadUrl, encryptedFileKey: encryptedFileKey)
                        } catch CryptoError.encrypt(let message){
                            self.callback?.onError?(DracoonError.filekey_encryption_failure(description: message))
                        } catch {
                            self.callback?.onError?(DracoonError.generic(error: error))
                        }
                    }
                })
            } else {
                self.completeUpload(uploadUrl: uploadUrl, encryptedFileKey: nil)
            }
            
        })
    }
    
    fileprivate func createNextChunk(uploadUrl: String, offset: Int, fileSize: Int64, cipher: EncryptionCipher?, completion: @escaping () -> Void) {
        let range = NSMakeRange(offset, DracoonConstants.UPLOAD_CHUNK_SIZE)
        let lastBlock = Int64(offset + DracoonConstants.UPLOAD_CHUNK_SIZE) >= fileSize
        do {
            guard let data = try FileUtils.readData(self.fileUrl, range: range) else {
                self.callback?.onError?(DracoonError.read_data_failure(at: self.fileUrl))
                return
            }
            let uploadData: Data
            if let cipher = cipher {
                do {
                    if data.count > 0 {
                        uploadData = try cipher.processBlock(fileData: data)
                    } else {
                        uploadData = data
                    }
                    if lastBlock {
                        try cipher.doFinal()
                    }
                } catch {
                    self.callback?.onError?(error)
                    return
                }
            } else {
                uploadData = data
            }
            self.uploadNextChunk(uploadUrl: uploadUrl, chunk: uploadData, offset: offset, totalFileSize: fileSize, retryCount: 0, chunkCallback: { error in
                if let error = error {
                    self.callback?.onError?(error)
                    return
                }
                if lastBlock {
                    completion()
                }
                else {
                    let newOffset = offset + data.count
                    self.createNextChunk(uploadUrl: uploadUrl, offset: newOffset, fileSize: fileSize, cipher: cipher, completion: completion)
                }
            }, callback: callback)
        } catch {
            
        }
    }
    
    fileprivate func uploadNextChunk(uploadUrl: String, chunk: Data, offset: Int, totalFileSize: Int64, retryCount: Int, chunkCallback: @escaping (Error?) -> Void, callback: UploadCallback?) {
        if self.isCanceled {
            return
        }
        var urlRequest = URLRequest(url: URL(string: uploadUrl)!)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.addValue("bytes " + String(offset) + "-" + String(offset + chunk.count) + "/*", forHTTPHeaderField: "Content-Range")
        
        self.sessionManager.upload(multipartFormData: { (formData) in
            formData.append(chunk, withName: "file", fileName: "file.name", mimeType: "application/octet-stream")
        },
                                   with: urlRequest,
                                   encodingCompletion: { (encodingResult) in
                                    switch encodingResult {
                                    case .success(let upload, _, _):
                                        upload.validate()
                                        upload.responseData { dataResponse in
                                            if let error = dataResponse.error {
                                                self.handleUploadError(error: error, uploadUrl: uploadUrl, chunk: chunk, offset: offset, totalFileSize: totalFileSize, retryCount: retryCount, chunkCallback: chunkCallback, callback: callback)
                                            } else {
                                                if self.checkMD5(result: dataResponse.result, localFileMD5: FileUtils.calculateMD5(chunk)) {
                                                    chunkCallback(nil)
                                                } else {
                                                    // MD5 check failed
                                                    self.handleUploadError(error: DracoonError.hash_check_failed, uploadUrl: uploadUrl, chunk: chunk, offset: offset, totalFileSize: totalFileSize, retryCount: retryCount, chunkCallback: chunkCallback, callback: callback)
                                                }
                                            }
                                        }
                                        upload.uploadProgress(closure: { progress in
                                            self.callback?.onProgress?((Float(progress.fractionCompleted)*Float(chunk.count) + Float(offset))/Float(totalFileSize))
                                        })
                                        
                                    case .failure(let error):
                                        self.handleUploadError(error: error, uploadUrl: uploadUrl, chunk: chunk, offset: offset, totalFileSize: totalFileSize, retryCount: retryCount, chunkCallback: chunkCallback, callback: callback)
                                    }
        })
    }
    
    fileprivate func handleUploadError(error: Error, uploadUrl: String, chunk: Data, offset: Int, totalFileSize: Int64, retryCount: Int,
                                       chunkCallback: @escaping (Error?) -> Void, callback: UploadCallback?) {
        if retryCount < DracoonConstants.CHUNK_UPLOAD_MAX_RETRIES {
            self.uploadNextChunk(uploadUrl: uploadUrl, chunk: chunk, offset: offset, totalFileSize: totalFileSize, retryCount: retryCount + 1, chunkCallback: chunkCallback, callback: callback)
        } else {
            chunkCallback(error)
        }
    }
    
    func checkMD5(result: Result<Data>, localFileMD5: String) -> Bool {
        if let response = result.value {
            if let responseModel = try? self.decoder.decode(ChunkUploadResponse.self, from: response) {
                return responseModel.hash == localFileMD5
            }
        }
        return true
    }
    
    func completeUpload(uploadUrl: String, encryptedFileKey: EncryptedFileKey?) {
        var completeRequest = CompleteUploadRequest()
        completeRequest.fileName = self.request.name
        completeRequest.resolutionStrategy = self.resolutionStrategy
        completeRequest.fileKey = encryptedFileKey
        
        self.sendCompleteRequest(uploadUrl: uploadUrl, request: completeRequest, sessionManager: self.sessionManager, completion: { result in
            switch result {
            case .value(let node):
                self.callback?.onComplete?(node)
            case .error(let error):
                self.callback?.onError?(error)
            }
        })
    }
    
    func completeBackgroundUpload(sessionManager: SessionManager, completionHandler: @escaping (DracoonError?) -> Void) {
        guard let uploadUrl = self.uploadUrl else {
            completionHandler(DracoonError.upload_not_found)
            return
        }
        var completeRequest = CompleteUploadRequest()
        completeRequest.fileName = self.request.name
        completeRequest.resolutionStrategy = self.resolutionStrategy
        
        self.sendCompleteRequest(uploadUrl: uploadUrl, request: completeRequest, sessionManager: sessionManager, completion: { result in
            switch result {
            case .value(_):
                completionHandler(nil)
            case .error(let error):
                completionHandler(error)
            }
        })
    }
    
    func resumeBackgroundUpload() {
        self.urlSessionTask?.resume()
    }
    
    fileprivate func sendCompleteRequest(uploadUrl: String, request: CompleteUploadRequest, sessionManager: SessionManager, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        do {
            let jsonBody = try encoder.encode(request)
            var urlRequest = URLRequest(url: URL(string: uploadUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            sessionManager.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func deleteUpload(uploadUrl: String, completion: @escaping (Dracoon.Response) -> Void) {
        self.sessionManager.request(uploadUrl, method: .delete, parameters: Parameters())
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
}
