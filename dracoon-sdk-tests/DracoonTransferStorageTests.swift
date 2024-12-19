//
//  DracoonTransferStorageTests.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 16.12.24.
//  Copyright © 2024 Dracoon. All rights reserved.
//

import XCTest
import Alamofire
@testable import dracoon_sdk

class DracoonTransferStorageTests: XCTestCase {
    
    var transferStorage: DracoonTransferStorage!
    let testWaiter = XCTWaiter()
    
    override func setUp() {
        super.setUp()
        
        self.transferStorage = DracoonTransferStorage()
    }
    
    func test_storeUpload() {
        let uploadId = "0"
        let testUpload = TestDracoonUpload()
        self.transferStorage.storeUpload(uploadId: uploadId, upload: testUpload)
        
        self.transferStorage.getUpload(uploadId: uploadId, completionHandler: { upload in
            XCTAssert((upload as? TestDracoonUpload) === testUpload)
        })
    }
    
    func test_removeUpload() {
        let uploadId = "0"
        let testUpload = TestDracoonUpload()
        self.transferStorage.storeUpload(uploadId: uploadId, upload: testUpload)
        self.transferStorage.removeUpload(uploadId: uploadId)
        
        self.transferStorage.getUpload(uploadId: uploadId, completionHandler: { upload in
            XCTAssertNil(upload)
        })
    }
    
    func test_getUpload() {
        let uploadId0 = "0"
        let testUpload0 = TestDracoonUpload()
        self.transferStorage.storeUpload(uploadId: uploadId0, upload: testUpload0)
        let uploadId2 = "2"
        let testUpload2 = TestDracoonUpload()
        self.transferStorage.storeUpload(uploadId: uploadId2, upload: testUpload2)
        let uploadId1 = "1"
        let testUpload1 = TestDracoonUpload()
        self.transferStorage.storeUpload(uploadId: uploadId1, upload: testUpload1)
        
        self.transferStorage.getUpload(uploadId: uploadId1, completionHandler: { upload in
            XCTAssert((upload as? TestDracoonUpload) === testUpload1)
        })
        self.transferStorage.getUpload(uploadId: uploadId0, completionHandler: { upload in
            XCTAssert((upload as? TestDracoonUpload) === testUpload0)
        })
        self.transferStorage.getUpload(uploadId: uploadId2, completionHandler: { upload in
            XCTAssert((upload as? TestDracoonUpload) === testUpload2)
        })
    }
    
    func test_storeDownload() {
        let nodeId: Int64 = 42
        let testDownload = self.getTestDownload(nodeId: nodeId)
        self.transferStorage.storeDownload(nodeId: nodeId, download: testDownload)
        
        self.transferStorage.getDownload(nodeId: nodeId, completionHandler: { download in
            XCTAssert(download === testDownload)
        })
    }
    
    func test_removeDownload() {
        let nodeId: Int64 = 42
        let testDownload = self.getTestDownload(nodeId: nodeId)
        self.transferStorage.storeDownload(nodeId: nodeId, download: testDownload)
        self.transferStorage.removeDownload(nodeId: nodeId)
        
        self.transferStorage.getDownload(nodeId: nodeId, completionHandler: { download in
            XCTAssertNil(download)
        })
    }
    
    func test_getDownload() {
        let nodeId0: Int64 = 0
        let testDownload0 = self.getTestDownload(nodeId: nodeId0)
        self.transferStorage.storeDownload(nodeId: nodeId0, download: testDownload0)
        let nodeId2: Int64 = 2
        let testDownload2 = self.getTestDownload(nodeId: nodeId2)
        self.transferStorage.storeDownload(nodeId: nodeId2, download: testDownload2)
        let nodeId1: Int64 = 1
        let testDownload1 = self.getTestDownload(nodeId: nodeId1)
        self.transferStorage.storeDownload(nodeId: nodeId1, download: testDownload1)
        
        self.transferStorage.getDownload(nodeId: nodeId2, completionHandler: { download in
            XCTAssert(download === testDownload2)
        })
        self.transferStorage.getDownload(nodeId: nodeId0, completionHandler: { download in
            XCTAssert(download === testDownload0)
        })
        self.transferStorage.getDownload(nodeId: nodeId1, completionHandler: { download in
            XCTAssert(download === testDownload1)
        })
    }
    
    
    private func getTestDownload(nodeId: Int64) -> FileDownload {
        return FileDownload(nodeId: nodeId,
                            targetUrl: Bundle(for: DracoonTransferStorageTests.self).resourceURL!.appendingPathComponent("testDownload-\(nodeId)"),
                            config: DracoonRequestConfig(session: Session(), serverUrl: URL(string: "dracoon.team")!, apiPath: "test", oauthTokenManager: OAuthTokenManagerMock(authMode: .accessToken(accessToken: "accessToken"), oAuthClient: OAuthClientMock(serverUrl: URL(string: "https://dracoon.team")!)), encoder: JSONEncoder(), decoder: JSONDecoder()), account: DracoonAccountMock(), nodes: DracoonNodesMock(), crypto: DracoonCryptoMock(), fileKey: nil, sessionConfig: nil, getEncryptionPassword: {return ""}, callback: nil)
    }
}

final class TestDracoonUpload: DracoonUpload {
    
    func start() {}
    
    func cancel() {}
    
    func resumeBackgroundUpload() {}
    
}
