//
//  S3FileUpload.swift
//  dracoon-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

public final class S3FileUpload: NSObject, DracoonUpload, URLSessionDataDelegate, Sendable {
    
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
    
    let s3ChunkSize: Int64
    let neededParts: Int32
    let lastPartSize: Int64
    
    private let properties = FileUploadProperties()
    private let s3Properties = S3FileUploadProperties()
    
    init(config: DracoonRequestConfig, request: CreateFileUploadRequest, fileUrl: URL, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy, crypto: CryptoProtocol?,
         sessionConfig: URLSessionConfiguration?, account: DracoonAccount, callback: UploadCallback?) {
        var s3DirectUploadRequest = request
        s3DirectUploadRequest.directS3Upload = true
        self.request = s3DirectUploadRequest
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
        self.fileSize = FileUtils.calculateFileSize(filePath: fileUrl) ?? 0
        
        self.properties.setSessionConfig(sessionConfig)
        self.properties.setCallback(callback)
        if sessionConfig?.identifier != nil {
            self.s3ChunkSize = fileSize
            self.neededParts = 1
            self.lastPartSize = 0
        } else {
            self.s3ChunkSize = DracoonConstants.S3_CHUNK_SIZE < 1024*1024*5 ? 1024*1024*5 : Int64(DracoonConstants.S3_CHUNK_SIZE)
            self.neededParts = Int32(fileSize/self.s3ChunkSize)
            self.lastPartSize = fileSize%self.s3ChunkSize
        }
    }
    
    // MARK: Start S3 Upload
    
    public func start() {
        if self.properties.uploadSessionConfig?.identifier != nil,
           self.fileSize > DracoonConstants.S3_BACKGROUND_UPLOAD_MAX_SIZE {
            self.callOnError(DracoonError.exceeds_maximum_s3_upload_size(fileSize: self.fileSize, maximumSize: DracoonConstants.S3_BACKGROUND_UPLOAD_MAX_SIZE))
            return
        }
        self.createFileUpload(request: request, completion: { result in
            switch result {
            case .value(let response):
                self.s3Properties.setUploadId(response.uploadId)
                self.obtainUrls(completion: { urlResult in
                    switch urlResult {
                    case .error(let error):
                        self.callOnError(error)
                    case .value(let response):
                        self.s3Properties.addS3URLs(response.urls)
                        self.startUploadWithPresignedUrls()
                    }
                })
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
        if let uploadId = self.s3Properties.uploadId {
            self.deleteUpload(uploadId: uploadId, completion: { _ in
                self.properties.callback?.onCanceled?()
            })
        } else {
            self.properties.callback?.onCanceled?()
        }
    }
    
    func resumeBackgroundUpload() {
        self.properties.urlSessionTask?.resume()
    }
    
    private func obtainUrls(completion: @escaping DataRequest.DecodeCompletion<PresignedUrlList>) {
        let completedParts = Int32(self.s3Properties.eTags.count)
        let remainingParts = self.neededParts - completedParts
        guard remainingParts > 0 else {
            self.requestPresignedUrls(firstPartNumber: self.neededParts + 1, lastPartNumber: self.neededParts + 1, size: self.lastPartSize, completion: completion)
            return
        }
        let partsToFetch = remainingParts <= DracoonConstants.S3_MAX_URL_FETCH_COUNT ? remainingParts : DracoonConstants.S3_MAX_URL_FETCH_COUNT
        let lastPartNumber = completedParts + partsToFetch
        self.requestPresignedUrls(firstPartNumber: completedParts + 1, lastPartNumber: lastPartNumber, size: self.s3ChunkSize, completion: { urlResult in
            switch urlResult {
            case .error(let error):
                self.callOnError(error)
            case .value(let response):
                self.handlePresignedUrlsResponse(response: response, lastPartNumber: lastPartNumber, completion: completion)
            }
        })
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
    
    private func handlePresignedUrlsResponse(response: PresignedUrlList, lastPartNumber: Int32, completion: @escaping DataRequest.DecodeCompletion<PresignedUrlList>) {
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
    
    private func requestPresignedUrls(firstPartNumber: Int32, lastPartNumber: Int32, size: Int64, completion: @escaping DataRequest.DecodeCompletion<PresignedUrlList>) {
        print("request urls \(firstPartNumber)-\(lastPartNumber)")
        let request = GeneratePresignedUrlsRequest(size: size, firstPartNumber: firstPartNumber, lastPartNumber: lastPartNumber)
        
        do {
            let jsonBody = try encoder.encode(request)
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(self.s3Properties.uploadId ?? "")/s3_urls"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(PresignedUrlList.self, decoder: self.decoder, requestType: .other, completion: completion)
        } catch {
            self.callOnError(error)
        }
    }
    
    private func startUploadWithPresignedUrls() {
        guard let firstUrl = self.s3Properties.s3Urls.first, let uploadId = self.s3Properties.uploadId else {
            self.properties.callback?.onCanceled?()
            return
        }
        print("presignedUrl count \(self.s3Properties.s3Urls.count)")
        if let sessionConfig = self.properties.uploadSessionConfig,
           sessionConfig.identifier != nil {
            print("background s3 upload")
            self.uploadBackgroundToPresignedURL(firstUrl)
        } else {
            if let crypto = self.crypto {
                do {
                    let fileKey = try crypto.generateFileKey(version: PlainFileKeyVersion.AES256GCM)
                    let cipher = try crypto.createEncryptionCipher(fileKey: fileKey)
                    self.s3Properties.setCipher(cipher)
                } catch {
                    self.callOnError(DracoonError.encryption_cipher_failure)
                    return
                }
            }
            print("foreground s3 upload")
            self.createNextChunk(uploadId: uploadId, presignedUrl: firstUrl, cipher: self.s3Properties.cipher, completion: {
                self.completeS3Upload(uploadId: uploadId, cipher: self.s3Properties.cipher)
            })
        }
    }
    
    // MARK: Background S3 Upload
    
    private func uploadBackgroundToPresignedURL(_ presignedUrl: PresignedUrl) {
        var fileToUpload = self.fileUrl
        if let crypto = self.crypto {
            do {
                let result = try self.encryptFile(crypto: crypto, fileURL: self.fileUrl)
                self.s3Properties.setCipher(result.cipher)
                fileToUpload = result.url
            } catch {
                self.callOnError(error)
                return
            }
        }
        let uploadUrl = presignedUrl.url
        let sessionConfiguration: URLSessionConfiguration
        if let sessionConfig = self.properties.uploadSessionConfig {
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
            task.countOfBytesClientExpectsToSend = self.fileSize
        }
        self.properties.setSessionTask(task)
        task.resume()
    }
    
    // MARK: Foreground S3 Upload
    
    private func uploadForegroundToPresignedUrl(_ presignedUrl: PresignedUrl, chunk: Data, retryCount: Int, chunkCallback: @Sendable @escaping (Error?) -> Void) {
        let requestUrl = presignedUrl.url
        
        var urlRequest = URLRequest(url: URL(string: requestUrl)!)
        urlRequest.httpMethod = HTTPMethod.put.rawValue
        
        var headers = HTTPHeaders()
        headers[ApiRequestConstants.headerFields.keys.contentType] = "application/octet-stream"
        
        let request = self.session.upload(chunk, to: requestUrl, method: .put, headers: headers)
        
        request.uploadProgress(closure: { progress in
            let recentChunkProgress = Float(progress.fractionCompleted)*Float(chunk.count)
            let overallProgress = recentChunkProgress + Float(Int(self.s3ChunkSize)*(Int(presignedUrl.partNumber) - 1))
            if (self.fileSize > 0) {
                self.properties.callback?.onProgress?(overallProgress/Float(self.fileSize))
            }
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
                    self.s3Properties.addETags([uploadPart])
                    chunkCallback(nil)
                    return
                }
                let errorModel = DracoonSDKErrorModel(errorCode: .UNKNOWN, httpStatusCode: dataResponse.response?.statusCode)
                self.handleUploadError(error: DracoonError.api(error: errorModel), url: presignedUrl, chunk: chunk, retryCount: retryCount, chunkCallback: chunkCallback)
            }
        })
    }
    
    private func createNextChunk(uploadId: String, presignedUrl: PresignedUrl, cipher: EncryptionCipher?, completion: @Sendable @escaping () -> Void) {
        if self.properties.isUploadCancelled() {
            return
        }
        let offset: Int = Int(presignedUrl.partNumber - 1) * Int(self.s3ChunkSize)
        let range = NSMakeRange(offset, Int(self.s3ChunkSize))
        let lastBlock = self.isLastBlock(presignedUrl: presignedUrl)
        
        do {
            guard let data = try FileUtils.readData(self.fileUrl, range: range) else {
                self.callOnError(DracoonError.read_data_failure(at: self.fileUrl))
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
                    self.callOnError(error)
                    return
                }
            } else {
                uploadData = data
            }
            self.startForegroundUploadForChunkAndProceed(data: uploadData, presignedUrl: presignedUrl, uploadId: uploadId, cipher: cipher, isLastBlock: lastBlock, completion: completion)
        } catch {
            self.callOnError(DracoonError.read_data_failure(at: self.fileUrl))
        }
    }
    
    private func startForegroundUploadForChunkAndProceed(data: Data, presignedUrl: PresignedUrl, uploadId: String, cipher: EncryptionCipher?, isLastBlock: Bool, completion: @Sendable @escaping () -> Void) {
        self.uploadForegroundToPresignedUrl(presignedUrl, chunk: data, retryCount: 0, chunkCallback: { error in
            if let error = error {
                self.callOnError(error)
                return
            }
            if isLastBlock {
                completion()
            }
            else {
                if self.s3Properties.s3Urls.count >= presignedUrl.partNumber + 1 {
                    let nextUrl = self.s3Properties.s3Urls[Int(presignedUrl.partNumber)]
                    self.createNextChunk(uploadId: uploadId, presignedUrl: nextUrl, cipher: cipher, completion: completion)
                } else {
                    self.createMoreUrlsAndProceed(uploadId: uploadId, cipher: cipher, completion: completion)
                }
            }
        })
    }
    
    private func createMoreUrlsAndProceed(uploadId: String, cipher: EncryptionCipher?, completion: @Sendable @escaping () -> Void) {
        self.obtainUrls(completion: { result in
            switch result {
            case .error(let error):
                self.callOnError(error)
            case .value(let response):
                self.s3Properties.addS3URLs(response.urls)
                let nextUrl = response.urls.first!
                self.createNextChunk(uploadId: uploadId, presignedUrl: nextUrl, cipher: cipher, completion: completion)
            }
        })
    }
    
    private func handleUploadError(error: Error, url: PresignedUrl, chunk: Data, retryCount: Int, chunkCallback: @Sendable @escaping (Error?) -> Void) {
        if retryCount < DracoonConstants.S3_UPLOAD_MAX_RETRIES {
            self.uploadForegroundToPresignedUrl(url, chunk: chunk, retryCount: retryCount + 1, chunkCallback: chunkCallback)
        } else {
            self.callOnError(DracoonError.generic(error: error))
        }
    }
    
    private func isLastBlock(presignedUrl: PresignedUrl) -> Bool {
        if self.lastPartSize > 0 {
            return presignedUrl.partNumber == self.neededParts + 1
        }
        return presignedUrl.partNumber == self.neededParts
    }
    
    // MARK: Complete S3 Upload
    
    private func completeS3Upload(uploadId: String, cipher: EncryptionCipher?) {
        if let crypto = self.crypto {
            guard let cipher = cipher else {
                self.callOnError(DracoonError.encryption_cipher_failure)
                return
            }
            self.account.getUserKeyPair(completion: { result in
                switch result {
                case .error(let error):
                    self.callOnError(error)
                    return
                case .value(let userKeyPair):
                    do {
                        let publicKey = UserPublicKey(publicKey: userKeyPair.publicKeyContainer.publicKey, version: userKeyPair.publicKeyContainer.version)
                        let encryptedFileKey = try crypto.encryptFileKey(fileKey: cipher.fileKey, publicKey: publicKey)
                        self.completeUpload(uploadId: uploadId, encryptedFileKey: encryptedFileKey)
                    } catch CryptoError.encrypt(let message){
                        self.callOnError(DracoonError.filekey_encryption_failure(description: message))
                    } catch {
                        self.callOnError(DracoonError.generic(error: error))
                    }
                }
            })
        } else {
            self.completeUpload(uploadId: uploadId, encryptedFileKey: nil)
        }
    }
    
    private func completeUpload(uploadId: String, encryptedFileKey: EncryptedFileKey?) {
        let completeRequest = CompleteS3FileUploadRequest(parts: self.s3Properties.eTags, resolutionStrategy: self.resolutionStrategy, keepShareLinks: false, fileName: self.request.name, fileKey: encryptedFileKey)
        self.sendCompleteRequest(uploadId: uploadId, request: completeRequest, completion: { response in
            if let error = response.error {
                self.callOnError(error)
            } else {
                self.pollForStatus(uploadId: uploadId, waitTimeSec: 1)
            }
        })
    }
    
    private func sendCompleteRequest(uploadId: String, request: CompleteS3FileUploadRequest, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
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
    
    private func pollForStatus(uploadId: String, waitTimeSec: Int) {
        self.getS3UploadStatus(uploadId: uploadId, completion: { result in
            switch result {
            case .error(let error):
                self.callOnError(error)
            case .value(let response):
                self.handleUploadStatusResponse(response: response, uploadId: uploadId, waitTimeSec: waitTimeSec)
            }
        })
    }
    
    private func handleUploadStatusResponse(response: S3FileUploadStatus, uploadId: String, waitTimeSec: Int) {
        if response.status == S3FileUploadStatus.S3UploadStatus.done.rawValue {
            if let responseNode = response.node {
                self.properties.callback?.onComplete?(responseNode)
            } else {
                let errorModel = DracoonSDKErrorModel(errorCode: .SERVER_NODE_NOT_FOUND, httpStatusCode: nil)
                self.callOnError(DracoonError.api(error: errorModel))
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
    
    private func handleUploadStatusErrorResponse(response: S3FileUploadStatus) {
        if let error = response.errorDetails {
            let code = DracoonErrorParser.shared.parseApiErrorResponse(error, requestType: .other)
            let errorModel = DracoonSDKErrorModel(errorCode: code, httpStatusCode: error.code)
            self.callOnError(DracoonError.api(error: errorModel))
        } else {
            let errorModel = DracoonSDKErrorModel(errorCode: .S3_UPLOAD_COMPLETION_FAILED, httpStatusCode: nil)
            self.callOnError(DracoonError.api(error: errorModel))
        }
    }
    
    private func getS3UploadStatus(uploadId: String, completion: @escaping DataRequest.DecodeCompletion<S3FileUploadStatus>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(uploadId)"
        
        self.session.request(requestUrl, method: .get, parameters: nil)
            .validate()
            .decode(S3FileUploadStatus.self, decoder: self.decoder, requestType: .other, completion: completion)
    }
    
    
    
    private func deleteUpload(uploadId: String, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads/\(uploadId)"
        
        self.session.request(requestUrl, method: .delete, parameters: Parameters())
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
    
    // MARK: URLSessionDataDelegate
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.handleUploadCompletion(session, task: task, didCompleteWithError: error)
    }
    
    private func handleUploadCompletion(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let presignedUrl = self.s3Properties.s3Urls.first,
              let uploadId = self.s3Properties.uploadId else {
            self.properties.callback?.onCanceled?()
            return
        }
        if let uploadError = error {
            self.callOnError(DracoonError.generic(error: uploadError))
        } else {
            if let httpURLResponse = task.response as? HTTPURLResponse, httpURLResponse.statusCode < 300 {
                let headerFields = httpURLResponse.allHeaderFields
                if let result = headerFields.keys.first(where: { ($0 as? String)?.caseInsensitiveCompare("eTag") == .orderedSame}) as? String,
                   let eTag = headerFields[result] as? String {
                    let cleanEtag = eTag.replacingOccurrences(of: "\"", with: "")
                    let uploadPart = S3FileUploadPart(partNumber: presignedUrl.partNumber, partEtag: cleanEtag)
                    self.s3Properties.addETags([uploadPart])
                    self.completeS3Upload(uploadId: uploadId, cipher: self.s3Properties.cipher)
                    return
                }
            }
            let errorModel = DracoonSDKErrorModel(errorCode: .UNKNOWN, httpStatusCode: (task.response as? HTTPURLResponse)?.statusCode)
            self.callOnError(DracoonError.api(error: errorModel))
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        self.handleUploadProgress(totalBytesSent: totalBytesSent)
    }
    
    private func handleUploadProgress(totalBytesSent: Int64) {
        if self.fileSize > 0 {
            let fractionCompleted = Float(totalBytesSent)/Float(self.fileSize)
            self.properties.callback?.onProgress?(fractionCompleted)
        }
    }
    
    private func callOnError(_ error: Error) {
        self.properties.callback?.onError?(error)
    }
}
