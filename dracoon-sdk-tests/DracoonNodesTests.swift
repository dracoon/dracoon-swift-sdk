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
    
    // MARK: Nodes
    
    func testGetNodes_retunsNodeList() {
        
        self.setResponseModel(NodeList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns NodeList")
        var calledValue = false
        
        self.nodes.getNodes(parentNodeId: 0, limit: nil, offset: nil, completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testGetNode_returnsNode() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns Node")
        var calledValue = false
        
        self.nodes.getNode(nodeId: 42, completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testGetNodeWithPath_returnsNode() {

        self.setResponseModel(NodeList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns NodeList")
        var calledValue = false
        
        self.nodes.getNode(nodePath: "/root/name", completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }

        })

        XCTWaiter().wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    // MARK: Rooms
    
    func testCreateRoom() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns node")
        var calledValue = false
        
        let request = CreateRoomRequest(name: "TestRoom")
        self.nodes.createRoom(request: request, completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testUpdateRoom() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns node")
        var calledValue = false
        
        let request = UpdateRoomRequest()
        self.nodes.updateRoom(roomId: 42, request: request, completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    // MARK: Folders
    
    func testCreateFolder() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns node")
        var calledValue = false
        
        let request = CreateFolderRequest(parentId: 42, name: "TestFolder")
        self.nodes.createFolder(request: request, completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
            
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testUpdateFolder() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns node")
        var calledValue = false
        
        let request = UpdateFolderRequest()
        self.nodes.updateFolder(folderId: 42, request: request, completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    // MARK: Files
    
    func testUpdateFile() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns node")
        var calledValue = false
        
        let request = UpdateFileRequest()
        self.nodes.updateFile(fileId: 42, request: request, completion: { result in
            switch result {
            case .error(_):
                break
            case.value(let response):
                calledValue = true
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(calledValue)
    }
    
    func testDeleteNodes() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        let request = DeleteNodesRequest(nodeIds: [41, 42])
        self.nodes.deleteNodes(request: request, completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
    func testCopyNodes() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns node")
        var calledValue = false
        
        let request = CopyNodesRequest(items: [CopyNode(nodeId: 42, name: "testNode")], resolutionStrategy: .autorename, keepShareLinks: true)
        self.nodes.copyNodes(nodeId: 43, request: request, completion: { result in
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
    
    func testMoveNodes() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns node")
        var calledValue = false
        
        let request = MoveNodesRequest(items: [MoveNode(nodeId: 42, name: "testNode")], resolutionStrategy: .autorename, keepShareLinks: true)
        self.nodes.moveNodes(nodeId: 43, request: request, completion: { result in
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
    
    // MARK: Upload
    
    func testUpload_succeeds_callsOnComplete() {

        self.setResponseModel(Node.self, statusCode: 200)
        self.setResponseModel(CreateFileUploadResponse.self, statusCode: 200)
        self.setResponseModel(Node.self, statusCode: 200) // TODO set upload response
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "upload")
        var calledOnComplete = false
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "Calls onComplete")
        
        let uploadCallback = UploadCallback()
        uploadCallback.onStarted = { _ in
            print("started")
        }
        uploadCallback.onError = { error in
            print(error)
            XCTFail()
        }
        uploadCallback.onCanceled = {
            print("canceled")
            XCTFail()
        }
        uploadCallback.onProgress = { progress in
            print("upload progress \(progress)")
        }
        uploadCallback.onComplete = { node in
            print("completed")
            calledOnComplete = true
            expectation.fulfill()
        }
        
        let url = Bundle(for: FileDownload.self).resourceURL!.appendingPathComponent("testUpload")
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback)
        
        self.testWaiter.wait(for: [expectation], timeout: 4.0)
        XCTAssertTrue(calledOnComplete)
    }
    
    func testUpload() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        self.setResponseModel(CreateFileUploadResponse.self, statusCode: 200)
        let error = NSError(domain: "SDKTest", code: -10006, userInfo: nil)
        MockURLProtocol.responseWithError(error, statusCode: 401)
        let expectation = XCTestExpectation(description: "Returns error")
        var calledOnError = false
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "upload")
        
        let uploadCallback = UploadCallback()
        uploadCallback.onStarted = { _ in
            print("started")
        }
        uploadCallback.onError = { error in
            print(error)
            calledOnError = true
            expectation.fulfill()
        }
        uploadCallback.onCanceled = {
            print("canceled")
            XCTFail()
        }
        uploadCallback.onProgress = { progress in
            print("upload progress \(progress)")
        }
        uploadCallback.onComplete = { node in
            print("completed")
            XCTFail()
        }
        
        let url = Bundle(for: FileDownload.self).resourceURL!.appendingPathComponent("testUpload")
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback)
        
        self.testWaiter.wait(for: [expectation], timeout: 4.0)
        XCTAssertTrue(calledOnError)
    }
    
    // MARK: Download
    
    func testDownload_succeeds_callsOnComplete() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        self.setResponseModel(DownloadTokenGenerateResponse.self, statusCode: 200)
        let urlRequest = URLRequest(url: URL(string: "https://dracoon.team")!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: TimeInterval())
        let httpUrlResponse = HTTPURLResponse(url: URL(string: "https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let url = Bundle(for: FileDownload.self).resourceURL!.appendingPathComponent("testDownload")
        let downloadResponse = DefaultDownloadResponse(request: urlRequest, response: httpUrlResponse, temporaryURL: url, destinationURL: url, resumeData: nil, error: nil)
        MockURLProtocol.response(with: downloadResponse, statusCode: 200)
        let expectation = XCTestExpectation(description: "Calls onComplete")
        var calledOnComplete = false
        
        let callback = DownloadCallback()
        callback.onError = { error in
            print(error)
            XCTFail()
        }
        callback.onProgress = { progress in
            print("download progress \(progress)")
        }
        callback.onCanceled = {
            XCTFail()
        }
        callback.onComplete = { _ in
            calledOnComplete = true
            expectation.fulfill()
        }
        
        self.nodes.downloadFile(nodeId: 42, targetUrl: url, callback: callback)
        
        self.testWaiter.wait(for: [expectation], timeout: 4.0)
        XCTAssertTrue(calledOnComplete)
    }
    
    // MARK: Search nodes
    
    func testSearchNodes() {
        
        self.setResponseModel(NodeList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns NodeList")
        var calledValue = false
        
        self.nodes.searchNodes(parentNodeId: 42, searchString: "searchString", offset: nil, limit: nil, completion: { result in
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
    
    func testSearchNodesWithDepth() {
        
        self.setResponseModel(NodeList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns NodeList")
        var calledValue = false
        
        self.nodes.searchNodes(parentNodeId: 42, searchString: "searchString", depthLevel: 0, filter: nil, offset: nil, limit: nil, completion: { result in
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
    
    // MARK: Favourites
    
    func testGetFavourites() {
        
        self.setResponseModel(NodeList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns NodeList")
        var calledValue = false
        
        self.nodes.getFavorites(completion: {
            result in
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
    
    func testSetFavourites() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns node")
        var calledValue = false
        
        self.nodes.setFavorite(nodeId: 42, completion: { result in
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
    
    func testDeleteFavourite() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        var calledError = true
        
        self.nodes.removeFavorite(nodeId: 42, completion: { response in
            if response.error == nil {
                calledError = false
                expectation.fulfill()
            }
        })
        
        self.testWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(calledError)
    }
    
}

extension Node {
    
    init(_id: Int64, type: ModelType, name: String, _ customize: ((inout Node) -> Void)? = nil) {
        self.init(_id: _id, type: type, name: name, parentId: nil, parentPath: nil, createdAt: nil, createdBy: nil, updatedAt: nil, updatedBy: nil, expireAt: nil, hash: nil, fileType: nil, mediaType: nil, size: nil, classification: nil, notes: nil, permissions: nil, isEncrypted: nil, cntChildren: nil, cntDeletedVersions: nil, hasRecycleBin: nil, recycleBinRetentionPeriod: nil, quota: nil, cntDownloadShares: nil, cntUploadShares: nil, isFavorite: nil, inheritPermissions: nil, encryptionInfo: nil, branchVersion: nil, mediaToken: nil, s3Key: nil, hasActivitiesLog: nil, children: nil, cntAdmins: nil, cntUsers: nil)
        customize?(&self)
    }
}
