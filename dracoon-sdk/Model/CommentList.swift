//
//  CommentList.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 19.11.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: CommentList
public struct CommentList: Codable, Sendable {
    
    /** Range */
    public var range: ModelRange
    /** List of node comments */
    public var items: [Comment]
    
}
