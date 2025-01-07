//
//  Comment.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 19.11.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: Comment
public struct Comment: Codable, Sendable {
    
    /** Comment ID */
    public var id: Int64
    /** Comment text */
    public var text: String?
    /** Creation date */
    public var createdAt: Date
    /** Created by user info */
    public var createdBy: UserInfo?
    /** Modification date */
    public var updatedAt: Date?
    /** Updated by user info */
    public var updatedBy: UserInfo?
    /** Determines whether comment was edited or not */
    public var isChanged: Bool
    /** Determines whether comment was deleted or not */
    public var isDeleted: Bool
    
}
