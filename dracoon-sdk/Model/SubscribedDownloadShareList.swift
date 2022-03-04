//
//  SubscribedDownloadShareList.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 04.03.22.
//  Copyright © 2022 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: SubscribedDownloadShareList
public struct SubscribedDownloadShareList: Codable {
    
    /** Range */
    public var range: ModelRange
    /** Subscribed download share information */
    public var items: [SubscribedDownloadShare]
    
    public init(range: ModelRange, items: [SubscribedDownloadShare]){
        self.range = range
        self.items = items
    }
}
