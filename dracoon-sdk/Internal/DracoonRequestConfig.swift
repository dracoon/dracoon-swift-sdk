//
//  DracoonRequestConfig.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

struct DracoonRequestConfig {
    let session: Alamofire.Session
    let serverUrl: URL
    let apiPath: String
    let oauthTokenManager: OAuthInterceptor
    let encoder: JSONEncoder
    let decoder: JSONDecoder
}
