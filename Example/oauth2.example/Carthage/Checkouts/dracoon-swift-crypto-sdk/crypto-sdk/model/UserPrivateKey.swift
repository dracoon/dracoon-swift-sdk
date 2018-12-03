//
//  UserPrivateKey.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public class UserPrivateKey: Codable {
    public internal(set) var privateKey: String
    public internal(set) var version: String
    
    public init(privateKey: String, version: String) {
        self.privateKey = privateKey
        self.version = version
    }
}
