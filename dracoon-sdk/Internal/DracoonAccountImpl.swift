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
            urlRequest.httpMethod = "Post"
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
        urlRequest.httpMethod = "Delete"
        
        self.sessionManager.request(urlRequest)
            .validate()
            .response(completionHandler: { response in
                if let error = response.error {
                    completion(Dracoon.Response(error: error))
                } else {
                    completion(Dracoon.Response(error: nil))
                }
            })
    }
}
