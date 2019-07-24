//
//  S3FileUpload.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

public class S3FileUpload: FileUpload {
    
    let MAXIMAL_URL_FETCH_COUNT: Int32 = 10
    
    var s3Urls: [PresignedUrl]?
    // chunkSize from Constants or 5 MB; 5MB is least S3 chunk size
    let chunkSize: Int64 = DracoonConstants.UPLOAD_CHUNK_SIZE < 1024*1024*5 ? 1024*1024*5 : Int64(DracoonConstants.UPLOAD_CHUNK_SIZE)
    var fileSize: Int64 = 0
    var neededParts: Int32 = 0
    var lastPartSize: Int64 = 0
    var eTags = [S3FileUploadPart]()
    
    override init(config: DracoonRequestConfig, request: CreateFileUploadRequest, filePath: URL, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy, crypto: Crypto?,
                  account: DracoonAccount) {
        super.init(config: config, request: request, filePath: filePath, resolutionStrategy: resolutionStrategy, crypto: crypto, account: account)
        var s3DirectUploadRequest = request
        s3DirectUploadRequest.directS3Upload = true
        self.request = s3DirectUploadRequest
        
        self.fileSize = self.calculateFileSize(filePath: self.filePath) ?? 0
        self.neededParts = Int32(fileSize/chunkSize)
        self.lastPartSize = fileSize%chunkSize
    }
    
    
    override public func start() {
        self.createFileUpload(request: request, completion: { result in
            switch result {
            case .value(let response):
                self.uploadId = response.uploadId
                self.callback?.onStarted?(response.uploadId)
                self.obtainUrls(completion: { urlResult in
                    switch urlResult {
                    case .error(let error):
                        self.callback?.onError?(error)
                    case .value(let response):
                        if self.s3Urls != nil {
                            self.s3Urls?.append(contentsOf: response.urls)
                        } else {
                            self.s3Urls = response.urls
                        }
                        self.startUploadWithPresignedUrls()
                    }
                })
            case .error(let error):
                self.callback?.onError?(error)
            }
        })
    }
    
    override public func cancel() {
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
    
    func obtainUrls(completion: @escaping DataRequest.DecodeCompletion<PresignedUrlList>) {
        let completedParts = Int32(self.eTags.count)
        let remainingParts = self.neededParts - completedParts
        if remainingParts > 0 {
            let partsToFetch = remainingParts <= MAXIMAL_URL_FETCH_COUNT ? remainingParts : MAXIMAL_URL_FETCH_COUNT
            let lastPartNumber = completedParts + partsToFetch
            self.requestPresignedUrls(firstPartNumber: completedParts + 1, lastPartNumber: lastPartNumber, size: self.chunkSize, completion: { urlResult in
                switch urlResult {
                case .error(let error):
                    self.callback?.onError?(error)
                case .value(let response):
                    if lastPartNumber == self.neededParts {
                        var lastParts = response.urls
                        if self.lastPartSize > 0 {
                            // request last part
                            self.requestPresignedUrls(firstPartNumber: self.neededParts + 1, lastPartNumber: self.neededParts + 1, size: self.lastPartSize, completion: { lastUrlResult in
                                switch lastUrlResult {
                                case .error(let error):
                                    completion(Dracoon.Result.error(error))
                                case .value(let response):
                                    lastParts.append(contentsOf: response.urls)
                                    completion(Dracoon.Result.value(PresignedUrlList(urls: lastParts)))
                                }
                            })
                        } else {
                            completion(Dracoon.Result.value(response))
                        }
                    } else {
                        completion(Dracoon.Result.value(response))
                    }
                }
            })
        } else {
            self.requestPresignedUrls(firstPartNumber: neededParts + 1, lastPartNumber: neededParts + 1, size: self.lastPartSize, completion: completion)
        }
    }
    
    fileprivate func requestPresignedUrls(firstPartNumber: Int32, lastPartNumber: Int32, size: Int64, completion: @escaping DataRequest.DecodeCompletion<PresignedUrlList>) {
        let request = GeneratePresignedUrlsRequest(size: size, firstPartNumber: firstPartNumber, lastPartNumber: lastPartNumber)
        
        do {
            let jsonBody = try encoder.encode(request)
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(self.uploadId ?? "")/s3_urls"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .decode(PresignedUrlList.self, decoder: self.decoder, requestType: .other, completion: completion)
        } catch {
            self.callback?.onError?(error)
        }
    }
    
    func startUploadWithPresignedUrls() {
        guard let urls = self.s3Urls, let firstUrl = urls.first, let uploadId = self.uploadId else {
            self.callback?.onCanceled?()
            return
        }
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
        self.createNextChunk(uploadId: uploadId, presignedUrl: firstUrl, cipher: cipher, completion: {
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
                            self.completeUpload(uploadId: uploadId, encryptedFileKey: encryptedFileKey)
                        } catch CryptoError.encrypt(let message){
                            self.callback?.onError?(DracoonError.filekey_encryption_failure(description: message))
                        } catch {
                            self.callback?.onError?(DracoonError.generic(error: error))
                        }
                    }
                })
            } else {
                self.completeUpload(uploadId: uploadId, encryptedFileKey: nil)
            }
        })
    }
    
    fileprivate func uploadToPresignedUrl(_ presignedUrl: PresignedUrl, chunk: Data, retryCount: Int, chunkCallback: @escaping (Error?) -> Void) {
        let requestUrl = presignedUrl.url
        
        var urlRequest = URLRequest(url: URL(string: requestUrl)!)
        urlRequest.httpMethod = HTTPMethod.put.rawValue
        
        var headers = HTTPHeaders()
        headers["Content-Type"] = "application/octet-stream"
        
        let request = self.sessionManager.upload(chunk, to: requestUrl, method: .put, headers: headers)
        
        request.uploadProgress(closure: { progress in
            let recentChunkProgress = Float(progress.fractionCompleted)*Float(chunk.count)
            let overallProgress = recentChunkProgress + Float(Int(self.chunkSize)*(Int(presignedUrl.partNumber) - 1))
            self.callback?.onProgress?(overallProgress/Float(self.fileSize))
        })
        
        request.response(completionHandler: { dataResponse in
            if let error = dataResponse.error {
                self.handleUploadError(error: error, url: presignedUrl, chunk: chunk, retryCount: retryCount, chunkCallback: chunkCallback)
            } else {
                if dataResponse.response!.statusCode < 300, let headerFields = dataResponse.response?.allHeaderFields {
                    if let result = headerFields.keys.first(where: { ($0 as? String)?.caseInsensitiveCompare("eTag") == .orderedSame}) as? String {
                        if let eTag = headerFields[result] as? String {
                            let cleanEtag = eTag.replacingOccurrences(of: "\"", with: "")
                            let uploadPart = S3FileUploadPart(partNumber: presignedUrl.partNumber, partEtag: cleanEtag)
                            self.eTags.append(uploadPart)
                            chunkCallback(nil)
                            return
                        }
                    }
                }
                let errorModel = DracoonSDKErrorModel(errorCode: .UNKNOWN, httpStatusCode: dataResponse.response?.statusCode)
                self.handleUploadError(error: DracoonError.api(error: errorModel), url: presignedUrl, chunk: chunk, retryCount: retryCount, chunkCallback: chunkCallback)
            }
        })
    }
    
    fileprivate func handleUploadError(error: Error, url: PresignedUrl, chunk: Data, retryCount: Int, chunkCallback: @escaping (Error?) -> Void) {
        if retryCount < DracoonConstants.CHUNK_UPLOAD_MAX_RETRIES {
            self.uploadToPresignedUrl(url, chunk: chunk, retryCount: retryCount + 1, chunkCallback: chunkCallback)
        } else {
            self.callback?.onError?(DracoonError.generic(error: error))
        }
    }
    
    fileprivate func createNextChunk(uploadId: String, presignedUrl: PresignedUrl, cipher: FileEncryptionCipher?, completion: @escaping () -> Void) {
        if self.isCanceled {
            return
        }
        let offset: Int = Int((presignedUrl.partNumber - 1)) * Int(self.chunkSize)
        let range = NSMakeRange(offset, Int(self.chunkSize))
        let lastBlock = self.isLastBlock(presignedUrl: presignedUrl)
        
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
            self.uploadToPresignedUrl(presignedUrl, chunk: uploadData, retryCount: 0, chunkCallback: { error in
                if let error = error {
                    self.callback?.onError?(error)
                    return
                }
                if lastBlock {
                    completion()
                }
                else {
                    if let urls = self.s3Urls, urls.count >= presignedUrl.partNumber + 1 {
                        let nextUrl = urls[Int(presignedUrl.partNumber)]
                        self.createNextChunk(uploadId: uploadId, presignedUrl: nextUrl, cipher: cipher, completion: completion)
                    } else {
                        self.obtainUrls(completion: { result in
                            switch result {
                            case .error(let error):
                                self.callback?.onError?(error)
                            case .value(let response):
                                self.s3Urls?.append(contentsOf: response.urls)
                                let nextUrl = response.urls.first!
                                self.createNextChunk(uploadId: uploadId, presignedUrl: nextUrl, cipher: cipher, completion: completion)
                            }
                        })
                    }
                }
            })
        } catch {
            self.callback?.onError?(DracoonError.read_data_failure(at: self.filePath))
        }
    }
    
    fileprivate func isLastBlock(presignedUrl: PresignedUrl) -> Bool {
        if self.lastPartSize > 0 {
            return presignedUrl.partNumber == self.neededParts + 1
        }
        return presignedUrl.partNumber == self.neededParts
    }
    
    override func completeUpload(uploadId: String, encryptedFileKey: EncryptedFileKey?) {
        let completeRequest = CompleteS3FileUploadRequest(parts: self.eTags, resolutionStrategy: self.resolutionStrategy, keepShareLinks: false, fileName: self.request.name, fileKey: encryptedFileKey)
        self.sendCompleteRequest(uploadId: uploadId, request: completeRequest, completion: { response in
            if let error = response.error {
                self.callback?.onError?(error)
            } else {
                self.pollForStatus(uploadId: uploadId, waitTimeSec: 1)
            }
        })
    }
    
    fileprivate func sendCompleteRequest(uploadId: String, request: CompleteS3FileUploadRequest, completion: @escaping (Dracoon.Response) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(uploadId)/s3"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .handleResponse(decoder: self.decoder, completion: completion)
            
        } catch {
            completion(Dracoon.Response(error: DracoonError.encode(error: error)))
        }
    }
    
    func pollForStatus(uploadId: String, waitTimeSec: Int) {
        self.getS3UploadStatus(uploadId: uploadId, completion: { result in
            switch result {
            case .error(let error):
                self.callback?.onError?(error)
            case .value(let response):
                if response.status == S3FileUploadStatus.S3UploadStatus.done.rawValue {
                    if let responseNode = response.node {
                        self.callback?.onComplete?(responseNode)
                    } else {
                        let errorModel = DracoonSDKErrorModel(errorCode: .SERVER_NODE_NOT_FOUND, httpStatusCode: nil)
                        self.callback?.onError?(DracoonError.api(error: errorModel))
                    }
                } else if response.status == S3FileUploadStatus.S3UploadStatus.error.rawValue {
                    if let error = response.errorDetails {
                        let code = DracoonErrorParser.shared.parseApiErrorResponse(error, requestType: .other)
                        let errorModel = DracoonSDKErrorModel(errorCode: code, httpStatusCode: error.code)
                        self.callback?.onError?(DracoonError.api(error: errorModel))
                    } else {
                        let errorModel = DracoonSDKErrorModel(errorCode: .S3_UPLOAD_COMPLETION_FAILED, httpStatusCode: nil)
                        self.callback?.onError?(DracoonError.api(error: errorModel))
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(waitTimeSec), execute: {
                        let waitTime = waitTimeSec >= 4 ? waitTimeSec : waitTimeSec * 2
                        self.pollForStatus(uploadId: uploadId, waitTimeSec: waitTime)
                    })
                }
            }
        })
    }
    
    fileprivate func getS3UploadStatus(uploadId: String, completion: @escaping DataRequest.DecodeCompletion<S3FileUploadStatus>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(uploadId)"
        
        self.sessionManager.request(requestUrl, method: .get, parameters: nil)
            .validate()
            .decode(S3FileUploadStatus.self, decoder: self.decoder, requestType: .other, completion: completion)
    }
}
