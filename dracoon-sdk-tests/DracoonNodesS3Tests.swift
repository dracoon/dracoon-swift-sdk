//
//  DracoonNodesTests.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 25.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import XCTest
import crypto_sdk
import Alamofire
@testable import dracoon_sdk

class DracoonNodesS3Tests: DracoonSdkTestCase {
    
    var nodes: DracoonNodesImpl!
    var encryptionPassword = "encryptionPassword"
    
    override func setUp() {
        super.setUp()
        
        self.nodes = DracoonNodesImpl(requestConfig: self.requestConfig, crypto: self.crypto, account: DracoonAccountMock(), config: DracoonConfigMock(), getEncryptionPassword: {
            return self.encryptionPassword
        })
    }
    
    // MARK: S3 Upload
    
    
}
