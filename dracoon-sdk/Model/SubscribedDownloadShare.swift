//
//  SubscribedDownloadShare.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 04.03.22.
//  Copyright © 2022 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: SubscribedDownloadShare
public struct SubscribedDownloadShare: Codable, Sendable {
    
    /** Share ID */
    public var id: Int64
    /** Auth parent room ID */
    public var authParentId: Int64?
    
    public init(id: Int64, authParentId: Int64? = nil) {
        self.id = id
        self.authParentId = authParentId
    }
    
}
