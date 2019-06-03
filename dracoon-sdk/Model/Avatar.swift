//
//  Avatar.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 03.06.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: Avatar
public struct Avatar: Codable {
    
    /** Download URI of avatar */
    public var avatarUri: String
    /** Unique avatar identifier */
    public var avatarUuid: String
    /** Determines whether user updated the avatar with own image */
    public var isCustomAvatar: Bool
}
