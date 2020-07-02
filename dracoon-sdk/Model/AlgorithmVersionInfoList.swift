//
//  AlgorithmVersionInfoList.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 02.07.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import Foundation

public struct AlgorithmVersionInfoList: Codable {
    
    public var FilekeyAlgorithms: [FileKeyAlgorithm]
    public var KeyPairAlgorithms: [KeyPairAlgorithm]
}
