//
//  ApiRequestConstants.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 23.03.23.
//  Copyright © 2023 Dracoon. All rights reserved.
//

import Foundation

final class ApiRequestConstants: Sendable {
    
    static let headerFields = HeaderFieldConstants()
    
    static let apiPaths = ApiPathConstants()
}

final class HeaderFieldConstants: Sendable {
    
    let keys = HeaderFieldKeys()
    let values = HeaderFieldValues()
}

final class HeaderFieldKeys: Sendable {
    
    let contentType = "Content-Type"
}

final class HeaderFieldValues: Sendable {
    
    let applicationJsonCharsetUTF8 = "application/json; charset=utf-8"
}

final class ApiPathConstants: Sendable {
    
    private static let userAccountPath = "/user/account"
    
    let userAccountAvatar = ApiPathConstants.userAccountPath + "/avatar"
    let userAccountKeyPair = ApiPathConstants.userAccountPath + "/keypair"
    
    let nodesSearch = "/nodes/search"
    
}
