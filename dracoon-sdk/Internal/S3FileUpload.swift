//
//  S3FileUpload.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

public class S3FileUpload: FileUpload, @unchecked Sendable {
    
    let MAX_URL_FETCH_COUNT: Int32 = 10
    
    var s3Urls: [PresignedUrl]?
    /*
     Chunk size from Constants or 5 MB
     5MB is least S3 chunk size
     5GB is maximum S3 chunk size
     */
    var chunkSize: Int64 = DracoonConstants.S3_CHUNK_SIZE < 1024*1024*5 ? 1024*1024*5 : Int64(DracoonConstants.S3_CHUNK_SIZE)
    var neededParts: Int32 = 0
    var lastPartSize: Int64 = 0
    var eTags = [S3FileUploadPart]()
    var uploadId: String?
    var cipher: EncryptionCipher?
    
    override init(config: DracoonRequestConfig, request: CreateFileUploadRequest, fileUrl: URL, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy, crypto: CryptoProtocol?,
                  sessionConfig: URLSessionConfiguration?, account: DracoonAccount) {
        super.init(config: config, request: request, fileUrl: fileUrl, resolutionStrategy: resolutionStrategy, crypto: crypto, sessionConfig: sessionConfig, account: account)
        var s3DirectUploadRequest = request
        s3DirectUploadRequest.directS3Upload = true
        self.request = s3DirectUploadRequest
        
        self.fileSize = FileUtils.calculateFileSize(filePath: fileUrl) ?? 0
        if sessionConfig?.identifier != nil {
            self.chunkSize = self.fileSize
            self.neededParts = 1
            self.lastPartSize = 0
        } else {
            self.neededParts = Int32(self.fileSize/self.chunkSize)
            self.lastPartSize = self.fileSize%self.chunkSize
        }
    }
    
    // MARK: Start S3 Upload
    
    override public func start() {
        if self.uploadSessionConfig?.identifier != nil,
           self.fileSize > DracoonConstants.S3_BACKGROUND_UPLOAD_MAX_SIZE {
            self.callback?.onError?(DracoonError.exceeds_maximum_s3_upload_size(fileSize: self.fileSize, maximumSize: DracoonConstants.S3_BACKGROUND_UPLOAD_MAX_SIZE))
            return
        }
        self.createFileUpload(request: request, completion: { result in
            switch result {
            case .value(let response):
                self.uploadId = response.uploadId
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
    
    func obtainUrls(completion: @escaping DataRequest.DecodeCompletion<PresignedUrlList>) {
        let completedParts = Int32(self.eTags.count)
        let remainingParts = self.neededParts - completedParts
        guard remainingParts > 0 else {
            self.requestPresignedUrls(firstPartNumber: self.neededParts + 1, lastPartNumber: self.neededParts + 1, size: self.lastPartSize, completion: completion)
            return
        }
        let partsToFetch = remainingParts <= MAX_URL_FETCH_COUNT ? remainingParts : MAX_URL_FETCH_COUNT
        let lastPartNumber = completedParts + partsToFetch
        self.requestPresignedUrls(firstPartNumber: completedParts + 1, lastPartNumber: lastPartNumber, size: self.chunkSize, completion: { urlResult in
            switch urlResult {
            case .error(let error):
                self.callback?.onError?(error)
            case .value(let response):
                self.handlePresignedUrlsResponse(response: response, lastPartNumber: lastPartNumber, completion: completion)
            }
        })
    }
    
    fileprivate func handlePresignedUrlsResponse(response: PresignedUrlList, lastPartNumber: Int32, completion: @escaping DataRequest.DecodeCompletion<PresignedUrlList>) {
        guard lastPartNumber == self.neededParts else {
            completion(Dracoon.Result.value(response))
            return
        }
        let lastParts = response.urls
        if self.lastPartSize > 0 {
            // request last part
            self.requestPresignedUrls(firstPartNumber: self.neededParts + 1, lastPartNumber: self.neededParts + 1, size: self.lastPartSize, completion: { [lastParts] lastUrlResult in
                switch lastUrlResult {
                case .error(let error):
                    completion(Dracoon.Result.error(error))
                case .value(let response):
                    var parts = lastParts
                    parts.append(contentsOf: response.urls)
                    completion(Dracoon.Result.value(PresignedUrlList(urls: parts)))
                }
            })
        } else {
            completion(Dracoon.Result.value(response))
        }
    }
    
    fileprivate func requestPresignedUrls(firstPartNumber: Int32, lastPartNumber: Int32, size: Int64, completion: @escaping DataRequest.DecodeCompletion<PresignedUrlList>) {
        print("request urls \(firstPartNumber)-\(lastPartNumber)")
        let request = GeneratePresignedUrlsRequest(size: size, firstPartNumber: firstPartNumber, lastPartNumber: lastPartNumber)
        
        do {
            let jsonBody = try encoder.encode(request)
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(self.uploadId ?? "")/s3_urls"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
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
        print("presignedUrl count \(urls.count)")
        if let sessionConfig = self.uploadSessionConfig,
           sessionConfig.identifier != nil {
            print("background s3 upload")
            self.uploadBackgroundToPresignedURL(firstUrl)
        } else {
            var cipher: EncryptionCipher?
            if let crypto = self.crypto {
                do {
                    let fileKey = try crypto.generateFileKey(version: PlainFileKeyVersion.AES256GCM)
                    cipher = try crypto.createEncryptionCipher(fileKey: fileKey)
                    self.cipher = cipher
                } catch {
                    self.callback?.onError?(DracoonError.encryption_cipher_failure)
                    return
                }
            }
            print("foreground s3 upload")
            self.createNextChunk(uploadId: uploadId, presignedUrl: firstUrl, cipher: cipher, completion: { [cipher] in
                self.completeS3Upload(uploadId: uploadId, cipher: cipher)
            })
        }
    }
    
    // MARK: Background S3 Upload
    
    fileprivate func uploadBackgroundToPresignedURL(_ presignedUrl: PresignedUrl) {
        var fileToUpload = self.fileUrl
        if self.crypto != nil {
            do {
                let result = try self.encryptFile()
                self.cipher = result.cipher
                fileToUpload = result.url
            } catch {
                self.callback?.onError?(error)
                return
            }
        }
        let uploadUrl = presignedUrl.url
        let sessionConfiguration: URLSessionConfiguration
        if let sessionConfig = self.uploadSessionConfig {
            sessionConfiguration = sessionConfig
        } else {
            sessionConfiguration = self.session.sessionConfiguration
        }
        let uploadSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        var urlRequest = URLRequest(url: URL(string: uploadUrl)!)
        urlRequest.httpMethod = HTTPMethod.put.rawValue
        urlRequest.addValue("application/octet-stream", forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
        let task = uploadSession.uploadTask(with: urlRequest, fromFile: fileToUpload)
        if self.fileSize > 0 {
            task.countOfBytesClientExpectsToSend = fileSize
        }
        self.urlSessionTask = task
        task.resume()
    }
    
    // MARK: URLSessionDataDelegate for background S3 Upload
    
    override func handleUploadCompletion(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let urls = self.s3Urls, let presignedUrl = urls.first,
              let uploadId = self.uploadId else {
            self.callback?.onCanceled?()
            return
        }
        if let uploadError = error {
            self.callback?.onError?(DracoonError.generic(error: uploadError))
        } else {
            if let httpURLResponse = task.response as? HTTPURLResponse, httpURLResponse.statusCode < 300 {
                let headerFields = httpURLResponse.allHeaderFields
                if let result = headerFields.keys.first(where: { ($0 as? String)?.caseInsensitiveCompare("eTag") == .orderedSame}) as? String,
                   let eTag = headerFields[result] as? String {
                    let cleanEtag = eTag.replacingOccurrences(of: "\"", with: "")
                    let uploadPart = S3FileUploadPart(partNumber: presignedUrl.partNumber, partEtag: cleanEtag)
                    self.eTags.append(uploadPart)
                    self.completeS3Upload(uploadId: uploadId, cipher: self.cipher)
                    return
                }
            }
            let errorModel = DracoonSDKErrorModel(errorCode: .UNKNOWN, httpStatusCode: (task.response as? HTTPURLResponse)?.statusCode)
            self.callback?.onError?(DracoonError.api(error: errorModel))
        }
    }
    
    // MARK: Foreground S3 Upload
    
    fileprivate func uploadForegroundToPresignedUrl(_ presignedUrl: PresignedUrl, chunk: Data, retryCount: Int, chunkCallback: @Sendable @escaping (Error?) -> Void) {
        let requestUrl = presignedUrl.url
        
        var urlRequest = URLRequest(url: URL(string: requestUrl)!)
        urlRequest.httpMethod = HTTPMethod.put.rawValue
        
        var headers = HTTPHeaders()
        headers[ApiRequestConstants.headerFields.keys.contentType] = "application/octet-stream"
        
        let request = self.session.upload(chunk, to: requestUrl, method: .put, headers: headers)
        
        request.uploadProgress(closure: { progress in
            let recentChunkProgress = Float(progress.fractionCompleted)*Float(chunk.count)
            let overallProgress = recentChunkProgress + Float(Int(self.chunkSize)*(Int(presignedUrl.partNumber) - 1))
            self.callback?.onProgress?(overallProgress/Float(self.fileSize))
        })
        
        request.response(completionHandler: { dataResponse in
            if let error = dataResponse.error {
                self.handleUploadError(error: error, url: presignedUrl, chunk: chunk, retryCount: retryCount, chunkCallback: chunkCallback)
            } else {
                if dataResponse.response?.statusCode ?? 400 < 300, let headerFields = dataResponse.response?.allHeaderFields,
                   let result = headerFields.keys.first(where: { ($0 as? String)?.caseInsensitiveCompare("eTag") == .orderedSame}) as? String,
                   let eTag = headerFields[result] as? String {
                    let cleanEtag = eTag.replacingOccurrences(of: "\"", with: "")
                    let uploadPart = S3FileUploadPart(partNumber: presignedUrl.partNumber, partEtag: cleanEtag)
                    self.eTags.append(uploadPart)
                    chunkCallback(nil)
                    return
                }
                let errorModel = DracoonSDKErrorModel(errorCode: .UNKNOWN, httpStatusCode: dataResponse.response?.statusCode)
                self.handleUploadError(error: DracoonError.api(error: errorModel), url: presignedUrl, chunk: chunk, retryCount: retryCount, chunkCallback: chunkCallback)
            }
        })
    }
    
    fileprivate func createNextChunk(uploadId: String, presignedUrl: PresignedUrl, cipher: EncryptionCipher?, completion: @Sendable @escaping () -> Void) {
        if self.isCanceled {
            return
        }
        let offset: Int = Int(presignedUrl.partNumber - 1) * Int(self.chunkSize)
        let range = NSMakeRange(offset, Int(self.chunkSize))
        let lastBlock = self.isLastBlock(presignedUrl: presignedUrl)
        
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
            self.startForegroundUploadForChunkAndProceed(data: uploadData, presignedUrl: presignedUrl, uploadId: uploadId, cipher: cipher, isLastBlock: lastBlock, completion: completion)
        } catch {
            self.callback?.onError?(DracoonError.read_data_failure(at: self.fileUrl))
        }
    }
    
    fileprivate func startForegroundUploadForChunkAndProceed(data: Data, presignedUrl: PresignedUrl, uploadId: String, cipher: EncryptionCipher?, isLastBlock: Bool, completion: @Sendable @escaping () -> Void) {
        self.uploadForegroundToPresignedUrl(presignedUrl, chunk: data, retryCount: 0, chunkCallback: { error in
            if let error = error {
                self.callback?.onError?(error)
                return
            }
            if isLastBlock {
                completion()
            }
            else {
                if let urls = self.s3Urls, urls.count >= presignedUrl.partNumber + 1 {
                    let nextUrl = urls[Int(presignedUrl.partNumber)]
                    self.createNextChunk(uploadId: uploadId, presignedUrl: nextUrl, cipher: cipher, completion: completion)
                } else {
                    self.createMoreUrlsAndProceed(uploadId: uploadId, cipher: cipher, completion: completion)
                }
            }
        })
    }
    
    fileprivate func createMoreUrlsAndProceed(uploadId: String, cipher: EncryptionCipher?, completion: @Sendable @escaping () -> Void) {
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
    
    fileprivate func handleUploadError(error: Error, url: PresignedUrl, chunk: Data, retryCount: Int, chunkCallback: @Sendable @escaping (Error?) -> Void) {
        if retryCount < DracoonConstants.S3_UPLOAD_MAX_RETRIES {
            self.uploadForegroundToPresignedUrl(url, chunk: chunk, retryCount: retryCount + 1, chunkCallback: chunkCallback)
        } else {
            self.callback?.onError?(DracoonError.generic(error: error))
        }
    }
    
    fileprivate func isLastBlock(presignedUrl: PresignedUrl) -> Bool {
        if self.lastPartSize > 0 {
            return presignedUrl.partNumber == self.neededParts + 1
        }
        return presignedUrl.partNumber == self.neededParts
    }
    
    // MARK: Complete S3 Upload
    
    func completeS3Upload(uploadId: String, cipher: EncryptionCipher?) {
        if let crypto = self.crypto {
            guard let cipher = cipher else {
                self.callback?.onError?(DracoonError.encryption_cipher_failure)
                return
            }
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
    }
    
    func completeUpload(uploadId: String, encryptedFileKey: EncryptedFileKey?) {
        let completeRequest = CompleteS3FileUploadRequest(parts: self.eTags, resolutionStrategy: self.resolutionStrategy, keepShareLinks: false, fileName: self.request.name, fileKey: encryptedFileKey)
        self.sendCompleteRequest(uploadId: uploadId, request: completeRequest, completion: { response in
            if let error = response.error {
                self.callback?.onError?(error)
            } else {
                self.pollForStatus(uploadId: uploadId, waitTimeSec: 1)
            }
        })
    }
    
    fileprivate func sendCompleteRequest(uploadId: String, request: CompleteS3FileUploadRequest, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(uploadId)/s3"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
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
                self.handleUploadStatusResponse(response: response, uploadId: uploadId, waitTimeSec: waitTimeSec)
            }
        })
    }
    
    fileprivate func handleUploadStatusResponse(response: S3FileUploadStatus, uploadId: String, waitTimeSec: Int) {
        if response.status == S3FileUploadStatus.S3UploadStatus.done.rawValue {
            if let responseNode = response.node {
                self.callback?.onComplete?(responseNode)
            } else {
                let errorModel = DracoonSDKErrorModel(errorCode: .SERVER_NODE_NOT_FOUND, httpStatusCode: nil)
                self.callback?.onError?(DracoonError.api(error: errorModel))
            }
        } else if response.status == S3FileUploadStatus.S3UploadStatus.error.rawValue {
            self.handleUploadStatusErrorResponse(response: response)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(waitTimeSec), execute: {
                let waitTime = waitTimeSec >= 4 ? waitTimeSec : waitTimeSec * 2
                self.pollForStatus(uploadId: uploadId, waitTimeSec: waitTime)
            })
        }
    }
    
    fileprivate func handleUploadStatusErrorResponse(response: S3FileUploadStatus) {
        if let error = response.errorDetails {
            let code = DracoonErrorParser.shared.parseApiErrorResponse(error, requestType: .other)
            let errorModel = DracoonSDKErrorModel(errorCode: code, httpStatusCode: error.code)
            self.callback?.onError?(DracoonError.api(error: errorModel))
        } else {
            let errorModel = DracoonSDKErrorModel(errorCode: .S3_UPLOAD_COMPLETION_FAILED, httpStatusCode: nil)
            self.callback?.onError?(DracoonError.api(error: errorModel))
        }
    }
    
    fileprivate func getS3UploadStatus(uploadId: String, completion: @escaping DataRequest.DecodeCompletion<S3FileUploadStatus>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(uploadId)"
        
        self.session.request(requestUrl, method: .get, parameters: nil)
            .validate()
            .decode(S3FileUploadStatus.self, decoder: self.decoder, requestType: .other, completion: completion)
    }
    
    // MARK: Cancel S3 Upload
    
    override public func cancel() {
        guard !isCanceled else {
            return
        }
        self.isCanceled = true
        self.urlSessionTask?.cancel()
        if let uploadId = self.uploadId {
            self.deleteUpload(uploadId: uploadId, completion: { _ in
                self.callback?.onCanceled?()
            })
        } else {
            self.callback?.onCanceled?()
        }
    }
    
    fileprivate func deleteUpload(uploadId: String, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(uploadId)"
        
        self.session.request(requestUrl, method: .delete, parameters: Parameters())
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
}
