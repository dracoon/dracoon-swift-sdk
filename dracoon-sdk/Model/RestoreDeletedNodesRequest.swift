//
// RestoreDeletedNodesRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct RestoreDeletedNodesRequest: Codable, Sendable {

    public enum ResolutionStrategy: String, Codable, Sendable { 
        case autorename = "autorename"
        case overwrite = "overwrite"
        case fail = "fail"
    }
    /** List of deleted node IDs */
    public var deletedNodeIds: [Int64]
    /** Node conflict resolution strategy: * &#x60;autorename&#x60; * &#x60;overwrite&#x60; * &#x60;fail&#x60;  (default: &#x60;autorename&#x60;) */
    public var resolutionStrategy: ResolutionStrategy?
    /** Preserve Download Share Links and point them to the new node. (default: false) */
    public var keepShareLinks: Bool?
    /** Node parent ID (default: previous parent ID) */
    public var parentId: Int64?



}

