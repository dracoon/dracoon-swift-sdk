//
//  AttributesResponse.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 18.11.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

public struct AttributesResponse: Codable, Sendable {
    
    public var range: ModelRange
    public var items: [KeyValueEntry]
}
