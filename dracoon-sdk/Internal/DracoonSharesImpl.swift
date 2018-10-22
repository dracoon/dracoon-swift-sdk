//
//  DracoonSharesImpl.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

class DracoonSharesImpl: DracoonShares {
    
    let sessionManager: Alamofire.SessionManager
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthTokenManager
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    let nodes: DracoonNodes
    let account: DracoonAccount
    let getEncryptionPassword: () -> String?
    
    init(config: DracoonRequestConfig, nodes: DracoonNodes, account: DracoonAccount, getEncryptionPassword: @escaping () -> String?) {
        self.sessionManager = config.sessionManager
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.oAuthTokenManager = config.oauthTokenManager
        self.decoder = config.decoder
        self.encoder = config.encoder
        self.nodes = nodes
        self.account = account
        self.getEncryptionPassword = getEncryptionPassword
    }
    
    func createDownloadShare(nodeId: Int64, password: String?, completion: @escaping (Dracoon.Result<DownloadShare>) -> Void) {
        
        self.nodes.isNodeEncrypted(nodeId: nodeId, completion: { result in
            
            switch result {
            case .error(let error):
                completion(Dracoon.Result.error(DracoonError.shares(error: error)))
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
                    self.account.checkUserKeyPairPassword(password: encryptionPassword, completion: { result in
                        switch result {
                        case .error(let error):
                            completion(Dracoon.Result.error(DracoonError.shares(error: error)))
                            
                        case .value(let userKeyPair):
                            
                            self.nodes.getFileKey(nodeId: nodeId, completion: { result in
                                
                                switch result {
                                case .error(let error):
                                    completion(Dracoon.Result.error(error))
                                case .value(let encryptedFileKey):
                                    do {
                                        let privateKey = UserPrivateKey(privateKey: userKeyPair.privateKeyContainer.privateKey, version: userKeyPair.privateKeyContainer.version)
                                        let plainFileKey = try self.nodes.decryptFileKey(fileKey: encryptedFileKey, privateKey: privateKey, password: encryptionPassword)
                                        let shareKeyPair = try self.account.generateUserKeyPair(password: shareEncryptionPassword)
                                        let shareFileKey = try self.nodes.encryptFileKey(fileKey: plainFileKey, publicKey: shareKeyPair.publicKeyContainer)
                                        let request = CreateDownloadShareRequest(nodeId: nodeId){$0.keyPair = shareKeyPair; $0.fileKey = shareFileKey}
                                        self.requestCreateDownloadShare(request: request, completion: completion)
                                    } catch {
                                        completion(Dracoon.Result.error(DracoonError.shares(error: error)))
                                    }
                                }
                            })
                        }
                    })
                } else {
                    let request = CreateDownloadShareRequest(nodeId: nodeId){$0.password = password}
                    self.requestCreateDownloadShare(request: request, completion: completion)
                }
            }
        })
    }
    
    func requestCreateDownloadShare(request: CreateDownloadShareRequest, completion: @escaping (Dracoon.Result<DownloadShare>) -> Void) {
        do {
            let jsonBody = try self.encoder.encode(request)
            
            let requestUrl = self.serverUrl.absoluteString + self.apiPath + "/shares/downloads"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = "Post"
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .decode(DownloadShare.self, decoder: self.decoder, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.shares(error: error)))
        }
    }
    
    func getDownloadShares(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<DownloadShareList>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/shares/downloads"
        
        let parameters: Parameters = [
            "filter" : "nodeId:eq:\(nodeId)"
        ]
        
        self.sessionManager.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(DownloadShareList.self, decoder: self.decoder, completion: completion)
        
    }
    
    func getDownloadShareQrCode(shareId: Int64, completion: @escaping (Dracoon.Result<DownloadShare>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/shares/downloads/\(shareId)/qr"
        
        self.sessionManager.request(requestUrl, method: .get)
            .validate()
            .decode(DownloadShare.self, decoder: self.decoder, completion: completion)
    }
    
    func createUploadShare(nodeId: Int64, name: String, password: String?, completion: @escaping (Dracoon.Result<UploadShare>) -> Void) {
        self.nodes.isNodeEncrypted(nodeId: nodeId, completion: { result in
            
            switch result {
            case .error(let error):
                completion(Dracoon.Result.error(DracoonError.shares(error: error)))
            case .value(let isEncrypted):
                if isEncrypted {
                    guard password != nil else {
                        completion(Dracoon.Result.error(DracoonError.encrypted_share_no_password_provided))
                        return
                    }
                }
                let request = CreateUploadShareRequest(targetId: nodeId, name: name){$0.password = password}
                self.requestCreateUploadShare(request: request, completion: completion)
            }
        })
    }
    
    func requestCreateUploadShare(request: CreateUploadShareRequest, completion: @escaping (Dracoon.Result<UploadShare>) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/shares/uploads"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = "Post"
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .decode(UploadShare.self, decoder: self.decoder, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.shares(error: error)))
        }
    }
    
    func getUploadShares(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<UploadShareList>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/shares/uploads"
        
        let parameters: Parameters = [
            "filter" : "targetId:eq:\(nodeId)"
        ]
        
        self.sessionManager.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(UploadShareList.self, decoder: self.decoder, completion: completion)
    }
    
    func getUploadShareQrCode(shareId: Int64, completion: @escaping (Dracoon.Result<UploadShare>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/shares/uploads/\(shareId)/qr"
        
        self.sessionManager.request(requestUrl, method: .get)
            .validate()
            .decode(UploadShare.self, decoder: self.decoder, completion: completion)
    }
}
