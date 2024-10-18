//
//  RateLimitAppliedDelegate.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 07.07.21.
//  Copyright © 2021 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: RateLimitAppliedDelegate
public protocol RateLimitAppliedDelegate: AnyObject, Sendable {
    func rateLimitApplied(expirationDate: Date)
}
