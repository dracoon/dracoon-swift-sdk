//
//  FileDownload.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

public class FileDownload {
    
    let sessionManager: Alamofire.SessionManager
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthTokenManager
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    let account: DracoonAccount
    let crypto: Crypto
    let getEncryptionPassword: () -> String?
    
    let nodeId: Int64
    let targetUrl: URL
    
    var callback: DownloadCallback?
    var fileKey: EncryptedFileKey?
    var downloadRequest: DownloadRequest?
    
    init(nodeId: Int64, targetUrl: URL, config: DracoonRequestConfig, account: DracoonAccount, crypto: Crypto, fileKey: EncryptedFileKey?, getEncryptionPassword: @escaping () -> String?) {
        self.sessionManager = config.sessionManager
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.oAuthTokenManager = config.oauthTokenManager
        self.encoder = config.encoder
        self.decoder = config.decoder
        self.account = account
        self.crypto = crypto
        self.getEncryptionPassword = getEncryptionPassword
        
        self.nodeId = nodeId
        self.targetUrl = targetUrl
        
        self.fileKey = fileKey
    }
    
    public func start() {
        self.download()
    }
    
    public func cancel() {
        guard let downloadRequest = self.downloadRequest else {
            return
        }
        downloadRequest.cancel()
        self.downloadRequest = nil
        self.callback?.onCanceled?()
    }
    
    fileprivate func getDownloadToken(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<DownloadTokenGenerateResponse>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/" + String(nodeId) + "/downloads"
        
        var urlRequest = URLRequest(url: URL(string: requestUrl)!)
        urlRequest.httpMethod = "Post"
        
        self.sessionManager.request(urlRequest)
            .validate()
            .decode(DownloadTokenGenerateResponse.self, decoder: self.decoder, completion: completion)
        
    }
    
    fileprivate func download() {
        getDownloadToken(nodeId: self.nodeId, completion: { result in
            switch result {
            case .value(let tokenResponse):
                if let downloadUrl = tokenResponse.downloadUrl {
                    self.downloadRequest = self.sessionManager.download(downloadUrl, to: { _, _ in
                        return (self.targetUrl, [.removePreviousFile, .createIntermediateDirectories])
                    })
                        .downloadProgress(closure: { (progress) in
                            self.callback?.onProgress?(Float(progress.fractionCompleted))
                        })
                        .response(completionHandler: { downloadResponse in
                            if let error = downloadResponse.error {
                                self.callback?.onError?(error)
                            } else {
                                if let fileKey = self.fileKey {
                                    self.decryptDownloadedFile(fileKey: fileKey)
                                } else {
                                    self.callback?.onComplete?(downloadResponse.destinationURL!)
                                }
                            }
                        })
                } else {
                    self.downloadToken(token: tokenResponse.token)
                }
                break
            case .error(let error):
                self.callback?.onError?(error)
            }
        })
    }
    
    fileprivate func downloadToken(token: String) {
        
        let requestUrl = serverUrl.absoluteString + apiPath + "/downloads/" + token
        
        
        var urlRequest = URLRequest(url: URL(string: requestUrl)!)
        urlRequest.httpMethod = "Get"
        
        self.downloadRequest = self.sessionManager.download(urlRequest, to: { _, _ in
            return (self.targetUrl, [.removePreviousFile, .createIntermediateDirectories])
        })
            .downloadProgress(closure: { (progress) in
                self.callback?.onProgress?(Float(progress.fractionCompleted))
            })
            .response(completionHandler: { downloadResponse in
                if let error = downloadResponse.error {
                    self.callback?.onError?(error)
                } else {
                    if let fileKey = self.fileKey {
                        self.decryptDownloadedFile(fileKey: fileKey)
                    } else {
                        self.callback?.onComplete?(downloadResponse.destinationURL!)
                    }
                }
            })
        
    }
    
    fileprivate func decryptDownloadedFile(fileKey: EncryptedFileKey) {
        guard let encryptionPassword = self.getEncryptionPassword() else {
            self.callback?.onError?(DracoonError.no_encryption_password)
            return
        }
        self.account.checkUserKeyPairPassword(password: encryptionPassword, completion: { result in
            
            switch result {
            case .error(let error):
                self.callback?.onError?(error)
            case .value(let userKeyPair):
                do {
                    let privateKey = UserPrivateKey(privateKey: userKeyPair.privateKeyContainer.privateKey, version: userKeyPair.privateKeyContainer.version)
                    let plainFileKey = try self.crypto.decryptFileKey(fileKey: fileKey, privateKey: privateKey, password: encryptionPassword)
                    try self.decryptFile(fileKey: plainFileKey, fileUrl: self.targetUrl)
                    self.callback?.onComplete?(self.targetUrl)
                } catch {
                    self.callback?.onError?(error)
                }
            }
        })
    }
    
    fileprivate func decryptFile(fileKey: PlainFileKey, fileUrl: URL) throws {
        let encryptedData = try Data(contentsOf: fileUrl)
        let decryptionCipher = try self.crypto.createDecryptionCipher(fileKey: fileKey)
        let inputStream = InputStream(data: encryptedData)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: DracoonConstants.DECRYPTION_BUFFER_SIZE)
        inputStream.open()
        
        var offset = 0
        var range = NSMakeRange(offset, DracoonConstants.DECRYPTION_BUFFER_SIZE)
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFilePath = tempPath.appendingPathComponent(String(encryptedData.hashValue))
        guard let outputStream = OutputStream(toFileAtPath: tempFilePath.path, append: false) else {
            self.callback?.onError?(DracoonError.file_decryption_error(nodeId: self.nodeId))
            return
        }
        outputStream.open()
        
        defer {
            buffer.deallocate()
            inputStream.close()
            outputStream.close()
        }
        
        try autoreleasepool {
            while inputStream.hasBytesAvailable {
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
        
        try FileManager.default.removeItem(at: fileUrl)
        try FileManager.default.moveItem(at: tempFilePath, to: fileUrl)
    }
}
