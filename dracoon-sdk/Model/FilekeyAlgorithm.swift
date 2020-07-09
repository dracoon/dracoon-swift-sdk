//
//  FilekeyAlgorithm.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 02.07.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import Foundation
import crypto_sdk

public enum AlgorithmStatus: String, Codable {
    case REQUIRED
    case RECOMMENDED
    case DISCOURAGED
}

public struct FileKeyAlgorithm: Codable {
    
    public var version: EncryptedFileKeyVersion
    public var description: String
    public var status: AlgorithmStatus
}
