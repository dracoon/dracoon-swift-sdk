//
// SyslogEvent.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct SyslogEvent: Codable {

    public enum Status: Int, Codable { 
        case _0 = 0
        case _2 = 2
    }
    /** Event ID */
    public var _id: Int64
    /** Event timestamp */
    public var time: Date
    /** Unique identifier for the user */
    public var userId: Int64
    /** Event description */
    public var message: String
    /** Operation type ID */
    public var operationId: Int?
    /** Operation name */
    public var operationName: String?
    /** Operation status: * &#x60;0&#x60; - Success * &#x60;2&#x60; - Error */
    public var status: Status?
    /** Client */
    public var userClient: String?
    /** Unique identifier for the customer */
    public var customerId: Int64?
    /** User name */
    public var userName: String?
    /** User IP */
    public var userIp: String?
    /** Auth parent source ID */
    public var authParentSource: String?
    /** Auth parent target ID */
    public var authParentTarget: String?
    /** Object ID 1 */
    public var objectId1: Int64?
    /** Object type 1 */
    public var objectType1: Int?
    /** Object name 1 */
    public var objectName1: String?
    /** Object ID 2 */
    public var objectId2: Int64?
    /** Object type 2 */
    public var objectType2: Int?
    /** Object type 2 */
    public var objectName2: String?
    /** Attribute 1 */
    public var attribute1: String?
    /** Attribute 2 */
    public var attribute2: String?
    /** Attribute 3 */
    public var attribute3: String?


    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case time
        case userId
        case message
        case operationId
        case operationName
        case status
        case userClient
        case customerId
        case userName
        case userIp
        case authParentSource
        case authParentTarget
        case objectId1
        case objectType1
        case objectName1
        case objectId2
        case objectType2
        case objectName2
        case attribute1
        case attribute2
        case attribute3
    }


}

