//
// Role.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct Role: Codable {
    
    public init(id: Int, name: String, description: String) {
        self._id = id
        self.name = name
        self._description = description
    }

    /** Unique identifier for the role */
    public var _id: Int
    /** Role (unique) name */
    public var name: String
    /** Role description */
    public var _description: String
    /** List of reachable right over role */
    public var items: [Right]?


    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case name
        case _description = "description"
        case items
    }


}

