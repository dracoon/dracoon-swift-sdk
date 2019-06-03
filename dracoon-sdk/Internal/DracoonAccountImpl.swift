//
//  DracoonAccountImpl.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

class DracoonAccountImpl: DracoonAccount {
    
    let sessionManager: Alamofire.SessionManager
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthTokenManager
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    let crypto: Crypto
    
    init(config: DracoonRequestConfig, crypto: Crypto) {
        self.sessionManager = config.sessionManager
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.oAuthTokenManager = config.oauthTokenManager
        self.decoder = config.decoder
        self.encoder = config.encoder
        self.crypto = crypto
    }
    
    func getUserAccount(completion: @escaping (Dracoon.Result<UserAccount>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/account"
        
        self.sessionManager.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(UserAccount.self, decoder: self.decoder, completion: completion)
        
    }
    
    func getCustomerAccount(completion: @escaping (Dracoon.Result<CustomerData>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/account/customer"
        
        self.sessionManager.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(CustomerData.self, decoder: self.decoder, completion: completion)
    }
    
    func generateUserKeyPair(password: String) throws -> UserKeyPair {
        return try crypto.generateUserKeyPair(password: password)
    }
    
    func setUserKeyPair(password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        do {
            let userKeyPair = try crypto.generateUserKeyPair(password: password)
            let jsonBody = try encoder.encode(userKeyPair)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/user/account/keypair"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.httpBody = jsonBody
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            self.sessionManager.request(urlRequest)
                .validate()
                .response(completionHandler: { response in
                    if let error = response.error {
                        completion(Dracoon.Result.error(DracoonError.keypair_failure(description: error.localizedDescription)))
                    } else {
                        let container = UserKeyPairContainer(publicKey: userKeyPair.publicKeyContainer.publicKey,
                                                             publicVersion: userKeyPair.publicKeyContainer.version,
                                                             privateKey: userKeyPair.privateKeyContainer.privateKey,
                                                             privateVersion: userKeyPair.privateKeyContainer.version)
                        completion(Dracoon.Result.value(container))
                    }
                })
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.keypair_failure(description: error.localizedDescription)))
        }
    }
    
    func getUserKeyPair(completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/account/keypair"
        
        self.sessionManager.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(UserKeyPair.self, decoder: self.decoder, completion: { result in
                switch result {
                case .error(let error):
                    completion(Dracoon.Result.error(error))
                    break
                case .value(let userKeyPair):
                    let container = UserKeyPairContainer(publicKey: userKeyPair.publicKeyContainer.publicKey,
                                                         publicVersion: userKeyPair.publicKeyContainer.version,
                                                         privateKey: userKeyPair.privateKeyContainer.privateKey,
                                                         privateVersion: userKeyPair.privateKeyContainer.version)
                    completion(Dracoon.Result.value(container))
                }
            })
    }
    
    func checkUserKeyPairPassword(password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        self.getUserKeyPair(completion: { result in
            
            switch result {
            case .error(let error):
                completion(Dracoon.Result.error(error))
            case .value(let userKeyPair):
                let userPublicKey = UserPublicKey(publicKey: userKeyPair.publicKeyContainer.publicKey, version: userKeyPair.publicKeyContainer.version)
                let userPrivateKey = UserPrivateKey(privateKey: userKeyPair.privateKeyContainer.privateKey, version: userKeyPair.privateKeyContainer.version)
                let keyPair = UserKeyPair(publicKey: userPublicKey, privateKey: userPrivateKey)
                if self.crypto.checkUserKeyPair(keyPair: keyPair, password: password) {
                    completion(Dracoon.Result.value(userKeyPair))
                } else {
                    completion(Dracoon.Result.error(DracoonError.keypair_decryption_failure))
                }
                
            }
            
        })
    }
    
    func deleteUserKeyPair(completion: @escaping (Dracoon.Response) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/account/keypair"
        
        var urlRequest = URLRequest(url: URL(string: requestUrl)!)
        urlRequest.httpMethod = HTTPMethod.delete.rawValue
        
        self.sessionManager.request(urlRequest)
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
    
    func getUserAvatar(completion: @escaping (Dracoon.Result<Avatar>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/account/avatar"
        
        self.sessionManager.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(Avatar.self, decoder: self.decoder, completion: completion)
    }
    
    func updateAvatar(fileUrl: URL, completion: @escaping (Dracoon.Result<Avatar>) -> Void) {
        guard FileManager.default.fileExists(atPath: fileUrl.path) else {
            completion(Dracoon.Result.error(DracoonError.file_does_not_exist(at: fileUrl)))
            return
        }
        guard let data = try? Data(contentsOf: fileUrl) else {
            completion(Dracoon.Result.error(DracoonError.read_data_failure(at: fileUrl)))
            return
        }
        
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/account/avatar"
        var request = try! URLRequest(url: URL(string: requestUrl)!, method: .post)
        request.addValue("Content-Type", forHTTPHeaderField: "multipart/formdata")
        
        self.sessionManager.upload(multipartFormData: { formdata in
            formdata.append(data, withName: "file", fileName: "file.name", mimeType: "application/octet-stream")
            
        }, with: request, encodingCompletion: { result in
            switch result {
            case .failure(let error):
                let dracoonError = DracoonError.generic(error: error)
                completion(Dracoon.Result.error(dracoonError))
            case .success(let request, _, _):
                request.validate()
                request.decode(Avatar.self, decoder: self.decoder, completion: completion)
            }
        })
        
    }
    
    func deleteUserAvatar(completion: @escaping (Dracoon.Result<Avatar>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/account/avatar"
        
        self.sessionManager.request(requestUrl, method: .delete, parameters: Parameters())
            .validate()
            .decode(Avatar.self, decoder: self.decoder, completion: completion)
    }
}
