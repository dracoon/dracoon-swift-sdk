//
//  DeleteDownloadSharesRequest.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 10.05.23.
//  Copyright © 2023 Dracoon. All rights reserved.
//

import Foundation

struct DeleteDownloadSharesRequest: Codable, Sendable {
    
    public var shareIds: [Int64]
    
    public init(shareIds: [Int64]) {
        self.shareIds = shareIds
    }
    
}
