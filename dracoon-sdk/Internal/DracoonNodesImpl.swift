//
//  DracoonNodesImpl.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

class DracoonNodesImpl: DracoonNodes {
    
    let config: DracoonRequestConfig
    let sessionManager: Alamofire.SessionManager
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthTokenManager
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    let crypto: Crypto
    let account: DracoonAccount
    let getEncryptionPassword: () -> String?
    
    private var uploads = [String : FileUpload]()
    private var downloads = [Int64 : FileDownload]()
    
    init(config: DracoonRequestConfig, crypto: Crypto, account: DracoonAccount, getEncryptionPassword: @escaping () -> String?) {
        self.config = config
        self.sessionManager = config.sessionManager
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.oAuthTokenManager = config.oauthTokenManager
        self.decoder = config.decoder
        self.encoder = config.encoder
        self.crypto = crypto
        self.account = account
        self.getEncryptionPassword = getEncryptionPassword
    }
    
    func getNodes(parentNodeId: Int64, limit: Int64?, offset: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>) {
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
        
        self.sessionManager.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(NodeList.self, decoder: self.decoder, requestType: .getNodes, completion: completion)
        
    }
    
    func getNode(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/\(String(nodeId))"
        
        self.sessionManager.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(Node.self, decoder: self.decoder, requestType: .getNodes, completion: completion)
    }
    
    func getNode(nodePath: String, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        
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
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/search"
        
        let parameters: Parameters = [
            "search_string": String(nodeComponents.last!),
            "depth_level": nodeComponents.count
        ]
        
        self.sessionManager.request(requestUrl, method: .get, parameters: parameters)
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
    
    func isNodeEncrypted(nodeId: Int64, completion: @escaping (Dracoon.Result<Bool>) -> Void) {
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
    
    func createRoom(request: CreateRoomRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/rooms"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .createRoom, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func updateRoom(roomId: Int64, request: UpdateRoomRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/rooms/\(String(roomId))"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .updateRoom, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func createFolder(request: CreateFolderRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/folders"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .createFolder, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func updateFolder(folderId: Int64, request: UpdateFolderRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/folders/\(String(folderId))"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .updateFolder, completion: completion)
            
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func updateFile(fileId: Int64, request: UpdateFileRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/\(String(fileId))"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .updateFile, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func deleteNodes(request: DeleteNodesRequest, completion: @escaping (Dracoon.Response) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.delete.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .handleResponse(decoder: self.decoder, completion: completion)
            
        } catch {
            completion(Dracoon.Response(error: DracoonError.encode(error: error)))
        }
    }
    
    func copyNodes(nodeId: Int64, request: CopyNodesRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/\(String(nodeId))/copy_to"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .copyNodes, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func moveNodes(nodeId: Int64, request: MoveNodesRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/\(String(nodeId))/move_to"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .decode(Node.self, decoder: self.decoder, requestType: .moveNodes, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    // MARK: Upload file
    
    func uploadFile(uploadId: String, request: CreateFileUploadRequest, filePath: URL, callback: UploadCallback, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy = CompleteUploadRequest.ResolutionStrategy.autorename) {
        
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            callback.onError?(DracoonError.file_does_not_exist(at: filePath))
            return
        }
        
        self.isNodeEncrypted(nodeId: request.parentId, completion: { result in
            
            switch result {
            case .error(let error):
                callback.onError?(error)
            case .value(let isEncrypted):
                var cryptoImpl: Crypto?
                if isEncrypted {
                    cryptoImpl = self.crypto
                }
                let upload = FileUpload(config: self.config, request: request, filePath: filePath, resolutionStrategy: resolutionStrategy,
                                        crypto: cryptoImpl, account: self.account)
                
                let innerCallback = UploadCallback()
                innerCallback.onCanceled = callback.onCanceled
                innerCallback.onComplete = { node in
                    if isEncrypted {
                        self.setMissingFileKeysBatch(nodeId: node._id, offset: 0, limit: DracoonConstants.MISSING_FILEKEYS_MAX_COUNT, completion: { _ in
                        })
                    }
                    callback.onComplete?(node)
                    self.uploads.removeValue(forKey: uploadId)
                }
                innerCallback.onError = callback.onError
                innerCallback.onProgress = callback.onProgress
                
                upload.callback = innerCallback
                
                self.uploads[uploadId] = upload
                upload.start()
            }
        })
    }
    
    func cancelUpload(uploadId: String) {
        
        guard let upload = self.uploads[uploadId] else {
            return
        }
        upload.cancel()
        self.uploads.removeValue(forKey: uploadId)
    }
    
    // MARK: Download file
    
    func downloadFile(nodeId: Int64, targetUrl: URL, callback: DownloadCallback) {
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
                            self.startFileDownload(nodeId: nodeId, targetUrl: targetUrl, callback: callback, fileKey: encryptedFileKey)
                        }
                        
                    })
                } else {
                    self.startFileDownload(nodeId: nodeId, targetUrl: targetUrl, callback: callback, fileKey: nil)
                }
            }
        })
    }
    
    fileprivate func startFileDownload(nodeId: Int64, targetUrl: URL, callback: DownloadCallback, fileKey: EncryptedFileKey?) {
        
        let download = FileDownload(nodeId: nodeId, targetUrl: targetUrl, config: self.config, account: self.account, nodes: self,
                                    crypto: self.crypto, fileKey: fileKey, getEncryptionPassword: self.getEncryptionPassword)
        
        let innerCallback = DownloadCallback()
        innerCallback.onCanceled = callback.onCanceled
        innerCallback.onComplete = { url in
            self.downloads.removeValue(forKey: nodeId)
            callback.onComplete?(url)
        }
        innerCallback.onError = callback.onError
        innerCallback.onProgress = callback.onProgress
        
        download.callback = innerCallback
        self.downloads[nodeId] = download
        download.start()
    }
    
    func cancelDownload(nodeId: Int64) {
        guard let download = downloads[nodeId] else {
            return
        }
        download.cancel()
        self.downloads.removeValue(forKey: nodeId)
    }
    
    // MARK: Search
    
    func searchNodes(parentNodeId: Int64, searchString: String, offset: Int64?, limit: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/search"
        
        var parameters = Parameters()
        if let limit = limit {
            parameters["limit"] = limit
        }
        if let offset = offset {
            parameters["offset"] = offset
        }
        parameters["search_string"] = searchString
        
        self.sessionManager.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(NodeList.self, decoder: self.decoder, requestType: .searchNodes, completion: completion)
        
    }
    
    func searchNodes(parentNodeId: Int64, searchString: String, depthLevel: Int?, filter: String?, offset: Int64?, limit: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/search"
        
        var parameters = Parameters()
        if let limit = limit {
            parameters["limit"] = limit
        }
        if let offset = offset {
            parameters["offset"] = offset
        }
        if let depthLevel = depthLevel {
            parameters["depth_level"] = String(depthLevel)
        }
        if let filter = filter?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            parameters["filter"] = filter
        }
        parameters["search_string"] = searchString
        
        self.sessionManager.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(NodeList.self, decoder: self.decoder, requestType: .searchNodes, completion: completion)
        
    }
    
    func getFavorites(completion: @escaping DataRequest.DecodeCompletion<NodeList>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/search"
        
        var parameters = Parameters()
        parameters["search_string"] = "*"
        parameters["depth_level"] = "-1"
        parameters["filter"] = "isFavorite:eq:true"
        
        self.sessionManager.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(NodeList.self, decoder: self.decoder, completion: completion)
    }
    
    func setFavorite(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/\(nodeId)/favorite"
        
        self.sessionManager.request(requestUrl, method: .post)
            .validate()
            .decode(Node.self, decoder: self.decoder, completion: completion)
    }
    
    func removeFavorite(nodeId: Int64, completion: @escaping (Dracoon.Response) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/\(nodeId)/favorite"
        
        self.sessionManager.request(requestUrl, method: .delete)
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
    
    // MARK: Crypto
    
    fileprivate func getMissingFileKeys(nodeId: Int64?, offset: Int64?, limit: Int64?, completion: @escaping DataRequest.DecodeCompletion<MissingKeysResponse>) {
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
        
        self.sessionManager.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(MissingKeysResponse.self, decoder: self.decoder, requestType: .getMissingFileKeys, completion: completion)
        
    }
    
    fileprivate func setMissingFileKeysBatch(nodeId: Int64?, offset: Int64?, limit: Int64?, completion: @escaping (Dracoon.Response) -> Void) {
        
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
    
    fileprivate func generateMissingFileKey(missingKeys: MissingKeysResponse, progress: Progress, results: [UserFileKeySetRequest], completion: @escaping ([UserFileKeySetRequest]) -> ()) {
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
        var keyItems = results
        
        self.account.checkUserKeyPairPassword(password: encryptionPassword, completion: { result in
            
            switch result {
            case .error(_):
                progress.completedUnitCount = progress.completedUnitCount + 1
                self.generateMissingFileKey(missingKeys: missingKeys, progress: progress, results: results, completion: completion)
            case .value(let userKeyPair):
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
    
    fileprivate func uploadMissingFileKeys(request: UserFileKeySetBatchRequest, completion: @escaping (Dracoon.Response) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/keys"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .handleResponse(decoder: self.decoder, completion: completion)
        } catch {
            completion(Dracoon.Response(error: DracoonError.encode(error: error)))
        }
    }
    
    func createFileKey(version: String = CryptoConstants.DEFAULT_VERSION) throws -> PlainFileKey {
        return try crypto.generateFileKey(version: version)
    }
    
    
    func getFileKey(nodeId: Int64, completion: @escaping (Dracoon.Result<EncryptedFileKey>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/nodes/files/\(String(nodeId))/user_file_key"
        
        self.sessionManager.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(EncryptedFileKey.self, decoder: self.decoder, completion: completion)
    }
    
    func decryptFileKey(fileKey: EncryptedFileKey, privateKey: UserPrivateKey, password: String) throws -> PlainFileKey {
        return try crypto.decryptFileKey(fileKey: fileKey, privateKey: privateKey, password: password)
    }
    
    func encryptFileKey(fileKey: PlainFileKey, publicKey: UserPublicKey) throws -> EncryptedFileKey {
        return try crypto.encryptFileKey(fileKey: fileKey, publicKey: publicKey)
    }
}
