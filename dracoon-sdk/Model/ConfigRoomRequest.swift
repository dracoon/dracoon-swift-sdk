//
//  ConfigRoomRequest.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 22.09.21.
//  Copyright © 2021 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: ConfigRoomRequest
public struct ConfigRoomRequest: Codable, Sendable {
    
    public enum NewGroupMemberAcceptance: String, Codable, Sendable {
        case autoallow = "autoallow"
        case pending = "pending"
    }
    
    /** Retention period for deleted nodes in days (maximum: 9999, minimum: 0) */
    public var recycleBinRetentionPeriod: Int?
    /** Inherit permissions from parent room (default: &#x60;false&#x60; if &#x60;parentId&#x60; is &#x60;0&#x60;; otherwise: &#x60;true&#x60;) */
    public var inheritPermissions: Bool?
    /** Take over existing permissions */
    public var takeOverPermissions: Bool?
    /** List of user ids A room requires at least one admin (user or group) */
    public var adminIds: [Int64]?
    /** List of group ids A room requires at least one admin (user or group) */
    public var adminGroupIds: [Int64]?
    /** Behaviour when new users are added to the group: * &#x60;autoallow&#x60; * &#x60;pending&#x60;  Only relevant if &#x60;adminGroupIds&#x60; has items. (default: &#x60;autoallow&#x60;) */
    public var newGroupMemberAcceptance: NewGroupMemberAcceptance?
    /** Is activities log active (for rooms only) (default: true) */
    public var hasActivitiesLog: Bool?
    /** Classification ID (for files only): * &#x60;1&#x60; - public * &#x60;2&#x60; - for internal use only * &#x60;3&#x60; - confidential * &#x60;4&#x60; - strictly confidential
     Provided (or default) classification is taken from room when file gets uploaded without any classification.
     (default: 2 - internal) */
    public var classification: Int?
    
    public init() {
        // Public initializer
    }
    
}
