//
//  DracoonSubscriptionTests.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 17.03.22.
//  Copyright © 2022 Dracoon. All rights reserved.
//

import XCTest
import Alamofire
@testable import dracoon_sdk

class DracoonSubscriptionTests: DracoonSdkTestCase {
    
    var subscriptions: DracoonSubscriptionsImpl!
    
    override func setUp() {
        super.setUp()
        
        self.subscriptions = DracoonSubscriptionsImpl(config: requestConfig)
    }
    
    func testGetNodeSubscriptions() {
        self.setResponseModel(SubscribedNodeList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SubscribedNodeList")
        let testState = TestState()
        
        self.subscriptions.getNodeSubscriptions(filter: nil, limit: nil, offset: nil, sort: nil, completion: { result in
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
    
    func testUpdateNodeSubscriptions() {
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        let testState = TestState()
        
        self.subscriptions.updateNodeSubscriptions(subscribe: false, nodeIds: [42], completion: { response in
            if response.error == nil {
                testState.onErrorCalled = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(testState.onErrorCalled)
    }
    
    func testSubscribeNode() {
        self.setResponseModel(SubscribedNode.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SubscribedNode")
        let testState = TestState()
        
        self.subscriptions.subscribeNode(nodeId: 42, completion: { result in
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
    
    func testUnsubscribeNode() {
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        let testState = TestState()
        testState.onErrorCalled = true
        
        self.subscriptions.unsubscribeNode(nodeId: 42, completion: { response in
            if response.error == nil {
                testState.onErrorCalled = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(testState.onErrorCalled)
    }
    
    func testGetDownloadShareSubscriptions() {
        self.setResponseModel(SubscribedDownloadShareList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SubscribedDownloadShareList")
        let testState = TestState()
        
        self.subscriptions.getDownloadShareSubscriptions(filter: nil, limit: nil, offset: nil, sort: nil, completion: { result in
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
    
    func testUpdateDownloadShareSubscriptions() {
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        let testState = TestState()
        testState.onErrorCalled = true
        
        self.subscriptions.updateDownloadShareSubscriptions(subscribe: false, shareIds: [42], completion: { response in
            if response.error == nil {
                testState.onErrorCalled = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(testState.onErrorCalled)
    }
    
    func testSubscribeDownloadShare() {
        self.setResponseModel(SubscribedDownloadShare.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SubscribedDownloadShare")
        let testState = TestState()
        
        self.subscriptions.subscribeDownloadShare(shareId: 42, completion: { result in
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
    
    func testUnsubscribeDownloadShare() {
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        let testState = TestState()
        testState.onErrorCalled = true
        
        self.subscriptions.unsubscribeDownloadShare(shareId: 42, completion: { response in
            if response.error == nil {
                testState.onErrorCalled = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(testState.onErrorCalled)
    }
    
    func testGetUploadShareSubscriptions() {
        self.setResponseModel(SubscribedUploadShareList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SubscribedUploadShareList")
        let testState = TestState()
        
        self.subscriptions.getUploadShareSubscriptions(filter: nil, limit: nil, offset: nil, sort: nil, completion: { result in
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
    
    func testUpdateUploadShareSubscriptions() {
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        let testState = TestState()
        testState.onErrorCalled = true
        
        self.subscriptions.updateUploadShareSubscriptions(subscribe: false, shareIds: [42], completion: { response in
            if response.error == nil {
                testState.onErrorCalled = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(testState.onErrorCalled)
    }
    
    func testSubscribeUploadShare() {
        self.setResponseModel(SubscribedUploadShare.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SubscribedUploadShare")
        let testState = TestState()
        
        self.subscriptions.subscribeUploadShare(shareId: 42, completion: { result in
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
    
    func testUnsubscribeUploadShare() {
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        let testState = TestState()
        testState.onErrorCalled = true
        
        self.subscriptions.unsubscribeUploadShare(shareId: 42, completion: { response in
            if response.error == nil {
                testState.onErrorCalled = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(testState.onErrorCalled)
    }
    
}
