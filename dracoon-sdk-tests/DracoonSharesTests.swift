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
        
        self.shares = DracoonSharesImpl(requestConfig: requestConfig, nodes: DracoonNodesMock(), account: DracoonAccountMock(), server: DracoonServerMock(), getEncryptionPassword: {
            return "encryptionPassword"
        })
    }
    
    override func tearDown() {
        super.tearDown()
        
        (self.shares.nodes as! DracoonNodesMock).nodeIsEncrypted = false
    }
    
    func testCreateDownloadShare() {
        
        self.setResponseModel(DownloadShare.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns DownloadShare")
        let testState = TestState()
        
        self.shares.createDownloadShare(nodeId: 1337, password: nil, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testCreateEncryptedDownloadShare() {
        
        (self.shares.nodes as! DracoonNodesMock).nodeIsEncrypted = true
        self.setResponseModel(DownloadShare.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns DownloadShare")
        let testState = TestState()
        
        self.shares.createDownloadShare(nodeId: 1337, password: "sharePassword", completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testCreateEncryptedDownloadShare_withoutPassword_returnsError() {
        
        (self.shares.nodes as! DracoonNodesMock).nodeIsEncrypted = true
        let expectation = XCTestExpectation(description: "Returns Error")
        let testState = TestState()
        
        self.shares.createDownloadShare(nodeId: 1337, password: nil, completion: { result in
            switch result {
            case .error(let error):
                switch error {
                case .encrypted_share_no_password_provided:
                    testState.onErrorCalled = true
                    expectation.fulfill()
                default:
                    break
                }
            case .value(_):
                break
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    func testGetDownloadShares_withNodeId() {
        
        self.setResponseModel(DownloadShareList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns DownloadShareList")
        let testState = TestState()
        
        self.shares.getDownloadShares(nodeId: 42, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testGetDownloadShares() {
        self.setResponseModel(DownloadShareList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns DownloadShareList")
        let testState = TestState()
        
        self.shares.getDownloadShares(offset: nil, limit: nil, filter: nil, sorting: nil, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testGetDownloadShareQrCode() {
        
        self.setResponseModel(DownloadShare.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns DownloadShare")
        let testState = TestState()
        
        self.shares.getDownloadShareQrCode(shareId: 42, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testDeleteDownloadShare() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        let testState = TestState()
        testState.onErrorCalled = true
        
        self.shares.deleteDownloadShare(shareId: 42, completion: { response in
            if response.error == nil {
                testState.onErrorCalled = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(testState.onErrorCalled)
    }
    
    func testDeleteDownloadShare_withUnknownId_returnsError() {
        
        MockURLProtocol.response(with: 404)
        let expectation = XCTestExpectation(description: "Returns error")
        let testState = TestState()
        
        self.shares.deleteDownloadShare(shareId: 43, completion: { response in
            if response.error != nil {
                testState.onErrorCalled = true
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    func testDeleteDownloadShares() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        let testState = TestState()
        testState.onErrorCalled = true
        
        self.shares.deleteDownloadShares(shareIds: [41,42], completion: { response in
            if response.error == nil {
                testState.onErrorCalled = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(testState.onErrorCalled)
    }
    
    func testDeleteDownloadShares_withUnknownId_returnsError() {
        
        MockURLProtocol.response(with: 404)
        let expectation = XCTestExpectation(description: "Returns error")
        let testState = TestState()
        
        self.shares.deleteDownloadShares(shareIds: [43, 44], completion: { response in
            if response.error != nil {
                testState.onErrorCalled = true
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    func testCreateUploadShare() {
        
        self.setResponseModel(UploadShare.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns UploadShare")
        let testState = TestState()
        
        self.shares.createUploadShare(nodeId: 42, name: "name", password: nil, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testGetUploadShares_withNodeId() {
        
        self.setResponseModel(UploadShareList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns UploadShareList")
        let testState = TestState()
        
        self.shares.getUploadShares(nodeId: 42, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testGetUploadShares() {
        
        self.setResponseModel(UploadShareList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns UploadShareList")
        let testState = TestState()
        
        self.shares.getUploadShares(offset: nil, limit: nil, filter: nil, sorting: nil, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testGetUploadShareQrCode() {
        
        self.setResponseModel(UploadShare.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns UploadShare")
        let testState = TestState()
        
        self.shares.getUploadShareQrCode(shareId: 42, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                testState.onValueCalled = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onValueCalled)
    }
    
    func testDeleteUploadShare() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        let testState = TestState()
        testState.onErrorCalled = true
        
        self.shares.deleteUploadShare(shareId: 42, completion: { response in
            if response.error == nil {
                testState.onErrorCalled = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(testState.onErrorCalled)
    }
    
    func testDeleteUploadShare_withUnknownId_returnsError() {
        
        MockURLProtocol.response(with: 404)
        let expectation = XCTestExpectation(description: "Returns error")
        let testState = TestState()
        
        self.shares.deleteUploadShare(shareId: 43, completion: { response in
            if response.error != nil {
                testState.onErrorCalled = true
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }
    
    func testDeleteUploadShares() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        let testState = TestState()
        testState.onErrorCalled = true
        
        self.shares.deleteUploadShares(shareIds: [41,42], completion: { response in
            if response.error == nil {
                testState.onErrorCalled = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(testState.onErrorCalled)
    }
    
    func testDeleteUploadShares_withUnknownId_returnsError() {
        
        MockURLProtocol.response(with: 404)
        let expectation = XCTestExpectation(description: "Returns error")
        let testState = TestState()
        
        self.shares.deleteUploadShares(shareIds: [43, 44], completion: { response in
            if response.error != nil {
                testState.onErrorCalled = true
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(testState.onErrorCalled)
    }

}
