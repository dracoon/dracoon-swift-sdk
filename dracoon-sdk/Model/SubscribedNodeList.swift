//
//  SubscribedNodeList.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 04.03.22.
//  Copyright © 2022 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: SubscribedNodeList
public struct SubscribedNodeList: Codable, Sendable {
    
    /** Range */
    public var range: ModelRange
    /** List of subscribed nodes */
    public var items: [SubscribedNode]
    
    public init(range: ModelRange, items: [SubscribedNode]){
        self.range = range
        self.items = items
    }
}
