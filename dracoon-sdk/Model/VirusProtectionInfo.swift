//
//  VirusProtectionInfo.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 06.06.23.
//  Copyright © 2023 Dracoon. All rights reserved.
//

import Foundation

public struct VirusProtectionInfo: Codable, Sendable {
    
    public enum Verdict: String, Codable, Sendable {
        case NOT_SCANNING
        case IN_PROGRESS
        case CLEAN
        case MALICIOUS
    }
    
    public var verdict: Verdict
    public var lastCheckedAt: Date?
    public var sha256: String?
    
}

