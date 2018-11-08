//
// PendingAssignmentData.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct PendingAssignmentData: Codable {

    public enum State: String, Codable { 
        case accepted = "ACCEPTED"
        case waiting = "WAITING"
        case denied = "DENIED"
    }
    /** Information about pending users */
    public var pendingUserData: PendingUserData
    /** Information about group with pending assignment option */
    public var pendingGroupData: PendingGroupData
    /** Room ID */
    public var roomId: Int64
    /** Acceptance state: * &#x60;ACCEPTED&#x60; * &#x60;WAITING&#x60; * &#x60;DENIED&#x60; */
    public var state: State
    /** &#x60;DEPRECATED&#x60;: Unique identifier for the user */
    public var userId: Int64?
    /** &#x60;DEPRECATED&#x60;: Unique identifier for the group */
    public var groupId: Int64?



}

