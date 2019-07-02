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
                // TODO obtain urls, upload
                //self.uploadChunks(uploadId: response.uploadId)
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
    
    fileprivate func obtainUrls() {
        // TODO chunkSize from Constants or 5 MB
        let fileSize = self.calculateFileSize(filePath: self.filePath)
        //GeneratePresignedUrlsRequest
    }
    
    
}
