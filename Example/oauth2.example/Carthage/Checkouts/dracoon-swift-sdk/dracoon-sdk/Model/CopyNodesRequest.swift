//
// CopyNodesRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

public struct CopyNodesRequest: Codable {

    public enum ResolutionStrategy: String, Codable { 
        case autorename = "autorename"
        case overwrite = "overwrite"
        case fail = "fail"
    }
    /** List of nodes to be copied */
    public var items: [CopyNode]?
    /** Node conflict resolution strategy: * &#x60;autorename&#x60; * &#x60;overwrite&#x60; * &#x60;fail&#x60;  (default: &#x60;autorename&#x60;) */
    public var resolutionStrategy: ResolutionStrategy?
    /** Preserve Download Share Links and point them to the new node. (default: false) */
    public var keepShareLinks: Bool?
    /** &#x60;DEPRECATED&#x60;: Node IDs; use &#x60;items&#x60; attribute */
    public var nodeIds: [Int64]?


    public init(items: [CopyNode], resolutionStrategy: ResolutionStrategy?, keepShareLinks: Bool?) {
        self.items = items
        self.resolutionStrategy = resolutionStrategy
        self.keepShareLinks = keepShareLinks
    }

}

