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
    
    func testUpload_succeeds_callsOnComplete() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        self.setResponseModel(CreateFileUploadResponse.self, statusCode: 200)
        self.setResponseModel(PresignedUrlList.self, statusCode: 200)
        // set last part model
        let lastUrlModel = PresignedUrlList(urls: [PresignedUrl(url: "https://dracoon.team/4", partNumber: 4)])
        MockURLProtocol.responseWithModel(PresignedUrlList.self, model: lastUrlModel, statusCode: 200)
        //upload response with eTag header
        let headers = HTTPHeaders(dictionaryLiteral: ("eTag", "0123456789abc"))
        let httpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: headers)
        let s3UploadResponse = DefaultDataResponse(request: nil, response: httpResponse, data: nil, error: nil)
        
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        
        // TODO Complete request reponse
        let completedHttpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.response(with: DefaultDataResponse(request: nil, response: completedHttpResponse, data: nil, error: nil), statusCode: 200)
        
        // TODO poll for node
        self.setResponseModel(S3FileUploadStatus.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "upload")
        var calledOnComplete = false
        
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "Calls onComplete")
        let uploadCallback = UploadCallback()
        
        uploadCallback.onComplete = { node in
            calledOnComplete = true
            expectation.fulfill()
        }
        
        let url = Bundle(for: FileDownload.self).resourceURL!.appendingPathComponent("testUpload")
        let uploadData = Data(count: 1024*1024*17)
        FileManager.default.createFile(atPath: url.path, contents: uploadData, attributes: [:])
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback)
        
        self.testWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertTrue(calledOnComplete)
    }
}
