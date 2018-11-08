//
// MoveNode.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct MoveNode: Codable {

    /** Source node ID */
    public var _id: Int64
    /** New node name */
    public var name: String?


    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case name
    }

    public init(nodeId: Int64, name: String?) {
        self._id = nodeId
        self.name = name
    }

}

