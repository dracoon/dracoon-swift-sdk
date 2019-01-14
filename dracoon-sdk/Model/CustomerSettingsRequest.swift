//
//  CustomerSettingsRequest.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

public struct CustomerSettingsRequest: Codable {
    
    /** the name of the container in which all user’s home rooms are located */
    public var homeRoomParentName: String?
    /** refers to the quota of each single user’s home room. “0” represents no quota */
    public var homeRoomQuota: Int64?
    /** if set to true, every user with an Active Directory account gets a personal homeroom. Once activated, this cannot be deactivated **/
    public var homeRoomsActive: Bool?
    
    public init(homeRoomParentName: String?, homeRoomQuota: Int64?, homeRoomsActive: Bool?) {
        self.homeRoomQuota = homeRoomQuota
        self.homeRoomParentName = homeRoomParentName
        self.homeRoomsActive = homeRoomsActive
    }
}
