//
//  DracoonSharesTests.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 30.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import XCTest
import crypto_sdk
import Alamofire
@testable import dracoon_sdk

class DracoonSharesTests: DracoonSdkTestCase {
    
    var shares: DracoonSharesImpl!
    
    override func setUp() {
        super.setUp()
        
        self.shares = DracoonSharesImpl(config: requestConfig, nodes: DracoonNodesMock(), account: DracoonAccountMock(), getEncryptionPassword: {
            return ""
        })
    }

}
