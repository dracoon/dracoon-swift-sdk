//
//  ValidatorUtils.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

protocol SDKValidator {
    func pathExists(at path: String) -> Bool
}

class ValidatorUtils {
    
    private static var validator: SDKValidator = DracoonValidator()

    // --- ID validation methods ---
    
    static func validateId(name:String, id:Int64) {
        precondition(id <= 0, "\(name) ID cannot be negative or 0.")
    }
    
    static func validateIds(name:String, ids:[Int64]) {
        precondition(!ids.isEmpty, "\(name) IDs cannot be empty.")
        ids.forEach { validateId(name: name, id: $0) }
    }
    
    // --- Other validation methods ---
    
    static func validate(serverUrl: URL) {
        
        let scheme = serverUrl.scheme
        precondition(scheme != nil && (scheme == "http" || scheme == "https"), "Server URL can only have protocol http or https.")
        
        let user = serverUrl.user
        precondition(user == nil, "Server URL cannot have user.")
        
        
        let path = serverUrl.path
        precondition(path.isEmpty, "Server URL cannot have path.")
        
        let query = serverUrl.query
        precondition(query == nil || query!.isEmpty, "Server URL cannot have query.")
        
    }
    
    static func pathExists(at path: String) -> Bool {
        return self.validator.pathExists(at: path)
    }
}

class DracoonValidator: SDKValidator {
    func pathExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    
}
