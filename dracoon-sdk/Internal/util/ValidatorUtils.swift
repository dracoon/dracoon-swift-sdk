//
//  ValidatorUtils.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

protocol SDKValidator {
    
    func isValid(serverUrl: URL) -> Bool
    func isValid(nodeId: Int64) -> Bool
    func isValid(nodeIds: [Int64]) -> Bool
    func pathExists(at path: String) -> Bool
}

class ValidatorUtils {
    
    static var validator: SDKValidator = DracoonValidator()
    
    static func isValid(serverUrl: URL) -> Bool {
        return self.validator.isValid(serverUrl: serverUrl)
    }
    
    static func isValid(nodeId: Int64) -> Bool {
        return self.validator.isValid(nodeId: nodeId)
    }
    
    static func isValid(nodeIds: [Int64]) -> Bool {
        return self.validator.isValid(nodeIds: nodeIds)
    }
    
    static func pathExists(at path: String) -> Bool {
        return self.validator.pathExists(at: path)
    }
}

class DracoonValidator: SDKValidator {
    
    func isValid(serverUrl: URL) -> Bool {
        let scheme = serverUrl.scheme
        guard scheme != nil && (scheme == "http" || scheme == "https") else {
            return false
        }
        let user = serverUrl.user
        let path = serverUrl.path
        let query = serverUrl.query
        return (user == nil && path.isEmpty && query == nil)
    }
    
    func isValid(nodeId: Int64) -> Bool {
        return nodeId > 0
    }
    
    func isValid(nodeIds: [Int64]) -> Bool {
        guard !nodeIds.isEmpty else {
            return false
        }
        
        for id in nodeIds {
            if !self.isValid(nodeId: id) {
                return false
            }
        }
        return true
    }
    
    func pathExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    
}
