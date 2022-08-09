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

public class FileUpload: NSObject, DracoonUpload, URLSessionDataDelegate {
    
    let session: Alamofire.Session
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthInterceptor
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    let account: DracoonAccount
    var request: CreateFileUploadRequest
    let resolutionStrategy: CompleteUploadRequest.ResolutionStrategy
    var fileUrl: URL
    
    var uploadSessionConfig: URLSessionConfiguration?
    var urlSessionTask: URLSessionTask?
    var encryptedFileKey: EncryptedFileKey?
    var callback: UploadCallback?
    let crypto: CryptoProtocol?
    var isCanceled = false
    var uploadUrl: String?
    
    var fileSize: Int64 = 0
    var readData: Int = 0
    
    init(config: DracoonRequestConfig, request: CreateFileUploadRequest, fileUrl: URL, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy, crypto: CryptoProtocol?,
         sessionConfig: URLSessionConfiguration?, account: DracoonAccount) {
        self.request = request
        self.session = config.session
        self.uploadSessionConfig = sessionConfig
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
        self.urlSessionTask?.cancel()
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
            var createRequest = request
            if let fileSize = FileUtils.calculateFileSize(filePath: self.fileUrl), fileSize > 0 {
                self.fileSize = fileSize
                createRequest.size = fileSize
            }
            let jsonBody = try encoder.encode(createRequest)
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/uploads"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(CreateFileUploadResponse.self, decoder: self.decoder, requestType: .createUpload, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func startChunkedUpload(uploadUrl: String, encryptedFileKey: EncryptedFileKey? = nil) {
        let sessionConfiguration: URLSessionConfiguration
        if let sessionConfig = self.uploadSessionConfig {
            sessionConfiguration = sessionConfig
        } else {
            sessionConfiguration = self.session.sessionConfiguration
        }
        let urlSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        var urlRequest = URLRequest(url: URL(string: uploadUrl)!)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        let task = urlSession.uploadTask(with: urlRequest, fromFile: self.fileUrl)
        if self.fileSize > 0 {
            task.countOfBytesClientExpectsToSend = fileSize
        }
        self.urlSessionTask = task
        task.resume()
    }
    
    func startEncryptedChunkedUpload(uploadUrl: String) {
        do {
            let result = try self.encryptFile()
            self.encryptFileKey(cipher: result.cipher, completion: { response in
                switch response {
                case .error(let error):
                    self.callback?.onError?(error)
                case .value(let fileKey):
                    self.encryptedFileKey = fileKey
                    self.fileUrl = result.url
                    self.startChunkedUpload(uploadUrl: uploadUrl, encryptedFileKey: fileKey)
                }
            })
        } catch {
            self.callback?.onError?(error)
        }
    }
    
    func encryptFile() throws -> (url: URL, cipher: EncryptionCipher) {
        var cipher: EncryptionCipher
        if let crypto = self.crypto {
            do {
                let fileKey = try crypto.generateFileKey(version: PlainFileKeyVersion.AES256GCM)
                cipher = try crypto.createEncryptionCipher(fileKey: fileKey)
            } catch {
                throw DracoonError.encryption_cipher_failure
            }
            guard let inputStream = InputStream(url: self.fileUrl) else {
                throw DracoonError.read_data_failure(at: self.fileUrl)
            }
            let bufferSize = DracoonConstants.ENCRYPTION_BUFFER_SIZE
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            
            let outputUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(self.fileUrl.lastPathComponent)
            FileManager.default.createFile(atPath: outputUrl.path, contents: nil, attributes: nil)
            guard let outputStream = OutputStream(toFileAtPath: outputUrl.path, append: true) else {
                throw DracoonError.write_data_failure(at: outputUrl)
            }
            inputStream.open()
            outputStream.open()
            defer {
                inputStream.close()
                outputStream.close()
                buffer.deallocate()
            }
            while inputStream.hasBytesAvailable {
                let read = inputStream.read(buffer, maxLength: bufferSize)
                if read > 0 {
                    let plainData = Data(bytes: buffer, count: read)
                    let encryptedData = try cipher.processBlock(fileData: plainData)
                    _ = outputStream.write(data: encryptedData)
                } else if let error = inputStream.streamError {
                    throw error
                }
                
            }
            try cipher.doFinal()
            
            return (outputUrl, cipher)
        } else {
            throw DracoonError.encryption_cipher_failure
        }
    }
    
    private func encryptFileKey(cipher: EncryptionCipher, completion: @escaping (Dracoon.Result<EncryptedFileKey>) -> Void) {
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
    
    func completeUpload(uploadUrl: String, encryptedFileKey: EncryptedFileKey?) {
        var completeRequest = CompleteUploadRequest()
        completeRequest.fileName = self.request.name
        completeRequest.resolutionStrategy = self.resolutionStrategy
        completeRequest.fileKey = encryptedFileKey
        
        self.sendCompleteRequest(uploadUrl: uploadUrl, request: completeRequest, session: self.session, completion: { result in
            switch result {
            case .value(let node):
                self.callback?.onComplete?(node)
            case .error(let error):
                self.callback?.onError?(error)
            }
        })
    }
    
    func resumeBackgroundUpload() {
        self.urlSessionTask?.resume()
    }
    
    fileprivate func sendCompleteRequest(uploadUrl: String, request: CompleteUploadRequest, session: Session, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        do {
            let jsonBody = try encoder.encode(request)
            var urlRequest = URLRequest(url: URL(string: uploadUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            session.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func deleteUpload(uploadUrl: String, completion: @escaping (Dracoon.Response) -> Void) {
        self.session.request(uploadUrl, method: .delete, parameters: Parameters())
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
    
    // MARK: URLSessionDataDelegate
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.handleUploadCompletion(session, task: task, didCompleteWithError: error)
    }
    
    func handleUploadCompletion(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            self.callback?.onError?(DracoonError.generic(error: error))
        } else if let response = task.response as? HTTPURLResponse, response.statusCode >= 400 {
            self.callback?.onError?(DracoonError.upload_failed(statusCode: response.statusCode))
        } else {
            self.completeUpload(uploadUrl: self.uploadUrl!, encryptedFileKey: self.encryptedFileKey)
        }
        if session.configuration.identifier != nil {
            session.finishTasksAndInvalidate()
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        self.handleUploadProgress(totalBytesSent: totalBytesSent)
    }
    
    func handleUploadProgress(totalBytesSent: Int64) {
        let fractionCompleted = Float(totalBytesSent)/Float(self.fileSize)
        self.callback?.onProgress?(fractionCompleted)
    }
}
