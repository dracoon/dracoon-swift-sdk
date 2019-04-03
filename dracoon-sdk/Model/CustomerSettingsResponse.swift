//
//  CustomerSettingsResponse.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: CustomerSettingsResponse
public struct CustomerSettingsResponse: Codable {
    
    /** the name of the container in which all user’s home rooms are located */
    public var homeRoomParentName: String?
    /** refers to the quota of each single user’s home room. “0” represents no quota */
    public var homeRoomQuota: Int64?
    /** if set to true, every user with an Active Directory account gets a personal homeroom. Once activated, this cannot be deactivated **/
    public var homeRoomsActive: Bool
    /** is the id of the parent of all homerooms**/
    public var homeRoomParentId: Int64?
}
