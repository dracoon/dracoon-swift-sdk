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
    
    func getUserAccount(completion: @escaping DataRequest.DecodeCompletion<UserAccount>) {}
    
    func getCustomerAccount(completion: @escaping DataRequest.DecodeCompletion<CustomerData>) {}
    
    func generateUserKeyPair(password: String) throws -> UserKeyPair {
        let publicKey = UserPublicKey(publicKey: "public", version: "A")
        let privateKey = UserPrivateKey(privateKey: "private", version: "A")
        return UserKeyPair(publicKey: publicKey, privateKey: privateKey)
    }
    
    func setUserKeyPair(password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {}
    
    func getUserKeyPair(completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {}
    
    func checkUserKeyPairPassword(password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void) {}
    
    func deleteUserKeyPair(completion: @escaping (Dracoon.Response) -> Void) {}
    
    func getUserAvatar(completion: @escaping (Dracoon.Result<Avatar>) -> Void) {}
    
    func downloadUserAvatar(targetUrl: URL, completion: @escaping (Dracoon.Result<Avatar>) -> Void) {}
    
    func updateUserAvatar(fileUrl: URL, completion: @escaping (Dracoon.Result<Avatar>) -> Void) {}
    
    func deleteUserAvatar(completion: @escaping (Dracoon.Result<Avatar>) -> Void) {}
    
}
