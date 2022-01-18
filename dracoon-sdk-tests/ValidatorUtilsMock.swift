//
//  ValidatorUtilsMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 29.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
@testable import dracoon_sdk

class ValidatorUtilsMock: SDKValidator {
    
    public var pathExists = true
    public var isValidServerUrl = true
    public var isValidNodeId = true
    public var areValidNodeIds = true
    
    func isValid(serverUrl: URL) -> Bool {
        return isValidServerUrl
    }
    
    func isValid(nodeId: Int64) -> Bool {
        return isValidNodeId
    }
    
    func isValid(nodeIds: [Int64]) -> Bool {
        return areValidNodeIds
    }
    
    func pathExists(at path: String) -> Bool {
        return pathExists
    }
    
}
