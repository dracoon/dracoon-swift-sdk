//
//  ClassificationPoliciesConfig.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 11.08.21.
//  Copyright © 2021 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: ClassificationPoliciesConfig
public struct ClassificationPoliciesConfig: Codable {
    
    /** Shares classification policies [Since 4.30.0] */
    public var shareClassificationPolicies: ShareClassificationPolicies?
}
