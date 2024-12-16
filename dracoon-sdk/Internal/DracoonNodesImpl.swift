//
//  DracoonNodesImpl.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

final class DracoonNodesImpl: DracoonNodes, Sendable {
    
    let requestConfig: DracoonRequestConfig
    let session: Alamofire.Session
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthInterceptor
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    let crypto: CryptoProtocol
    let account: DracoonAccount
    let config: DracoonConfig
    let getEncryptionPassword: @Sendable () -> String?
    let transferStorage: DracoonTransferStorage
    
    init(requestConfig: DracoonRequestConfig, crypto: CryptoProtocol, account: DracoonAccount, config: DracoonConfig, getEncryptionPassword: @Sendable @escaping () -> String?) {
        self.requestConfig = requestConfig
        self.session = requestConfig.session
        self.serverUrl = requestConfig.serverUrl
        self.apiPath = requestConfig.apiPath
        self.oAuthTokenManager = requestConfig.oauthTokenManager
        self.decoder = requestConfig.decoder
        self.encoder = requestConfig.encoder
        self.crypto = crypto
        self.account = account
        self.config = config
        self.getEncryptionPassword = getEncryptionPassword
        self.transferStorage = DracoonTransferStorage()
    }
    
    func getNodes(parentNodeId: Int64, limit: Int64?, offset: Int64?, completion: @Sendable @escaping (Dracoon.Result<NodeList>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes"
        
        var parameters: Parameters = [
            "depth_level": 0,
            "parent_id": parentNodeId
        ]
        
        if let limit = limit {
            parameters["limit"] = limit
        }
        
        if let offset = offset {
            parameters["offset"] = offset
        }
        
        self.session.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(NodeList.self, decoder: self.decoder, requestType: .getNodes, completion: completion)
        
    }
    
    func getNode(nodeId: Int64, completion: @Sendable @escaping (Dracoon.Result<Node>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/\(String(nodeId))"
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(Node.self, decoder: self.decoder, requestType: .getNodes, completion: completion)
    }
    
    func getNode(nodePath: String, completion: @Sendable @escaping (Dracoon.Result<Node>) -> Void) {
        
        let nodeComponents = nodePath.split(separator: "/")
        
        guard nodeComponents.count > 0 else {
            completion(Dracoon.Result.error(DracoonError.node_path_invalid(path: nodePath)))
            return
        }
        
        guard let range = nodePath.range(of: "/", options: String.CompareOptions.backwards, range: nil, locale: nil) else {
            completion(Dracoon.Result.error(DracoonError.path_range_invalid))
            return
        }
        let parentPath = String(nodePath[..<range.lowerBound])
        let requestUrl = serverUrl.absoluteString + apiPath + ApiRequestConstants.apiPaths.nodesSearch
        
        let parameters: Parameters = [
            "search_string": String(nodeComponents.last!),
            "depth_level": nodeComponents.count
        ]
        
        self.session.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(NodeList.self, decoder: self.decoder, requestType: .getNodes, completion: { result in
                switch result {
                case .value(let nodes):
                    var searchedNode: Node?
                    for node in nodes.items {
                        if node.parentPath == parentPath {
                            searchedNode = node
                            break
                        }
                    }
                    if let resultNode = searchedNode {
                        completion(Dracoon.Result.value(resultNode))
                    } else {
                        completion(Dracoon.Result.error(DracoonError.node_not_found(path: nodePath)))
                    }
                    
                case .error(let error):
                    completion(Dracoon.Result.error(error))
                }
            })
    }
    
    func isNodeEncrypted(nodeId: Int64, completion: @Sendable @escaping (Dracoon.Result<Bool>) -> Void) {
        self.getNode(nodeId: nodeId, completion: { result in
            switch result {
            case .value(let node):
                completion(Dracoon.Result.value(node.isEncrypted ?? false))
            case .error(let error):
                completion(Dracoon.Result.error(error))
            }
        })
    }
    
    // MARK: File Operations
    
    func createRoom(request: CreateRoomRequest, completion: @Sendable @escaping (Dracoon.Result<Node>) -> Void) {
        
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/rooms"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .createRoom, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func updateRoom(roomId: Int64, request: UpdateRoomRequest, completion: @Sendable @escaping (Dracoon.Result<Node>) -> Void) {
        
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/rooms/\(String(roomId))"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .updateRoom, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func updateRoomConfig(roomId: Int64, request: ConfigRoomRequest, completion: @Sendable @escaping (Dracoon.Result<Node>) -> Void) {
        
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/rooms/\(String(roomId))/config"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .updateRoom, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func createFolder(request: CreateFolderRequest, completion: @Sendable @escaping (Dracoon.Result<Node>) -> Void) {
        
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/folders"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .createFolder, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func updateFolder(folderId: Int64, request: UpdateFolderRequest, completion: @Sendable @escaping (Dracoon.Result<Node>) -> Void) {
        
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/folders/\(String(folderId))"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .updateFolder, completion: completion)
            
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func updateFile(fileId: Int64, request: UpdateFileRequest, completion: @Sendable @escaping (Dracoon.Result<Node>) -> Void) {
        
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/\(String(fileId))"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .updateFile, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func deleteNodes(request: DeleteNodesRequest, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.delete.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .handleResponse(decoder: self.decoder, completion: completion)
            
        } catch {
            completion(Dracoon.Response(error: DracoonError.encode(error: error)))
        }
    }
    
    func copyNodes(nodeId: Int64, request: CopyNodesRequest, completion: @Sendable @escaping (Dracoon.Result<Node>) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/\(String(nodeId))/copy_to"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .copyNodes, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func moveNodes(nodeId: Int64, request: MoveNodesRequest, completion: @Sendable @escaping (Dracoon.Result<Node>) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/\(String(nodeId))/move_to"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .moveNodes, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    // MARK: Upload file
    
    func uploadFile(uploadId: String, request: CreateFileUploadRequest, fileUrl: URL, callback: UploadCallback, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy = CompleteUploadRequest.ResolutionStrategy.autorename, sessionConfig: URLSessionConfiguration?) {
        
        guard ValidatorUtils.pathExists(at: fileUrl.path) else {
            callback.onError?(DracoonError.file_does_not_exist(at: fileUrl))
            return
        }
        
        self.isNodeEncrypted(nodeId: request.parentId, completion: { result in
            
            switch result {
            case .error(let error):
                callback.onError?(error)
            case .value(let isEncrypted):
                var cryptoImpl: CryptoProtocol?
                if isEncrypted {
                    cryptoImpl = self.crypto
                }
                
                self.checkForS3AndStartUpload(uploadId: uploadId, request: request, fileUrl: fileUrl, callback: callback, resolutionStrategy: resolutionStrategy, cryptoImpl: cryptoImpl, sessionConfig: sessionConfig)
            }
        })
    }
    
    private func checkForS3AndStartUpload(uploadId: String, request: CreateFileUploadRequest, fileUrl: URL, callback: UploadCallback,
                                          resolutionStrategy: CompleteUploadRequest.ResolutionStrategy, cryptoImpl: CryptoProtocol?, sessionConfig: URLSessionConfiguration?) {
        self.isS3Upload(onComplete: { result in
            switch result {
            case .error(_):
                self.startUpload(uploadId: uploadId, request: request, filePath: fileUrl, callback: callback, resolutionStrategy: resolutionStrategy, cryptoImpl: cryptoImpl, sessionConfig: sessionConfig)
            case .value(let isS3Upload):
                if isS3Upload {
                    self.startS3Upload(uploadId: uploadId, request: request, fileUrl: fileUrl, callback: callback, resolutionStrategy: resolutionStrategy, cryptoImpl: cryptoImpl, sessionConfig: sessionConfig)
                } else {
                    self.startUpload(uploadId: uploadId, request: request, filePath: fileUrl, callback: callback, resolutionStrategy: resolutionStrategy, cryptoImpl: cryptoImpl, sessionConfig: sessionConfig)
                }
            }
        })
    }
    
    private func startUpload(uploadId: String, request: CreateFileUploadRequest, filePath: URL, callback: UploadCallback,
                             resolutionStrategy: CompleteUploadRequest.ResolutionStrategy, cryptoImpl: CryptoProtocol?, sessionConfig: URLSessionConfiguration?) {
        let upload = FileUpload(config: self.requestConfig, request: request, fileUrl: filePath, resolutionStrategy: resolutionStrategy,
                                crypto: cryptoImpl, sessionConfig: sessionConfig, account: self.account)
        
        let innerCallback = UploadCallback()
        innerCallback.onCanceled = callback.onCanceled
        innerCallback.onComplete = { node in
            if cryptoImpl != nil {
                self.setMissingFileKeysBatch(nodeId: node._id, offset: 0, limit: DracoonConstants.MISSING_FILEKEYS_MAX_COUNT, completion: { _ in
                    // Don't wait for file key creation
                })
            }
            callback.onComplete?(node)
            self.transferStorage.removeUpload(uploadId: uploadId)
        }
        innerCallback.onError = callback.onError
        innerCallback.onProgress = callback.onProgress
        
        upload.callback = innerCallback
        
        self.transferStorage.storeUpload(uploadId: uploadId, upload: upload)
        upload.start()
    }
    
    private func startS3Upload(uploadId: String, request: CreateFileUploadRequest, fileUrl: URL, callback: UploadCallback,
                               resolutionStrategy: CompleteUploadRequest.ResolutionStrategy, cryptoImpl: CryptoProtocol?, sessionConfig: URLSessionConfiguration?) {
        let s3upload = S3FileUpload(config: self.requestConfig, request: request, fileUrl: fileUrl, resolutionStrategy: resolutionStrategy,
                                    crypto: cryptoImpl, sessionConfig: sessionConfig, account: self.account)
        
        let innerCallback = UploadCallback()
        innerCallback.onCanceled = callback.onCanceled
        innerCallback.onComplete = { node in
            if cryptoImpl != nil {
                self.setMissingFileKeysBatch(nodeId: node._id, offset: 0, limit: DracoonConstants.MISSING_FILEKEYS_MAX_COUNT, completion: { _ in
                    // Don't wait for file key creation
                })
            }
            callback.onComplete?(node)
            self.transferStorage.removeUpload(uploadId: uploadId)
        }
        innerCallback.onError = callback.onError
        innerCallback.onProgress = callback.onProgress
        
        s3upload.callback = innerCallback
        
        self.transferStorage.storeUpload(uploadId: uploadId, upload: s3upload)
        s3upload.start()
    }
    
    private func isS3Upload(onComplete: @Sendable @escaping (Dracoon.Result<Bool>) -> Void) {
        self.config.getGeneralSettings(completion: { result in
            switch result {
            case .error(let error):
                onComplete(Dracoon.Result.error(error))
            case .value(let settings):
                if settings.useS3Storage ?? false {
                    self.config.getInfrastructureProperties(completion: { propertyResult in
                        switch propertyResult {
                        case .error(let error):
                            onComplete(Dracoon.Result.error(error))
                        case .value(let properties):
                            onComplete(Dracoon.Result.value(properties.s3EnforceDirectUpload ?? false))
                        }
                    })
                } else {
                    onComplete(Dracoon.Result.value(false))
                }
            }
        })
    }
    
    func cancelUpload(uploadId: String) {
        self.transferStorage.getUpload(uploadId: uploadId, completionHandler: { [weak self] upload in
            if let upload = upload {
                upload.cancel()
                self?.transferStorage.removeUpload(uploadId: uploadId)
            }
        })
    }
    
    func createFileUpload(request: CreateFileUploadRequest, fileSize: Int64, completion: @escaping DataRequest.DecodeCompletion<CreateFileUploadResponse>) {
        do {
            var createRequest = request
            createRequest.size = fileSize
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
    
    func completeFileUpload(request: CompleteUploadRequest, uploadUrl: URL, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        do {
            let jsonBody = try encoder.encode(request)
            var urlRequest = URLRequest(url: uploadUrl)
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
    
    // MARK: Download file
    
    func downloadFile(nodeId: Int64, targetUrl: URL, callback: DownloadCallback, sessionConfig: URLSessionConfiguration?) {
        guard targetUrl.isFileURL else {
            callback.onError?(DracoonError.url_invalid(url: targetUrl))
            return
        }
        self.isNodeEncrypted(nodeId: nodeId, completion: { result in
            switch result {
            case .error(let error):
                callback.onError?(error)
            case .value(let isEncrypted):
                if isEncrypted {
                    self.getFileKey(nodeId: nodeId, completion: { result in
                        switch result {
                        case .error(let error):
                            callback.onError?(error)
                            return
                        case .value(let encryptedFileKey):
                            self.startFileDownload(nodeId: nodeId, targetUrl: targetUrl, callback: callback, fileKey: encryptedFileKey, sessionConfig: sessionConfig)
                        }
                    })
                } else {
                    self.startFileDownload(nodeId: nodeId, targetUrl: targetUrl, callback: callback, fileKey: nil, sessionConfig: sessionConfig)
                }
            }
        })
    }
    
    fileprivate func startFileDownload(nodeId: Int64, targetUrl: URL, callback: DownloadCallback, fileKey: EncryptedFileKey?, sessionConfig: URLSessionConfiguration?) {
        
        let download = FileDownload(nodeId: nodeId, targetUrl: targetUrl, config: self.requestConfig, account: self.account, nodes: self,
                                    crypto: self.crypto, fileKey: fileKey, sessionConfig: sessionConfig, getEncryptionPassword: self.getEncryptionPassword)
        
        let innerCallback = DownloadCallback()
        innerCallback.onCanceled = callback.onCanceled
        innerCallback.onComplete = { url in
            self.transferStorage.removeDownload(nodeId: nodeId)
            callback.onComplete?(url)
        }
        innerCallback.onError = callback.onError
        innerCallback.onProgress = callback.onProgress
        
        download.callback = innerCallback
        self.transferStorage.storeDownload(nodeId: nodeId, download: download)
        download.start()
    }
    
    func cancelDownload(nodeId: Int64) {
        self.transferStorage.getDownload(nodeId: nodeId, completionHandler: { [weak self] download in
            if let download = download {
                download.cancel()
                self?.transferStorage.removeDownload(nodeId: nodeId)
            }
        })
    }
    
    func resumeBackgroundTasks() {
        self.transferStorage.resumeDownloads()
        self.transferStorage.resumeUploads()
    }
    
    // MARK: Search
    
    func searchNodes(parentNodeId: Int64, searchString: String, offset: Int64?, limit: Int64?, completion: @Sendable @escaping (Dracoon.Result<NodeList>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + ApiRequestConstants.apiPaths.nodesSearch
        
        var parameters: Parameters = [
            "search_string": searchString,
            "parent_id": parentNodeId
        ]
        if let limit = limit {
            parameters["limit"] = limit
        }
        if let offset = offset {
            parameters["offset"] = offset
        }
        
        parameters["search_string"] = searchString
        
        self.session.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(NodeList.self, decoder: self.decoder, requestType: .searchNodes, completion: completion)
        
    }
    
    func searchNodes(parentNodeId: Int64, searchString: String, depthLevel: Int?, filter: String?, sorting: String?, offset: Int64?, limit: Int64?, completion: @Sendable @escaping (Dracoon.Result<NodeList>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + ApiRequestConstants.apiPaths.nodesSearch
        
        var parameters: Parameters = [
            "search_string": searchString,
            "parent_id": parentNodeId
        ]
        if let limit = limit {
            parameters["limit"] = limit
        }
        if let offset = offset {
            parameters["offset"] = offset
        }
        if let depthLevel = depthLevel {
            parameters["depth_level"] = depthLevel
        }
        if let filter = filter {
            parameters["filter"] = filter
        }
        if let sorting = sorting {
            parameters["sort"] = sorting
        }
        
        self.session.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(NodeList.self, decoder: self.decoder, requestType: .searchNodes, completion: completion)
    }
    
    // MARK: Favorites
    
    func getFavorites(completion: @Sendable @escaping (Dracoon.Result<NodeList>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + ApiRequestConstants.apiPaths.nodesSearch
        
        var parameters = Parameters()
        parameters["search_string"] = "*"
        parameters["depth_level"] = "-1"
        parameters["filter"] = "isFavorite:eq:true"
        
        self.session.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(NodeList.self, decoder: self.decoder, completion: completion)
    }
    
    func setFavorite(nodeId: Int64, completion: @Sendable @escaping (Dracoon.Result<Node>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/\(nodeId)/favorite"
        
        self.session.request(requestUrl, method: .post)
            .validate()
            .decode(Node.self, decoder: self.decoder, completion: completion)
    }
    
    func removeFavorite(nodeId: Int64, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/\(nodeId)/favorite"
        
        self.session.request(requestUrl, method: .delete)
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
    
    // MARK: Comments
    
    func getComments(for nodeId: Int64, limit: Int64?, offset: Int64?, completion: @Sendable @escaping (Dracoon.Result<CommentList>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/\(String(nodeId))/comments"
        
        var parameters = Parameters()
        
        if let limit = limit {
            parameters["limit"] = limit
        }
        
        if let offset = offset {
            parameters["offset"] = offset
        }
        
        self.session.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(CommentList.self, decoder: self.decoder, requestType: .getNodes, completion: completion)
    }
    
    func createComment(for nodeId: Int64, commentText: String, completion: @Sendable @escaping (Dracoon.Result<Comment>) -> Void) {
        guard !commentText.isEmpty else {
            let apiError = DracoonSDKErrorModel(errorCode: .VALIDATION_FIELD_CANNOT_BE_EMPTY, httpStatusCode: 400)
            completion(Dracoon.Result.error(DracoonError.api(error: apiError)))
            return
        }
        let request = CreateNodeCommentRequest(text: commentText)
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/\(String(nodeId))/comments"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(Comment.self, decoder: self.decoder, requestType: .other, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func updateComment(commentId: Int64, updatedText: String, completion: @Sendable @escaping (Dracoon.Result<Comment>) -> Void) {
        guard !updatedText.isEmpty else {
            let apiError = DracoonSDKErrorModel(errorCode: .VALIDATION_FIELD_CANNOT_BE_EMPTY, httpStatusCode: 400)
            completion(Dracoon.Result.error(DracoonError.api(error: apiError)))
            return
        }
        let request = ChangeNodeCommentRequest(text: updatedText)
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/comments/\(String(commentId))"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(Comment.self, decoder: self.decoder, requestType: .other, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func deleteComment(commentId: Int64, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/comments/\(String(commentId))"
        
        self.session.request(requestUrl, method: .delete)
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
    
    // MARK: Crypto
    
    fileprivate func getMissingFileKeys(nodeId: Int64?, offset: Int64?, limit: Int64?, completion: @Sendable @escaping (Dracoon.Result<MissingKeysResponse>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/missingFileKeys"
        
        var parameters = Parameters()
        
        if let nodeId = nodeId {
            parameters["file_id"] = nodeId
        }
        
        if let limit = limit {
            parameters["limit"] = limit
        }
        
        if let offset = offset {
            parameters["offset"] = offset
        }
        
        self.session.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(MissingKeysResponse.self, decoder: self.decoder, requestType: .getMissingFileKeys, completion: completion)
        
    }
    
    fileprivate func setMissingFileKeysBatch(nodeId: Int64?, offset: Int64?, limit: Int64?, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        
        self.getMissingFileKeys(nodeId: nodeId, offset: offset, limit: limit, completion: { result in
            switch result {
            case .value(let missingKeys):
                self.generateMissingFileKey(missingKeys: missingKeys, progress: Progress(), results: [UserFileKeySetRequest](), completion: { items in
                    if items.count > 0 {
                        self.uploadMissingFileKeys(request: UserFileKeySetBatchRequest(items: items), completion: completion)
                    }
                })
            case .error(let error):
                completion(Dracoon.Response(error: error))
                break
            }
        })
    }
    
    fileprivate func generateMissingFileKey(missingKeys: MissingKeysResponse, progress: Progress, results: [UserFileKeySetRequest], completion: @Sendable @escaping ([UserFileKeySetRequest]) -> ()) {
        guard let items = missingKeys.items else {
            completion(results)
            return
        }
        
        if progress.completedUnitCount == items.count {
            completion(results)
            return
        }
        
        guard let encryptionPassword = self.getEncryptionPassword() else {
            completion(results)
            return
        }
        
        let item = items[Int(progress.completedUnitCount)]
        
        guard let fileId = item.fileId, let userId = item.userId,
              let userPublicKey = self.getUserPublicKey(userId: userId, keys: missingKeys.users!),
              let fileKey = self.getFileKeyForFile(fileId: fileId, keys: missingKeys.files!) else {
            progress.completedUnitCount = progress.completedUnitCount + 1
            self.generateMissingFileKey(missingKeys: missingKeys, progress: progress, results: results, completion: completion)
            return
        }
        
        self.account.checkUserKeyPairPassword(version: fileKey.getUserKeyPairVersion(), password: encryptionPassword, completion: { result in
            
            switch result {
            case .error(_):
                progress.completedUnitCount = progress.completedUnitCount + 1
                self.generateMissingFileKey(missingKeys: missingKeys, progress: progress, results: results, completion: completion)
            case .value(let userKeyPair):
                var keyItems = results
                do {
                    let privateKey = UserPrivateKey(privateKey: userKeyPair.privateKeyContainer.privateKey, version: userKeyPair.privateKeyContainer.version)
                    let plainFileKey = try self.crypto.decryptFileKey(fileKey: fileKey, privateKey: privateKey, password: encryptionPassword)
                    let encryptedFileKey = try self.encryptFileKey(fileKey: plainFileKey, publicKey: userPublicKey)
                    keyItems.append(UserFileKeySetRequest(fileId: fileId, userId: userId, fileKey: encryptedFileKey))
                } catch {}
                progress.completedUnitCount = progress.completedUnitCount + 1
                self.generateMissingFileKey(missingKeys: missingKeys, progress: progress, results: keyItems, completion: completion)
            }
        })
    }
    
    fileprivate func getUserPublicKey(userId: Int64, keys: [UserUserPublicKey]) -> UserPublicKey? {
        for key in keys {
            if key._id == userId {
                return key.publicKeyContainer
            }
        }
        return nil
    }
    
    fileprivate func getFileKeyForFile(fileId: Int64, keys: [FileFileKeys]) -> EncryptedFileKey? {
        for key in keys {
            if key._id == fileId {
                return key.fileKeyContainer
            }
        }
        return nil
    }
    
    fileprivate func uploadMissingFileKeys(request: UserFileKeySetBatchRequest, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/keys"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .handleResponse(decoder: self.decoder, completion: completion)
        } catch {
            completion(Dracoon.Response(error: DracoonError.encode(error: error)))
        }
    }
    
    func createFileKey(version: PlainFileKeyVersion) throws -> PlainFileKey {
        return try crypto.generateFileKey(version: version)
    }
    
    
    func getFileKey(nodeId: Int64, completion: @Sendable @escaping (Dracoon.Result<EncryptedFileKey>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/\(String(nodeId))/user_file_key"
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(EncryptedFileKey.self, decoder: self.decoder, completion: completion)
    }
    
    func decryptFileKey(fileKey: EncryptedFileKey, privateKey: UserPrivateKey, password: String) throws -> PlainFileKey {
        return try crypto.decryptFileKey(fileKey: fileKey, privateKey: privateKey, password: password)
    }
    
    func encryptFileKey(fileKey: PlainFileKey, publicKey: UserPublicKey) throws -> EncryptedFileKey {
        return try crypto.encryptFileKey(fileKey: fileKey, publicKey: publicKey)
    }
    
    // MARK: Anti-virus protection
    
    func generateVirusProtectionVerdict(for nodeIds: [Int64], completion: @Sendable @escaping (Dracoon.Result<VirusProtectionVerdictResponse>) -> Void) {
        let request = VirusProtectionVerdictRequest(nodeIds: nodeIds)
        do {
            let jsonBody = try encoder.encode(request)
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/generate_verdict_info"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(VirusProtectionVerdictResponse.self, decoder: self.decoder, completion: completion)
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func deleteMaliciousFilePermanently(nodeId: Int64, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/malicious_files/\(nodeId)"
        
        self.session.request(requestUrl, method: .delete)
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
    
    // MARK: Policies
    
    func getRoomPolicies(roomId: Int64, completion: @Sendable @escaping (Dracoon.Result<RoomPolicies>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/rooms/\(roomId)/policies"
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(RoomPolicies.self, decoder: self.decoder, completion: completion)
    }
}
