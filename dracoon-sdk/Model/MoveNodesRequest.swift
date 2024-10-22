//
// MoveNodesRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/// - Tag: MoveNodesRequest
public struct MoveNodesRequest: Codable, Sendable {

    public enum ResolutionStrategy: String, Codable, Sendable { 
        case autorename = "autorename"
        case overwrite = "overwrite"
        case fail = "fail"
    }
    /** List of nodes to be moved */
    public var items: [MoveNode]?
    /** Node conflict resolution strategy: * &#x60;autorename&#x60; * &#x60;overwrite&#x60; * &#x60;fail&#x60;  (default: &#x60;autorename&#x60;) */
    public var resolutionStrategy: ResolutionStrategy?
    /** Preserve Download Share Links and point them to the new node. (default: false) */
    public var keepShareLinks: Bool?

    public init(items: [MoveNode], resolutionStrategy: ResolutionStrategy?, keepShareLinks: Bool?) {
        self.items = items
        self.resolutionStrategy = resolutionStrategy
        self.keepShareLinks = keepShareLinks
    }

}

