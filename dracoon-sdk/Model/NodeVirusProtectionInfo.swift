//
//  NodeVirusProtectionInfo.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 06.06.23.
//  Copyright © 2023 Dracoon. All rights reserved.
//

import Foundation

public struct NodeVirusProtectionInfo: Codable {
    
    public var nodeId: Int64
    public var verdict: VirusProtectionInfo.Verdict
    public var lastCheckedAt: String?
    public var sha256: String?
    
}
