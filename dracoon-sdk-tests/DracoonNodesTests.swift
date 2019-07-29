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
    
    func testGetNode_returnsNode() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns node")
        self.nodes.getNode(nodeId: 42, completion: { result in
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
    
//    func testGetNodeWithPath_returnsNode() {
//
//        self.setResponseModel(Node.self, statusCode: 200)
//
//        let expectation = XCTestExpectation(description: "Returns Node")
//        self.nodes.getNode(nodePath: "/test/", completion: { result in
//            switch result {
//            case .error(let error):
//                XCTFail()
//            case.value(let response):
//                XCTAssertNotNil(response)
//                expectation.fulfill()
//            }
//
//        })
//
//        XCTWaiter().wait(for: [expectation], timeout: 2.0)
//    }
    
    // MARK: Rooms
    
    func testCreateRoom() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns node")
        let request = CreateRoomRequest(name: "TestRoom")
        self.nodes.createRoom(request: request, completion: { result in
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
    
    func testUpdateRoom() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns node")
        let request = UpdateRoomRequest()
        self.nodes.updateRoom(roomId: 42, request: request, completion: { result in
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
    
    // MARK: Folders
    
    func testCreateFolder() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns node")
        let request = CreateFolderRequest(parentId: 42, name: "TestFolder")
        self.nodes.createFolder(request: request, completion: { result in
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
    
    func testUpdateFolder() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns node")
        let request = UpdateFolderRequest()
        self.nodes.updateFolder(folderId: 42, request: request, completion: { result in
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
    
    // MARK: Files
    
    func testUpdateFile() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns node")
        let request = UpdateFileRequest()
        self.nodes.updateFile(fileId: 42, request: request, completion: { result in
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
    
    func testDeleteNodes() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        let request = DeleteNodesRequest(nodeIds: [41, 42])
        self.nodes.deleteNodes(request: request, completion: { response in
            if response.error != nil {
                XCTFail()
            } else {
                expectation.fulfill()
            }
        })
        
        XCTWaiter().wait(for: [expectation], timeout: 2.0)
    }
    
    func testCopyNodes() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns node")
        let request = CopyNodesRequest(items: [CopyNode(nodeId: 42, name: "testNode")], resolutionStrategy: .autorename, keepShareLinks: true)
        self.nodes.copyNodes(nodeId: 43, request: request, completion: { result in
            switch result {
            case .error(_):
                XCTFail()
            case .value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        XCTWaiter().wait(for: [expectation], timeout: 2.0)
    }
    
    func testMoveNodes() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns node")
        let request = MoveNodesRequest(items: [MoveNode(nodeId: 42, name: "testNode")], resolutionStrategy: .autorename, keepShareLinks: true)
        self.nodes.moveNodes(nodeId: 43, request: request, completion: { result in
            switch result {
            case .error(_):
                XCTFail()
            case .value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        XCTWaiter().wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: Upload
    
    func testUpload() {
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "upload")
        let uploadCallback = UploadCallback()
        uploadCallback.onComplete = { node in
            
        }
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: URL(string:"/")!, callback: uploadCallback)
    }
    
    // MARK: Search nodes
    
    func testSearchNodes() {
        
        self.setResponseModel(NodeList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns NodeList")
        
        self.nodes.searchNodes(parentNodeId: 42, searchString: "searchString", offset: nil, limit: nil, completion: { result in
            switch result {
            case .error(_):
                XCTFail()
            case .value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        XCTWaiter().wait(for: [expectation], timeout: 2.0)
    }
    
    func testSearchNodesWithDepth() {
        
        self.setResponseModel(NodeList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns NodeList")
        
        self.nodes.searchNodes(parentNodeId: 42, searchString: "searchString", depthLevel: 0, filter: nil, offset: nil, limit: nil, completion: { result in
            switch result {
            case .error(_):
                XCTFail()
            case .value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
        
        XCTWaiter().wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: Favourites
    
    func testGetFavourites() {
        
        self.setResponseModel(NodeList.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns NodeList")
        
        self.nodes.getFavorites(completion: {
            result in
            switch result {
            case .error(_):
                XCTFail()
            case .value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
    }
    
    func testSetFavourites() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        let expectation = XCTestExpectation(description: "Returns node")
        
        self.nodes.setFavorite(nodeId: 42, completion: { result in
            switch result {
            case .error(_):
                XCTFail()
            case .value(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            }
        })
    }
    
    func testDeleteFavourite() {
        
        MockURLProtocol.response(with: 204)
        let expectation = XCTestExpectation(description: "Returns without error")
        
        self.nodes.removeFavorite(nodeId: 42, completion: { response in
            if response.error != nil {
                XCTFail()
            } else {
                expectation.fulfill()
            }
        })
    }
    
}

extension Node {
    
    init(_id: Int64, type: ModelType, name: String, _ customize: ((inout Node) -> Void)? = nil) {
        self.init(_id: _id, type: type, name: name, parentId: nil, parentPath: nil, createdAt: nil, createdBy: nil, updatedAt: nil, updatedBy: nil, expireAt: nil, hash: nil, fileType: nil, mediaType: nil, size: nil, classification: nil, notes: nil, permissions: nil, isEncrypted: nil, cntChildren: nil, cntDeletedVersions: nil, hasRecycleBin: nil, recycleBinRetentionPeriod: nil, quota: nil, cntDownloadShares: nil, cntUploadShares: nil, isFavorite: nil, inheritPermissions: nil, encryptionInfo: nil, branchVersion: nil, mediaToken: nil, s3Key: nil, hasActivitiesLog: nil, children: nil, cntAdmins: nil, cntUsers: nil)
        customize?(&self)
    }
}
