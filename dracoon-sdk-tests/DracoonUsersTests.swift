//
//  DracoonUsersTests.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 08.02.21.
//  Copyright © 2021 Dracoon. All rights reserved.
//

import XCTest
import Alamofire
@testable import dracoon_sdk

class DracoonUsersTests: DracoonSdkTestCase {
    
    var users: DracoonUsersImpl!
    
    override func setUp() {
        super.setUp()
        self.users = DracoonUsersImpl(config: requestConfig)
    }
    
    func testDownloadAvatar() {
        
        let targetUrl = Bundle(for: DracoonUsersTests.self).resourceURL!.appendingPathComponent("testUpload")
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        self.users.downloadUserAvatar(userId: 42, avatarUuid: "testUuid", targetUrl: targetUrl, completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
    func testDownloadAvatar_downloadFails_retunsError() {
        
        let targetUrl = Bundle(for: DracoonUsersTests.self).resourceURL!.appendingPathComponent("testUpload")
        let expectation = XCTestExpectation(description: "Returns error")
        MockURLProtocol.responseWithError(NSError(domain: "SDKTest", code: NSURLErrorNotConnectedToInternet, userInfo: nil), statusCode: 400)
        var calledError = false
        
        self.users.downloadUserAvatar(userId: 42, avatarUuid: "testUuid", targetUrl: targetUrl, completion: { response in
            if response.error != nil {
                calledError = true
                expectation.fulfill()
            }
        })
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledError)
    }
}
