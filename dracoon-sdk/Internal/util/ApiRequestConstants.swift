//
//  ApiRequestConstants.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 23.03.23.
//  Copyright © 2023 Dracoon. All rights reserved.
//

import Foundation

class ApiRequestConstants {
    
    static let headerFields = HeaderFieldConstants()
    
    static let apiPaths = ApiPathConstants()
}

class HeaderFieldConstants {
    
    let keys = HeaderFieldKeys()
    let values = HeaderFieldValues()
}

class HeaderFieldKeys {
    
    let contentType = "Content-Type"
}

class HeaderFieldValues {
    
    let applicationJsonCharsetUTF8 = "application/json; charset=utf-8"
}

class ApiPathConstants {
    
    private static let userAccountPath = "/user/account"
    
    let userAccountAvatar = ApiPathConstants.userAccountPath + "/avatar"
    let userAccountKeyPair = ApiPathConstants.userAccountPath + "/keypair"
    
    let nodesSearch = "/nodes/search"
    
}
