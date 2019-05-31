//
//  FileUpload.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

public class FileUpload {
    
    let sessionManager: Alamofire.SessionManager
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthTokenManager
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    let account: DracoonAccount
    let request: CreateFileUploadRequest
    let resolutionStrategy: CompleteUploadRequest.ResolutionStrategy
    let filePath: URL
    
    var callback: UploadCallback?
    let crypto: Crypto?
    fileprivate var isCanceled = false
    fileprivate var uploadId: String?
    
    init(config: DracoonRequestConfig, request: CreateFileUploadRequest, filePath: URL, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy, crypto: Crypto?,
         account: DracoonAccount) {
        self.request = request
        self.sessionManager = config.sessionManager
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.oAuthTokenManager = config.oauthTokenManager
        self.decoder = config.decoder
        self.encoder = config.encoder
        self.crypto = crypto
        self.account = account
        self.filePath = filePath
        self.resolutionStrategy = resolutionStrategy
    }
    
    public func start() {
        self.createFileUpload(request: request, completion: { result in
            switch result {
            case .value(let response):
                self.uploadId = response.uploadId
                self.callback?.onStarted?(response.uploadId)
                self.uploadChunks(uploadId: response.uploadId)
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
        if let uploadId = self.uploadId {
            self.deleteUpload(uploadId: uploadId, completion: { _ in
                self.callback?.onCanceled?()
            })
        } else {
            self.callback?.onCanceled?()
        }
    }
    
    fileprivate func createFileUpload(request: CreateFileUploadRequest, completion: @escaping DataRequest.DecodeCompletion<CreateFileUploadResponse>) {
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
    
    fileprivate func uploadChunks(uploadId: String) {
        
        let totalFileSize = self.calculateFileSize(filePath: self.filePath) ?? 0 as Int64
        
        var cipher: FileEncryptionCipher?
        if let crypto = self.crypto {
            do {
                let fileKey = try crypto.generateFileKey()
                cipher = try crypto.createEncryptionCipher(fileKey: fileKey)
            } catch {
                self.callback?.onError?(DracoonError.encryption_cipher_failure)
                return
            }
            
        }
        self.createNextChunk(uploadId: uploadId, offset: 0, fileSize: totalFileSize, cipher: cipher, completion: {
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
                            self.completeRequest(uploadId: uploadId, encryptedFileKey: encryptedFileKey)
                        } catch CryptoError.encrypt(let message){
                            self.callback?.onError?(DracoonError.filekey_encryption_failure(description: message))
                        } catch {
                            self.callback?.onError?(DracoonError.generic(error: error))
                        }
                    }
                })
            } else {
                self.completeRequest(uploadId: uploadId, encryptedFileKey: nil)
            }
            
        })
    }
    
    fileprivate func createNextChunk(uploadId: String, offset: Int, fileSize: Int64, cipher: FileEncryptionCipher?, completion: @escaping () -> Void) {
        let range = NSMakeRange(offset, DracoonConstants.UPLOAD_CHUNK_SIZE)
        let lastBlock = Int64(offset + DracoonConstants.UPLOAD_CHUNK_SIZE) >= fileSize
        do {
            guard let data = try self.readData(self.filePath, range: range) else {
                self.callback?.onError?(DracoonError.read_data_failure(at: self.filePath))
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
            self.uploadNextChunk(uploadId: uploadId, chunk: uploadData, offset: offset, totalFileSize: fileSize, retryCount: 0, chunkCallback: { error in
                if let error = error {
                    self.callback?.onError?(error)
                    return
                }
                if lastBlock {
                    completion()
                }
                else {
                    let newOffset = offset + data.count
                    self.createNextChunk(uploadId: uploadId, offset: newOffset, fileSize: fileSize, cipher: cipher, completion: completion)
                }
            }, callback: callback)
        } catch {
            
        }
    }
    
    fileprivate func uploadNextChunk(uploadId: String, chunk: Data, offset: Int, totalFileSize: Int64, retryCount: Int, chunkCallback: @escaping (Error?) -> Void, callback: UploadCallback?) {
        if self.isCanceled {
            return
        }
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(uploadId)"
        
        var urlRequest = URLRequest(url: URL(string: requestUrl)!)
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
                                                if retryCount < DracoonConstants.CHUNK_UPLOAD_MAX_RETRIES {
                                                    self.uploadNextChunk(uploadId: uploadId, chunk: chunk, offset: offset, totalFileSize: totalFileSize, retryCount: retryCount + 1, chunkCallback: chunkCallback, callback: callback)
                                                } else {
                                                    chunkCallback(error)
                                                }
                                            } else {
                                                chunkCallback(nil)
                                            }
                                        }
                                        upload.uploadProgress(closure: { progress in
                                            self.callback?.onProgress?((Float(progress.fractionCompleted)*Float(chunk.count) + Float(offset))/Float(totalFileSize))
                                        })
                                        
                                    case .failure(let error):
                                        if retryCount < DracoonConstants.CHUNK_UPLOAD_MAX_RETRIES {
                                            self.uploadNextChunk(uploadId: uploadId, chunk: chunk, offset: offset, totalFileSize: totalFileSize, retryCount: retryCount + 1, chunkCallback: chunkCallback, callback: callback)
                                        } else {
                                            chunkCallback(error)
                                        }
                                    }
        })
    }
    
    fileprivate func completeRequest(uploadId: String, encryptedFileKey: EncryptedFileKey?) {
        var completeRequest = CompleteUploadRequest()
        completeRequest.fileName = self.request.name
        completeRequest.resolutionStrategy = self.resolutionStrategy
        completeRequest.fileKey = encryptedFileKey
        
        self.completeUpload(uploadId: uploadId, request: completeRequest, completion: { result in
            switch result {
            case .value(let node):
                self.callback?.onComplete?(node)
            case .error(let error):
                self.callback?.onError?(error)
            }
        })
    }
    
    fileprivate func completeUpload(uploadId: String, request: CompleteUploadRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        do {
            let jsonBody = try encoder.encode(request)
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(uploadId)"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    fileprivate func deleteUpload(uploadId: String, completion: @escaping (Dracoon.Response) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(uploadId)"
        
        self.sessionManager.request(requestUrl, method: .delete, parameters: Parameters())
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
    
    // MARK: Helper
    
    fileprivate func calculateFileSize(filePath: URL) -> Int64? {
        do {
            let fileAttribute: [FileAttributeKey : Any] = try FileManager.default.attributesOfItem(atPath: filePath.path)
            let fileSize = fileAttribute[FileAttributeKey.size] as? Int64
            return fileSize
        } catch {}
        return nil
    }
    
    func readData(_ path: URL?, range: NSRange) throws -> Data? {
        guard let path = path, let fileHandle = try? FileHandle(forReadingFrom: path) else {
            return nil
        }
        
        let offset = UInt64(range.location)
        let length = UInt64(range.length)
        let size = fileHandle.seekToEndOfFile()
        
        let maxLength = size - offset
        
        guard maxLength > 0 else {
            return nil
        }
        
        let secureLength = Int(min(length, maxLength))
        
        fileHandle.seek(toFileOffset: offset)
        let data = fileHandle.readData(ofLength: secureLength)
        
        return data
    }
}
