//
//  ShareClassificationPolicies.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 11.08.21.
//  Copyright © 2021 Dracoon. All rights reserved.
//

import Foundation

import Foundation

public struct ShareClassificationPolicies: Codable {
    
    /**
     Minimum classification that causes download shares to require a password. 0 means no password will be enforced.
     Enum: [ 0, 1, 2, 3, 4 ]
     [Since 4.30.0]
     */
    public var classificationRequiresSharePassword: Int
}
