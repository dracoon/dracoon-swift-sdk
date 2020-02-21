//
// CreateFolderRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/// - Tag: CreateFolderRequest
public struct CreateFolderRequest: Codable {
    
    public init(parentId: Int64, name: String) {
        self.parentId = parentId
        self.name = name
    }

    /** Parent node ID (room or folder) */
    public var parentId: Int64
    /** Name */
    public var name: String
    /** User notes Use empty string to remove. */
    public var notes: String?



}

