//
//  ProfileAttributesRequest.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 18.11.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: ProfileAttributesRequest
public struct ProfileAttributesRequest: Codable {
    
    public var items: [KeyValueEntry]
}
