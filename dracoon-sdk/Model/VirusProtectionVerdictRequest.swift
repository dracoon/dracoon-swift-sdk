//
//  VirusProtectionVerdictRequest.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 06.06.23.
//  Copyright © 2023 Dracoon. All rights reserved.
//

import Foundation

public struct VirusProtectionVerdictRequest: Codable {
    
    public var nodeIds: [Int64]
    
    public init(nodeIds: [Int64]) {
        self.nodeIds = nodeIds
    }
}
