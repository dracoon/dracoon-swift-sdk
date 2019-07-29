//
//  ValidatorUtilsMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 29.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

@testable import dracoon_sdk

class ValidatorUtilsMock: SDKValidator {
    
    public var pathExists = true
    
    func pathExists(at path: String) -> Bool {
        return pathExists
    }
    
}
