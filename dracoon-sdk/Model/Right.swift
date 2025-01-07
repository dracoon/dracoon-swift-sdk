//
// Right.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct Right: Codable, Sendable {
    
    public init(id: Int, name: String, description: String) {
        self._id = id
        self.name = name
        self._description = description
    }

    /** Unique identifier for the right */
    public var _id: Int
    /** Right (unique) name */
    public var name: String
    /** Right description */
    public var _description: String


    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case name
        case _description = "description"
    }


}

