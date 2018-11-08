//
//  UserKeyPair.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public class UserKeyPair: Codable {
    public internal(set) var publicKeyContainer: UserPublicKey
    public internal(set) var privateKeyContainer: UserPrivateKey
    
    public init(publicKey: UserPublicKey, privateKey: UserPrivateKey) {
        self.publicKeyContainer = publicKey
        self.privateKeyContainer = privateKey
    }
}
