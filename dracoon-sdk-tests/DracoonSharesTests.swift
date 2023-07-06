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
        var calledValue = false
        
        self.shares.createDownloadShare(nodeId: 1337, password: nil, completion: { result in
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
    
    func testCreateEncryptedDownloadShare() {
        
        (self.shares.nodes as! DracoonNodesMock).nodeIsEncrypted = true
        self.setResponseModel(DownloadShare.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns DownloadShare")
        var calledValue = false
        
        self.shares.createDownloadShare(nodeId: 1337, password: "sharePassword", completion: { result in
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
    
    func testCreateEncryptedDownloadShare_withoutPassword_returnsError() {
        
        (self.shares.nodes as! DracoonNodesMock).nodeIsEncrypted = true
        let expectation = XCTestExpectation(description: "Returns Error")
        var calledError = false
        
        self.shares.createDownloadShare(nodeId: 1337, password: nil, completion: { result in
            switch result {
            case .error(let error):
                switch error {
                case .encrypted_share_no_password_provided:
                    calledError = true
                    expectation.fulfill()
                default:
                    break
                }
            case .value(_):
                break
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledError)
    }
    
    func testGetDownloadShares_withNodeId() {
        
        self.setResponseModel(DownloadShareList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns DownloadShareList")
        var calledValue = false
        
        self.shares.getDownloadShares(nodeId: 42, completion: { result in
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
    
    func testGetDownloadShares() {
        self.setResponseModel(DownloadShareList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns DownloadShareList")
        var calledValue = false
        
        self.shares.getDownloadShares(offset: nil, limit: nil, filter: nil, sorting: nil, completion: { result in
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
    
    func testGetDownloadShareQrCode() {
        
        self.setResponseModel(DownloadShare.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns DownloadShare")
        var calledValue = false
        
        self.shares.getDownloadShareQrCode(shareId: 42, completion: { result in
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
    
    func testDeleteDownloadShare() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        self.shares.deleteDownloadShare(shareId: 42, completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
    func testDeleteDownloadShare_withUnknownId_returnsError() {
        
        MockURLProtocol.response(with: 404)
        let expectation = XCTestExpectation(description: "Returns error")
        var calledError = false
        
        self.shares.deleteDownloadShare(shareId: 43, completion: { response in
            if response.error != nil {
                calledError = true
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledError)
    }
    
    func testDeleteDownloadShares() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        self.shares.deleteDownloadShares(shareIds: [41,42], completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
    func testDeleteDownloadShares_withUnknownId_returnsError() {
        
        MockURLProtocol.response(with: 404)
        let expectation = XCTestExpectation(description: "Returns error")
        var calledError = false
        
        self.shares.deleteDownloadShares(shareIds: [43, 44], completion: { response in
            if response.error != nil {
                calledError = true
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledError)
    }
    
    func testCreateUploadShare() {
        
        self.setResponseModel(UploadShare.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns UploadShare")
        var calledValue = false
        
        self.shares.createUploadShare(nodeId: 42, name: "name", password: nil, completion: { result in
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
    
    func testGetUploadShares_withNodeId() {
        
        self.setResponseModel(UploadShareList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns UploadShareList")
        var calledValue = false
        
        self.shares.getUploadShares(nodeId: 42, completion: { result in
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
    
    func testGetUploadShares() {
        
        self.setResponseModel(UploadShareList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns UploadShareList")
        var calledValue = false
        
        self.shares.getUploadShares(offset: nil, limit: nil, filter: nil, sorting: nil, completion: { result in
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
    
    func testGetUploadShareQrCode() {
        
        self.setResponseModel(UploadShare.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns UploadShare")
        var calledValue = false
        
        self.shares.getUploadShareQrCode(shareId: 42, completion: { result in
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
    
    func testDeleteUploadShare() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        self.shares.deleteUploadShare(shareId: 42, completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
    func testDeleteUploadShare_withUnknownId_returnsError() {
        
        MockURLProtocol.response(with: 404)
        let expectation = XCTestExpectation(description: "Returns error")
        var calledError = false
        
        self.shares.deleteUploadShare(shareId: 43, completion: { response in
            if response.error != nil {
                calledError = true
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledError)
    }
    
    func testDeleteUploadShares() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        self.shares.deleteUploadShares(shareIds: [41,42], completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
    func testDeleteUploadShares_withUnknownId_returnsError() {
        
        MockURLProtocol.response(with: 404)
        let expectation = XCTestExpectation(description: "Returns error")
        var calledError = false
        
        self.shares.deleteUploadShares(shareIds: [43, 44], completion: { response in
            if response.error != nil {
                calledError = true
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledError)
    }

}
