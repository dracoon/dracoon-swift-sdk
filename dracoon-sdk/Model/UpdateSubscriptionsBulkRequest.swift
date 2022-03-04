//
//  UpdateSubscriptionsBulkRequest.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 04.03.22.
//  Copyright © 2022 Dracoon. All rights reserved.
//

import Foundation

public struct UpdateSubscriptionsBulkRequest: Codable {
    
    /** Creates or deletes a subscription on each item in an array of objects. */
    public var isSubscribed: Bool
    /** List of IDs */
    public var objectIds: [Int64]
    
    public init(isSubscribed: Bool, objectIds: [Int64]) {
        self.isSubscribed = isSubscribed
        self.objectIds = objectIds
    }
}
