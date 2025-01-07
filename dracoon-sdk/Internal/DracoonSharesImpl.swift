//
//  DracoonSharesImpl.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

final class DracoonSharesImpl: DracoonShares, Sendable {
    
    let session: Session
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthInterceptor
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    let nodes: DracoonNodes
    let account: DracoonAccount
    let server: DracoonServer
    let getEncryptionPassword: @Sendable () -> String?
    
    init(requestConfig: DracoonRequestConfig, nodes: DracoonNodes, account: DracoonAccount, server: DracoonServer, getEncryptionPassword: @Sendable @escaping () -> String?) {
        self.session = requestConfig.session
        self.serverUrl = requestConfig.serverUrl
        self.apiPath = requestConfig.apiPath
        self.oAuthTokenManager = requestConfig.oauthTokenManager
        self.decoder = requestConfig.decoder
        self.encoder = requestConfig.encoder
        self.nodes = nodes
        self.account = account
        self.server = server
        self.getEncryptionPassword = getEncryptionPassword
    }
    
    func createDownloadShare(nodeId: Int64, password: String?, completion: @Sendable @escaping (Dracoon.Result<DownloadShare>) -> Void) {
        self.nodes.isNodeEncrypted(nodeId: nodeId, completion: { result in
            switch result {
            case .error(let error):
                completion(Dracoon.Result.error(error))
            case .value(let isEncrypted):
                if isEncrypted {
                    guard let shareEncryptionPassword = password else {
                        completion(Dracoon.Result.error(DracoonError.encrypted_share_no_password_provided))
                        return
                    }
                    guard let encryptionPassword = self.getEncryptionPassword() else {
                        completion(Dracoon.Result.error(DracoonError.no_encryption_password))
                        return
                    }
                    self.createEncryptedShare(nodeId: nodeId, encryptionPassword: encryptionPassword, shareEncryptionPassword: shareEncryptionPassword, completion: completion)
                } else {
                    let request = CreateDownloadShareRequest(nodeId: nodeId){$0.password = password}
                    self.requestCreateDownloadShare(request: request, completion: completion)
                }
            }
        })
    }
    
    private func createEncryptedShare(nodeId: Int64, encryptionPassword: String, shareEncryptionPassword: String, completion: @Sendable @escaping (Dracoon.Result<DownloadShare>) -> Void) {
        self.server.getServerVersion(completion: { result in
            switch result {
            case .error(let error):
                completion(Dracoon.Result.error(error))
            case .value(let versionInfo):
                let apiVersion = versionInfo.restApiVersion
                self.nodes.getFileKey(nodeId: nodeId, completion: { result in
                    switch result {
                    case .error(let error):
                        completion(Dracoon.Result.error(error))
                    case .value(let encryptedFileKey):
                        self.handleFileKeyResponse(nodeId: nodeId, encryptedFileKey: encryptedFileKey, encryptionPassword: encryptionPassword, shareEncryptionPassword: shareEncryptionPassword, apiVersion: apiVersion, completion: completion)
                    }
                })
            }
        })
    }
    
    private func handleFileKeyResponse(nodeId: Int64, encryptedFileKey: EncryptedFileKey, encryptionPassword: String, shareEncryptionPassword: String, apiVersion: String, completion: @Sendable @escaping (Dracoon.Result<DownloadShare>) -> Void) {
        let userKeyPairVersion = encryptedFileKey.getUserKeyPairVersion()
        if ApiVersionCheck.isRequiredServerVersion(requiredVersion: ApiVersionCheck.CryptoUpdateVersion, currentApiVersion: apiVersion) {
            self.account.checkUserKeyPairPassword(version: userKeyPairVersion, password: encryptionPassword, completion: { [weak self] result in
                self?.handleUserKeyPairResponse(result: result, nodeId: nodeId, fileKey: encryptedFileKey, encryptionPassword: encryptionPassword, shareEncryptionPassword: shareEncryptionPassword, completion: completion)
            })
        } else {
            self.account.checkUserKeyPairPassword(password: encryptionPassword, completion: { [weak self] result in
                self?.handleUserKeyPairResponse(result: result, nodeId: nodeId, fileKey: encryptedFileKey, encryptionPassword: encryptionPassword, shareEncryptionPassword: shareEncryptionPassword, completion: completion)
            })
        }
    }
    
    private func handleUserKeyPairResponse(result: Dracoon.Result<UserKeyPairContainer>, nodeId: Int64, fileKey: EncryptedFileKey, encryptionPassword: String, shareEncryptionPassword: String, completion: @Sendable @escaping (Dracoon.Result<DownloadShare>) -> Void) {
        switch result {
        case .error(let error):
            completion(Dracoon.Result.error(error))
        case .value(let userKeyPair):
            do {
                let privateKey = UserPrivateKey(privateKey: userKeyPair.privateKeyContainer.privateKey, version: userKeyPair.privateKeyContainer.version)
                let plainFileKey = try self.nodes.decryptFileKey(fileKey: fileKey, privateKey: privateKey, password: encryptionPassword)
                let shareKeyPair = try self.account.generateUserKeyPair(version: userKeyPair.publicKeyContainer.version, password: shareEncryptionPassword)
                let shareFileKey = try self.nodes.encryptFileKey(fileKey: plainFileKey, publicKey: shareKeyPair.publicKeyContainer)
                let request = CreateDownloadShareRequest(nodeId: nodeId) {
                    $0.keyPair = shareKeyPair
                    $0.fileKey = shareFileKey
                }
                self.requestCreateDownloadShare(request: request, completion: completion)
            } catch CryptoError.decrypt(let message){
                completion(Dracoon.Result.error(DracoonError.filekey_decryption_failure(description: message)))
            } catch CryptoError.generate(let message){
                completion(Dracoon.Result.error(DracoonError.keypair_failure(description: message)))
            } catch CryptoError.encrypt(let message) {
                completion(Dracoon.Result.error(DracoonError.filekey_encryption_failure(description: message)))
            } catch {
                completion(Dracoon.Result.error(DracoonError.generic(error: error)))
            }
        }
    }
    
    func requestCreateDownloadShare(request: CreateDownloadShareRequest, completion: @Sendable @escaping (Dracoon.Result<DownloadShare>) -> Void) {
        do {
            let jsonBody = try self.encoder.encode(request)
            
            let requestUrl = self.serverUrl.absoluteString + self.apiPath + "/shares/downloads"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(DownloadShare.self, decoder: self.decoder, requestType: .createDLShare, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func getDownloadShares(nodeId: Int64, completion: @Sendable @escaping (Dracoon.Result<DownloadShareList>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/shares/downloads"
        
        let parameters: Parameters = [
            "filter" : "nodeId:eq:\(nodeId)"
        ]
        
        self.session.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(DownloadShareList.self, decoder: self.decoder, completion: completion)
        
    }
    
    func getDownloadShares(offset: Int?, limit: Int?, filter: String?, sorting: String?, completion: @Sendable @escaping (Dracoon.Result<DownloadShareList>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/shares/downloads"
        
        var parameters = Parameters()
        
        if let limit = limit {
            parameters["limit"] = limit
        }
        if let offset = offset {
            parameters["offset"] = offset
        }
        if let filter = filter {
            parameters["filter"] = filter
        }
        if let sorting = sorting {
            parameters["sort"] = sorting
        }
        
        self.session.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(DownloadShareList.self, decoder: self.decoder, completion: completion)
        
    }
    
    func getDownloadShareQrCode(shareId: Int64, completion: @Sendable @escaping (Dracoon.Result<DownloadShare>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/shares/downloads/\(shareId)/qr"
        
        self.session.request(requestUrl, method: .get)
            .validate()
            .decode(DownloadShare.self, decoder: self.decoder, completion: completion)
    }
    
    func updateDownloadShare(shareId: Int64, request: UpdateDownloadShareRequest, completion: @Sendable @escaping (Dracoon.Result<DownloadShare>) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/shares/downloads/\(shareId)"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(DownloadShare.self, decoder: self.decoder, requestType: .createDLShare, completion: completion)
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func deleteDownloadShare(shareId: Int64, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/shares/downloads/\(shareId)"
        
        var urlRequest = URLRequest(url: URL(string: requestUrl)!)
        urlRequest.httpMethod = HTTPMethod.delete.rawValue
        
        self.session.request(urlRequest)
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
    
    func deleteDownloadShares(shareIds: [Int64], completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        let requestModel = DeleteDownloadSharesRequest(shareIds: shareIds)
        do {
            let jsonBody = try encoder.encode(requestModel)
            let requestUrl = serverUrl.absoluteString + apiPath + "/shares/downloads"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.delete.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .handleResponse(decoder: self.decoder, completion: completion)
        } catch {
            completion(Dracoon.Response(error: DracoonError.encode(error: error)))
        }
    }
    
    func createUploadShare(nodeId: Int64, name: String?, password: String?, completion: @Sendable @escaping (Dracoon.Result<UploadShare>) -> Void) {
        let request = CreateUploadShareRequest(targetId: nodeId) {
            $0.name = name
            $0.password = password
        }
        self.requestCreateUploadShare(request: request, completion: completion)
    }
    
    func requestCreateUploadShare(request: CreateUploadShareRequest, completion: @Sendable @escaping (Dracoon.Result<UploadShare>) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/shares/uploads"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(UploadShare.self, decoder: self.decoder, requestType: .createULShare, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func getUploadShares(nodeId: Int64, completion: @Sendable @escaping (Dracoon.Result<UploadShareList>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/shares/uploads"
        
        let parameters: Parameters = [
            "filter" : "targetId:eq:\(nodeId)"
        ]
        
        self.session.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(UploadShareList.self, decoder: self.decoder, completion: completion)
    }
    
    func getUploadShares(offset: Int?, limit: Int?, filter: String?, sorting: String?, completion: @Sendable @escaping (Dracoon.Result<UploadShareList>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/shares/uploads"
        
        var parameters = Parameters()
        
        if let limit = limit {
            parameters["limit"] = limit
        }
        if let offset = offset {
            parameters["offset"] = offset
        }
        if let filter = filter {
            parameters["filter"] = filter
        }
        if let sorting = sorting {
            parameters["sort"] = sorting
        }
        
        self.session.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(UploadShareList.self, decoder: self.decoder, completion: completion)
        
    }
    
    func getUploadShareQrCode(shareId: Int64, completion: @Sendable @escaping (Dracoon.Result<UploadShare>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/shares/uploads/\(shareId)/qr"
        
        self.session.request(requestUrl, method: .get)
            .validate()
            .decode(UploadShare.self, decoder: self.decoder, completion: completion)
    }
    
    func updateUploadShare(shareId: Int64, request: UpdateUploadShareRequest, completion: @Sendable @escaping (Dracoon.Result<UploadShare>) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/shares/uploads/\(shareId)"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(UploadShare.self, decoder: self.decoder, requestType: .createULShare, completion: completion)
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
    
    func deleteUploadShare(shareId: Int64, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/shares/uploads/\(shareId)"
        
        var urlRequest = URLRequest(url: URL(string: requestUrl)!)
        urlRequest.httpMethod = HTTPMethod.delete.rawValue
        
        self.session.request(urlRequest)
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
    
    func deleteUploadShares(shareIds: [Int64], completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        let requestModel = DeleteUploadSharesRequest(shareIds: shareIds)
        do {
            let jsonBody = try encoder.encode(requestModel)
            let requestUrl = serverUrl.absoluteString + apiPath + "/shares/uploads"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.delete.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .handleResponse(decoder: self.decoder, completion: completion)
        } catch {
            completion(Dracoon.Response(error: DracoonError.encode(error: error)))
        }
    }
}
