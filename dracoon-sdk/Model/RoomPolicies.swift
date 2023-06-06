//
//  RoomPolicies.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 06.06.23.
//  Copyright © 2023 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: RoomPolicies
public struct RoomPolicies: Codable {
    
    /**
     Default policy room expiration period in seconds.
     All files in a room will have their expiration date set to this period after their respective upload.
     0 means no default expiration policy is set. */
    public var defaultExpirationPeriod: Int
    
    /**
     [Since 4.44.0]
     Determines whether virus protection is enabled for room. To be set by room admins */
    public var virusProtectionEnabled: Bool?
}
