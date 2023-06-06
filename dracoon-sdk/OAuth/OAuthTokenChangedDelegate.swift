//
//  OAuthTokenChangedDelegate.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

/// - Tag: OAuthTokenChangedDelegate
public protocol OAuthTokenChangedDelegate: AnyObject {
    func tokenChanged(accessToken: String, refreshToken: String)
    func tokenRefreshFailed(error: DracoonError)
    func tokenRevocationResult(error: DracoonError?)
}

extension OAuthTokenChangedDelegate {
    // make optional to implement
    func tokenRevocationResult(error: DracoonError?) {}
}
