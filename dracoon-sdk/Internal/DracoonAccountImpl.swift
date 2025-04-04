//
//  DracoonAccountImpl.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk

final class DracoonAccountImpl: DracoonAccount, Sendable {
    
    let session: Session
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthInterceptor
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    let crypto: CryptoProtocol
    
    init(config: DracoonRequestConfig, crypto: CryptoProtocol) {
        self.session = config.session
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.oAuthTokenManager = config.oauthTokenManager
        self.decoder = config.decoder
        self.encoder = config.encoder
        self.crypto = crypto
    }
    
    func getUserAccount(completion: @Sendable @escaping (Dracoon.Result<UserAccount>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/account"
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(UserAccount.self, decoder: self.decoder, completion: completion)
    }
    
    func getCustomerAccount(completion: @Sendable @escaping (Dracoon.Result<CustomerData>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/account/customer"
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(CustomerData.self, decoder: self.decoder, completion: completion)
    }
    
    func generateUserKeyPair(version: UserKeyPairVersion, password: String) throws -> UserKeyPair {
        return try crypto.generateUserKeyPair(password: password, version: version)
    }
    
    func setUserKeyPair(version: UserKeyPairVersion, password: String, completion: @Sendable @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        do {
            let userKeyPair = try crypto.generateUserKeyPair(password: password, version: version)
            let jsonBody = try encoder.encode(userKeyPair)
            
            let requestUrl = serverUrl.absoluteString + apiPath + ApiRequestConstants.apiPaths.userAccountKeyPair
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.httpBody = jsonBody
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            
            self.session.request(urlRequest)
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
    
    func getUserKeyPair(version: UserKeyPairVersion, completion: @Sendable @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        let parameters: Parameters = [
            "version" : "\(version.rawValue)"
        ]
        self.sendGetUserKeyPairRequest(parameters: parameters, completion: completion)
    }
    
    func getUserKeyPair(completion: @Sendable @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        self.sendGetUserKeyPairRequest(parameters: Parameters(), completion: completion)
    }
    
    private func sendGetUserKeyPairRequest(parameters: [String : Sendable], completion: @Sendable @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + ApiRequestConstants.apiPaths.userAccountKeyPair
        
        self.session.request(requestUrl, method: .get, parameters: parameters)
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
    
    func checkUserKeyPairPassword(version: UserKeyPairVersion, password: String, completion: @Sendable @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        self.getUserKeyPair(version: version, completion: { result in
            self.handleCheckUserKeyPairResponse(result: result, password: password, completion: completion)
        })
    }
    
    func checkUserKeyPairPassword(password: String, completion: @Sendable @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        self.getUserKeyPair(completion: { result in
            self.handleCheckUserKeyPairResponse(result: result, password: password, completion: completion)
        })
    }
    
    private func handleCheckUserKeyPairResponse(result: Dracoon.Result<UserKeyPairContainer>, password: String, completion: @Sendable @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
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
    }
    
    func deleteUserKeyPair(version: UserKeyPairVersion, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        let parameters: Parameters = [
            "version" : "\(version.rawValue)"
        ]
        self.sendDeleteUserKeyPairRequest(parameters: parameters, completion: completion)
    }
    
    func deleteUserKeyPair(completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        self.sendDeleteUserKeyPairRequest(parameters: Parameters(), completion: completion)
    }
    
    private func sendDeleteUserKeyPairRequest(parameters: [String : Sendable], completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + ApiRequestConstants.apiPaths.userAccountKeyPair
        self.session.request(requestUrl, method: .delete, parameters: parameters)
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
    
    func getUserAvatar(completion: @Sendable @escaping (Dracoon.Result<Avatar>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + ApiRequestConstants.apiPaths.userAccountAvatar
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(Avatar.self, decoder: self.decoder, completion: completion)
    }
    
    func downloadUserAvatar(targetUrl: URL, completion: @Sendable @escaping (Dracoon.Result<Avatar>) -> Void) {
        self.getUserAvatar(completion: { result in
            switch result {
            case .error(let error):
                completion(Dracoon.Result.error(error))
            case .value(let avatar):
                let downloadUrl = URL(string: avatar.avatarUri)!
                var request = URLRequest(url: downloadUrl)
                request.addValue("application/octet-stream", forHTTPHeaderField: "Accept")
                
                self.session
                    .download(request, to: { _, _ in
                        return (targetUrl, [.removePreviousFile, .createIntermediateDirectories])
                    })
                    .response(completionHandler: { downloadResponse in
                        switch downloadResponse.result {
                        case .success(_):
                            completion(Dracoon.Result.value(avatar))
                        case .failure(let error):
                            completion(Dracoon.Result.error(DracoonError.generic(error: error)))
                        }
                    })
            }
        })
    }
    
    func updateUserAvatar(fileUrl: URL, completion: @Sendable @escaping (Dracoon.Result<Avatar>) -> Void) {
        guard ValidatorUtils.pathExists(at: fileUrl.path) else {
            completion(Dracoon.Result.error(DracoonError.file_does_not_exist(at: fileUrl)))
            return
        }
        guard let data = try? FileUtils.readData(fileUrl) else {
            completion(Dracoon.Result.error(DracoonError.read_data_failure(at: fileUrl)))
            return
        }
        
        let requestUrl = serverUrl.absoluteString + apiPath + ApiRequestConstants.apiPaths.userAccountAvatar
        var request = URLRequest(url: URL(string: requestUrl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("multipart/formdata", forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
        
        let uploadRequest = self.session.upload(multipartFormData: { formData in
            formData.append(data, withName: "file", fileName: "file.name", mimeType: "application/octet-stream")
        }, with: request)
        uploadRequest.response(completionHandler: { response in
            switch response.result {
            case .success(_):
                uploadRequest.validate()
                uploadRequest.decode(Avatar.self, decoder: self.decoder, completion: completion)
            case .failure(let error):
                let dracoonError = DracoonError.generic(error: error)
                completion(Dracoon.Result.error(dracoonError))
            }
            })
    }
    
    func deleteUserAvatar(completion: @Sendable @escaping (Dracoon.Result<Avatar>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + ApiRequestConstants.apiPaths.userAccountAvatar
        
        self.session.request(requestUrl, method: .delete, parameters: Parameters())
            .validate()
            .decode(Avatar.self, decoder: self.decoder, completion: completion)
    }
    
    func getProfileAttributes(completion: @Sendable @escaping (Dracoon.Result<AttributesResponse>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/profileAttributes"
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(AttributesResponse.self, decoder: self.decoder, completion: completion)
    }
    
    func updateProfileAttributes(request: ProfileAttributesRequest, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/user/profileAttributes"
            
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
    
    func deleteProfileAttributes(key: String, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        guard let pathKey = key.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            completion(Dracoon.Response(error: DracoonError.invalidParameter(description: key)))
            return
        }
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/profileAttributes/\(pathKey)"
        
        var urlRequest = URLRequest(url: URL(string: requestUrl)!)
        urlRequest.httpMethod = HTTPMethod.delete.rawValue
        
        self.session.request(urlRequest)
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
}
