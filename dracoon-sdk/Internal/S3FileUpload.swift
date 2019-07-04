//
//  S3FileUpload.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

public class S3FileUpload: DracoonUpload {
    
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
    
    var s3Urls: [PresignedUrl]?
    // chunkSize from Constants or 5 MB
    let chunkSize: Int64 = DracoonConstants.UPLOAD_CHUNK_SIZE < 1024*1024*5 ? 1024*1024*5 : Int64(DracoonConstants.UPLOAD_CHUNK_SIZE)
    var fileSize: Int64?
    var eTags = [S3FileUploadPart]()
    
    init(config: DracoonRequestConfig, request: CreateFileUploadRequest, filePath: URL, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy, crypto: Crypto?,
         account: DracoonAccount) {
        var s3DirectUploadRequest = request
        s3DirectUploadRequest.directS3Upload = true
        self.request = s3DirectUploadRequest
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
    
    
    func start() {
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
                        // TODO check for sorted
                        self.s3Urls = response.urls
                        self.uploadWithPresignedUrls()
                    }
                })
            case .error(let error):
                self.callback?.onError?(error)
            }
        })
    }
    
    func cancel() {
        
    }
    
    // same as FileUpload
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
    
    fileprivate func obtainUrls(completion: @escaping DataRequest.DecodeCompletion<PresignedUrlList>) {
        if let fileSize = self.calculateFileSize(filePath: self.filePath) {
            self.fileSize = fileSize
            let neededParts = (fileSize/chunkSize) + 1
            // TODO 0 byte file, file fits exactly in chunks
            let request = GeneratePresignedUrlsRequest(size: chunkSize, firstPartNumber: 1, lastPartNumber: Int32(neededParts))
            
            do {
                let jsonBody = try encoder.encode(request)
                let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(self.uploadId ?? "")/s3_urls"
                
                var urlRequest = URLRequest(url: URL(string: requestUrl)!)
                urlRequest.httpMethod = HTTPMethod.post.rawValue
                urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = jsonBody
                
                self.sessionManager.request(urlRequest)
                    .validate()
                    .decode(PresignedUrlList.self, decoder: self.decoder, requestType: .createUpload, completion: completion)
            } catch {
                self.callback?.onError?(error)
            }
        } else {
            // TODO handle fileSize unknown
        }
        
       
    }
    
    fileprivate func uploadWithPresignedUrls() {
        guard let urls = self.s3Urls, urls.count > 0, let uploadId = self.uploadId else {
            print("invalid params")
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
        
        guard let fileSize = self.fileSize else {
            print("unknown size")
            return
        }
        
        let firstUrl = urls[0]
        self.createNextChunk(uploadId: uploadId, presignedUrl: firstUrl, fileSize: fileSize, cipher: cipher, completion: {
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
    
    fileprivate func uploadPresignedUrl(_ presignedUrl: PresignedUrl, chunk: Data, chunkCallback: @escaping (Error?) -> Void, callback: UploadCallback?) {
        let requestUrl = presignedUrl.url
        
        var urlRequest = URLRequest(url: URL(string: requestUrl)!)
        urlRequest.httpMethod = HTTPMethod.put.rawValue
        
        var headers = HTTPHeaders()
        headers["Content-Type"] = "application/octet-stream"
        
        let request = self.sessionManager.upload(chunk, to: requestUrl, method: .put, headers: headers)
        
        request.response(completionHandler: { dataResponse in
            if let error = dataResponse.error {
                self.handleUploadError(error: error)
            } else {
                if dataResponse.response!.statusCode < 300 {
                    if let eTag = dataResponse.response?.allHeaderFields["Etag"] as? String {
                        let uploadPart = S3FileUploadPart(partNumber: presignedUrl.partNumber, partEtag: eTag)
                        self.eTags.append(uploadPart)
                        chunkCallback(nil)
                    }
                } else {
                    print("no etag returned")
                }
            }
        })
        
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
                                                self.handleUploadError(error: error)
                                            } else {
                                                // store ETag
                                                if let eTag = upload.response?.allHeaderFields["ETag"] as? String {
                                                    let uploadPart = S3FileUploadPart(partNumber: presignedUrl.partNumber, partEtag: eTag)
                                                    self.eTags.append(uploadPart)
                                                    chunkCallback(nil)
                                                } else {
                                                    print("no etag returned!!")
                                                }
                                            }
                                        }
                                        upload.uploadProgress(closure: { progress in
                                            let recentChunkProgress = Float(progress.fractionCompleted)*Float(chunk.count)
                                            let overallProgress = recentChunkProgress + Float(Int(self.chunkSize)*(Int(presignedUrl.partNumber) - 1))
                                            self.callback?.onProgress?(overallProgress/Float(self.fileSize!))
                                        })

                                    case .failure(let error):
                                        self.handleUploadError(error: error)
                                    }
        })
    }
    
    fileprivate func handleUploadError(error: Error) {
        print("upload Error \(error)")
    }
    
    fileprivate func createNextChunk(uploadId: String, presignedUrl: PresignedUrl, fileSize: Int64, cipher: FileEncryptionCipher?, completion: @escaping () -> Void) {
        let offset: Int = Int((presignedUrl.partNumber - 1)) * Int(self.chunkSize)
        let range = NSMakeRange(offset, Int(self.chunkSize))
        let lastBlock = Int64(offset + Int(self.chunkSize)) >= fileSize
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
            self.uploadPresignedUrl(presignedUrl, chunk: uploadData, chunkCallback: { error in
                if let error = error {
                    self.callback?.onError?(error)
                    return
                }
                if lastBlock {
                    completion()
                }
                else {
                    if self.s3Urls!.count > presignedUrl.partNumber {
                        if let urls = self.s3Urls, urls.count >= presignedUrl.partNumber + 1 {
                            let nextUrl = urls[Int(presignedUrl.partNumber + 1)]
                            self.createNextChunk(uploadId: uploadId, presignedUrl: nextUrl, fileSize: fileSize, cipher: cipher, completion: completion)
                        } else {
                            print("no urls")
                        }
                        
                    } else {
                        print("invalid url count")
                    }
                }
            }, callback: callback)
        } catch {
            print("error at createNextChunk \(error)")
        }
    }
    
    func completeUpload(uploadId: String, encryptedFileKey: EncryptedFileKey?) {
        guard self.s3Urls!.count == self.eTags.count else {
            print("number of urls does not match number of eTags")
            return
        }
        let completeRequest = CompleteS3FileUploadRequest(parts: self.eTags, resolutionStrategy: self.resolutionStrategy, keepShareLinks: false, fileName: self.request.name, fileKey: encryptedFileKey)
        self.sendCompleteRequest(uploadId: uploadId, request: completeRequest, completion: { response in
            if let error = response.error {
                self.callback?.onError?(error)
            } else {
                self.pollForStatus(uploadId: uploadId)
            }
        })
    }
    
    func sendCompleteRequest(uploadId: String, request: CompleteS3FileUploadRequest, completion: @escaping (Dracoon.Response) -> Void) {
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
    
    func pollForStatus(uploadId: String) {
        self.getS3UploadStatus(uploadId: uploadId, completion: { result in
            switch result {
            case .error(let error):
                self.callback?.onError?(error)
            case .value(let response):
                if response.status == S3FileUploadStatus.S3UploadStatus.done.rawValue {
                    self.callback?.onComplete?(nil)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        self.pollForStatus(uploadId: uploadId)
                    })
                }
            }
        })
    }
    
    func getS3UploadStatus(uploadId: String, completion: @escaping DataRequest.DecodeCompletion<S3FileUploadStatus>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(uploadId)"
        
        self.sessionManager.request(requestUrl, method: .get, parameters: nil)
            .validate()
            .decode(S3FileUploadStatus.self, decoder: self.decoder, requestType: .getNodes, completion: completion)
    }
    
}
