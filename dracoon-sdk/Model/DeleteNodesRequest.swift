//
// DeleteNodesRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/// - Tag: DeleteNodesRequest
public struct DeleteNodesRequest: Codable, Sendable {

    /** List of node IDs */
    public var nodeIds: [Int64]

    public init(nodeIds: [Int64]) {
        self.nodeIds = nodeIds
    }
}

