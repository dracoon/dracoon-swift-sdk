//
// RoleList.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct RoleList: Codable {
    
    public init(items: [Role]) {
        self.items = items
    }

    /** List of roles */
    public var items: [Role]



}

