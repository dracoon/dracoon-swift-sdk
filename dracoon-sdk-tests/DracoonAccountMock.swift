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

class DracoonAccountMock: DracoonAccount, @unchecked Sendable {
    
    var error: DracoonError?
    var userAccountResponse: UserAccount
    var customerAccountResponse: CustomerData
    var avatarResponse: Avatar
    var userAttributesResponse: AttributesResponse
    var userProfileAttributes: ProfileAttributes
    
    init() {
        let modelFactory = ResponseModelFactory()
        self.userAccountResponse = modelFactory.getTestResponseModel(UserAccount.self)!
        self.customerAccountResponse = modelFactory.getTestResponseModel(CustomerData.self)!
        self.avatarResponse = modelFactory.getTestResponseModel(Avatar.self)!
        self.userAttributesResponse = modelFactory.getTestResponseModel(AttributesResponse.self)!
        self.userProfileAttributes = modelFactory.getTestResponseModel(ProfileAttributes.self)!
    }
    
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
    
    func generateUserKeyPair(version: UserKeyPairVersion, password: String) throws -> UserKeyPair {
        let publicKey = UserPublicKey(publicKey: "public", version: version)
        let privateKey = UserPrivateKey(privateKey: "private", version: version)
        return UserKeyPair(publicKey: publicKey, privateKey: privateKey)
    }
    
    func setUserKeyPair(version: UserKeyPairVersion, password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        self.getUserKeyPair(version: version, completion: completion)
    }
    
    func getUserKeyPair(completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        self.getUserKeyPair(version: .RSA2048, completion: completion)
    }
    
    func getUserKeyPair(version: UserKeyPairVersion, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        let userPublicKey = UserPublicKey(publicKey: "publicKey", version: version)
        let userPrivateKey = UserPrivateKey(privateKey: "privateKey", version: version)
        let userKeyPair = UserKeyPair(publicKey: userPublicKey, privateKey: userPrivateKey)
        let container = UserKeyPairContainer(publicKey: userKeyPair.publicKeyContainer.publicKey,
                                             publicVersion: userKeyPair.publicKeyContainer.version,
                                             privateKey: userKeyPair.privateKeyContainer.privateKey,
                                             privateVersion: userKeyPair.privateKeyContainer.version)
        completion(Dracoon.Result.value(container))
    }
    
    func checkUserKeyPairPassword(password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        self.checkUserKeyPairPassword(version: .RSA2048, password: password, completion: completion)
    }
    
    func checkUserKeyPairPassword(version: UserKeyPairVersion, password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {
        self.getUserKeyPair(version: version, completion: completion)
    }
    
    func deleteUserKeyPair(completion: @escaping (Dracoon.Response) -> Void) {
        self.deleteUserKeyPair(version: .RSA2048, completion: completion)
    }
    
    func deleteUserKeyPair(version: UserKeyPairVersion, completion: @escaping (Dracoon.Response) -> Void) {
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
    
    func updateProfileAttributes(request: ProfileAttributesRequest, completion: @escaping (Dracoon.Result<ProfileAttributes>) -> Void) {
        if let error = error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.userProfileAttributes))
        }
    }
    
    func deleteProfileAttributes(key: String, completion: @escaping (Dracoon.Response) -> Void) {
        completion(Dracoon.Response(error: self.error))
    }
    
}
