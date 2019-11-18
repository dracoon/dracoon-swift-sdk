//
//  DracoonAccountMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 25.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk
@testable import dracoon_sdk

class DracoonAccountMock: DracoonAccount {
    
    var error: DracoonError?
    var userAccountResponse = ResponseModelFactory.getTestResponseModel(UserAccount.self)!
    var customerAccountResponse = ResponseModelFactory.getTestResponseModel(CustomerData.self)!
    var avatarResponse = ResponseModelFactory.getTestResponseModel(Avatar.self)!
    var userAttributesResponse = ResponseModelFactory.getTestResponseModel(AttributesResponse.self)!
    
    func getUserAccount(completion: @escaping DataRequest.DecodeCompletion<UserAccount>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.userAccountResponse))
        }
    }
    
    func getCustomerAccount(completion: @escaping DataRequest.DecodeCompletion<CustomerData>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.customerAccountResponse))
        }
    }
    
    func generateUserKeyPair(password: String) throws -> UserKeyPair {
        let publicKey = UserPublicKey(publicKey: "public", version: "A")
        let privateKey = UserPrivateKey(privateKey: "private", version: "A")
        return UserKeyPair(publicKey: publicKey, privateKey: privateKey)
    }
    
    func setUserKeyPair(password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        self.getUserKeyPair(completion: completion)
    }
    
    func getUserKeyPair(completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        let userPublicKey = UserPublicKey(publicKey: "publicKey", version: "test")
        let userPrivateKey = UserPrivateKey(privateKey: "privateKey", version: "test")
        let userKeyPair = UserKeyPair(publicKey: userPublicKey, privateKey: userPrivateKey)
        let container = UserKeyPairContainer(publicKey: userKeyPair.publicKeyContainer.publicKey,
                                             publicVersion: userKeyPair.publicKeyContainer.version,
                                             privateKey: userKeyPair.privateKeyContainer.privateKey,
                                             privateVersion: userKeyPair.privateKeyContainer.version)
        completion(Dracoon.Result.value(container))
    }
    
    func checkUserKeyPairPassword(password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        self.getUserKeyPair(completion: completion)
    }
    
    func deleteUserKeyPair(completion: @escaping (Dracoon.Response) -> Void) {
        if let error = self.error {
            completion(Dracoon.Response(error: error))
        } else {
            completion(Dracoon.Response(error: nil))
        }
    }
    
    func getUserAvatar(completion: @escaping (Dracoon.Result<Avatar>) -> Void) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.avatarResponse))
        }
    }
    
    func downloadUserAvatar(targetUrl: URL, completion: @escaping (Dracoon.Result<Avatar>) -> Void) {
        self.getUserAvatar(completion: completion)
    }
    
    func updateUserAvatar(fileUrl: URL, completion: @escaping (Dracoon.Result<Avatar>) -> Void) {
        self.getUserAvatar(completion: completion)
    }
    
    func deleteUserAvatar(completion: @escaping (Dracoon.Result<Avatar>) -> Void) {
        self.getUserAvatar(completion: completion)
    }
    
    func getProfileAttributes(completion: @escaping (Dracoon.Result<AttributesResponse>) -> Void) {
        if let error = error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.userAttributesResponse))
        }
    }
    
    func updateProfileAttributes(request: ProfileAttributesRequest, completion: @escaping (Dracoon.Result<AttributesResponse>) -> Void) {
        if let error = error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.userAttributesResponse))
        }
    }
    
    func deleteProfileAttributes(key: String, completion: @escaping (Dracoon.Response) -> Void) {
        completion(Dracoon.Response(error: self.error))
    }
    
}
