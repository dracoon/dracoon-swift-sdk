//
//  SubscribedUploadShare.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 04.03.22.
//  Copyright © 2022 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: SubscribedUploadShare
public struct SubscribedUploadShare: Codable {
    
    /** Share ID */
    public var id: Int64
    /** Target room or folder ID */
    public var targetNodeId: Int64?
    
    public init(id: Int64, targetNodeId: Int64? = nil) {
        self.id = id
        self.targetNodeId = targetNodeId
    }
}
