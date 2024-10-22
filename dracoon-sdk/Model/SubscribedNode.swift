//
//  SubscribedNode.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 04.03.22.
//  Copyright © 2022 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: SubscribedNode
public struct SubscribedNode: Codable, Sendable {
    
    public enum ModelType: String, Codable, Sendable {
        case room = "room"
        case folder = "folder"
        case file = "file"
    }
    
    /** Node ID */
    public var id: Int64
    /** Node type */
    public var type: ModelType?
    /** Auth parent room ID */
    public var authParentId: Int64?
    
    public init(id: Int64, type: ModelType? = nil, authParentId: Int64? = nil) {
        self.id = id
        self.type = type
        self.authParentId = authParentId
    }
}
