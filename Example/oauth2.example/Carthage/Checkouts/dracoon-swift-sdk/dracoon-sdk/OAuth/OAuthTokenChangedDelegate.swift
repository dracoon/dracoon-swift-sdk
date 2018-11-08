//
//  OAuthTokenChangedDelegate.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

public protocol OAuthTokenChangedDelegate: class {
    func tokenChanged(accessToken: String, refreshToken: String)
}
