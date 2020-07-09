//
//  KeyPairAlgorithm.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 02.07.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import Foundation
import crypto_sdk

public struct KeyPairAlgorithm: Codable {
    
    public var version: UserKeyPairVersion
    public var description: String
    public var status: AlgorithmStatus
}
