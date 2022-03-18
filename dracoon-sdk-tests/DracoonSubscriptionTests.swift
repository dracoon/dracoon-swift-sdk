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
        var calledValue = false
        
        self.subscriptions.getNodeSubscriptions(filter: nil, limit: nil, offset: nil, sort: nil, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testUpdateNodeSubscriptions() {
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        self.subscriptions.updateNodeSubscriptions(subscribe: false, nodeIds: [42], completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
    func testSubscribeNode() {
        self.setResponseModel(SubscribedNode.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SubscribedNode")
        var calledValue = false
        
        self.subscriptions.subscribeNode(nodeId: 42, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testUnsubscribeNode() {
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        self.subscriptions.unsubscribeNode(nodeId: 42, completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
    func testGetDownloadShareSubscriptions() {
        self.setResponseModel(SubscribedDownloadShareList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SubscribedDownloadShareList")
        var calledValue = false
        
        self.subscriptions.getDownloadShareSubscriptions(filter: nil, limit: nil, offset: nil, sort: nil, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testUpdateDownloadShareSubscriptions() {
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        self.subscriptions.updateDownloadShareSubscriptions(subscribe: false, shareIds: [42], completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
    func testSubscribeDownloadShare() {
        self.setResponseModel(SubscribedDownloadShare.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SubscribedDownloadShare")
        var calledValue = false
        
        self.subscriptions.subscribeDownloadShare(shareId: 42, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testUnsubscribeDownloadShare() {
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        self.subscriptions.unsubscribeDownloadShare(shareId: 42, completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
    func testGetUploadShareSubscriptions() {
        self.setResponseModel(SubscribedUploadShareList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SubscribedUploadShareList")
        var calledValue = false
        
        self.subscriptions.getUploadShareSubscriptions(filter: nil, limit: nil, offset: nil, sort: nil, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testUpdateUploadShareSubscriptions() {
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        self.subscriptions.updateUploadShareSubscriptions(subscribe: false, shareIds: [42], completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
    func testSubscribeUploadShare() {
        self.setResponseModel(SubscribedUploadShare.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns SubscribedUploadShare")
        var calledValue = false
        
        self.subscriptions.subscribeUploadShare(shareId: 42, completion: { result in
            switch result {
            case .error(_):
                break
            case .value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testUnsubscribeUploadShare() {
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        self.subscriptions.unsubscribeUploadShare(shareId: 42, completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
}
