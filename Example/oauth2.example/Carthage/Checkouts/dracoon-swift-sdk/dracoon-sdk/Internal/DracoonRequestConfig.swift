//
//  DracoonRequestConfig.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

struct DracoonRequestConfig {
    let sessionManager: Alamofire.SessionManager
    let serverUrl: URL
    let apiPath: String
    let oauthTokenManager: OAuthTokenManager
    let encoder: JSONEncoder
    let decoder: JSONDecoder
}
