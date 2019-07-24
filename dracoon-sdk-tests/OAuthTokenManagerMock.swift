//
//  OAuthTokenManagerMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 24.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
@testable import dracoon_sdk

class OAuthTokenManagerMock: OAuthInterceptor {
    
    init() {
        let authMode = DracoonAuthMode.accessToken(accessToken: "mock")
        let oAuthClient = OAuthClientMock(serverUrl: URL(string: "https://dracoon.team")!)
        super.init(authMode: authMode, oAuthClient: oAuthClient)
    }
}
