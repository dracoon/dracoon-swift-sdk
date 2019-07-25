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

class DracoonNodesTests: DracoonSdkTestCase {
    
    var nodes: DracoonNodesImpl!
    var encryptionPassword = "encryptionPassword"
    
    override func setUp() {
        super.setUp()
        
        self.nodes = DracoonNodesImpl(config: self.requestConfig, crypto: self.crypto, account: DracoonAccountMock(), getEncryptionPassword: {
            return self.encryptionPassword
        })
    }
    
    func testGetNodes() {
        
        self.setResponseModel(NodeList.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns NodeListModel")
        self.nodes.getNodes(parentNodeId: 0, limit: nil, offset: nil, completion: { result in
            switch result {
            case .error(_):
                XCTFail()
            case.value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        XCTWaiter().wait(for: [expectation], timeout: 2.0)
    }
    
}
