//
//  SubscribedUploadShareList.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 04.03.22.
//  Copyright © 2022 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: SubscribedUploadShareList
public struct SubscribedUploadShareList: Codable {
    
    /** Range */
    public var range: ModelRange
    /** List of subscribed upload shares */
    public var items: [SubscribedUploadShare]
    
    public init(range: ModelRange, items: [SubscribedUploadShare]){
        self.range = range
        self.items = items
    }
}
