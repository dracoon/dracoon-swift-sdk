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
        
        let config = DracoonConfigMock()
        config.generalSettingsResponse.useS3Storage = true
        config.infrastructurePropertiesResponse.s3EnforceDirectUpload = true
        
        let password = self.encryptionPassword
        self.nodes = DracoonNodesImpl(requestConfig: self.requestConfig, crypto: self.crypto, account: DracoonAccountMock(), config: config, getEncryptionPassword: {
            return password
        })
    }
    
    // MARK: S3 Foreground Upload
    
    func testUpload_succeeds_callsOnComplete() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        self.setResponseModel(CreateFileUploadResponse.self, statusCode: 200)
        // Set part model
        let lastUrlModel = PresignedUrlList(urls: [PresignedUrl(url: "https://dracoon.team/1", partNumber: 1)])
        MockURLProtocol.responseWithModel(PresignedUrlList.self, model: lastUrlModel, statusCode: 200)
        // Upload response with eTag header
        let headers = ["eTag" : "0123456789abc"]
        let httpResponse = HTTPURLResponse(url: URL(string:"https://dracoon2.team")!, statusCode: 200, httpVersion: nil, headerFields: headers)
        let s3UploadResponse = DataResponse<Sendable?, AFError>(request: nil, response: httpResponse, data: nil, metrics: nil, serializationDuration: TimeInterval(), result: .success(nil))
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        
        // Complete request reponse
        let completedHttpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.response(with: DataResponse<Sendable?, AFError>(request: nil, response: completedHttpResponse, data: nil, metrics: nil, serializationDuration: TimeInterval(), result: .success(nil)), statusCode: 200)
        
        // Poll for node
        self.setResponseModel(S3FileUploadStatus.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Calls onComplete")
        var calledOnComplete = false
        
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "upload")
        let uploadCallback = UploadCallback()
        
        uploadCallback.onComplete = { node in
            calledOnComplete = true
            expectation.fulfill()
        }
        
        let url = Bundle(for: DracoonNodesS3Tests.self).resourceURL!.appendingPathComponent("testUpload")
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback, sessionConfig: nil)
        
        self.testWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertTrue(calledOnComplete)
    }
    
    func testUpload_withMoreChunks_succeeds() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        self.setResponseModel(CreateFileUploadResponse.self, statusCode: 200)
        self.setResponseModel(PresignedUrlList.self, statusCode: 200)
        // Set last part model
        let lastUrlModel = PresignedUrlList(urls: [PresignedUrl(url: "https://dracoon.team/4", partNumber: 4)])
        MockURLProtocol.responseWithModel(PresignedUrlList.self, model: lastUrlModel, statusCode: 200)
        // Upload response with eTag header
        let headers = ["eTag" : "0123456789abc"]
        let httpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: headers)
        let s3UploadResponse = DataResponse<Sendable?, AFError>(request: nil, response: httpResponse, data: nil, metrics: nil, serializationDuration: TimeInterval(), result: .success(nil))
        
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        
        // Complete request reponse
        let completedHttpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.response(with: DataResponse<Sendable?, AFError>(request: nil, response: completedHttpResponse, data: nil, metrics: nil, serializationDuration: TimeInterval(), result: .success(nil)), statusCode: 200)
        
        // Poll for node
        self.setResponseModel(S3FileUploadStatus.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Calls onComplete")
        var calledOnComplete = false
        (FileUtils.fileHelper as! FileUtilsMock).size = Int64(1024*1024*17)
        
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "upload")
        let uploadCallback = UploadCallback()
        
        uploadCallback.onComplete = { node in
            calledOnComplete = true
            expectation.fulfill()
        }
        
        let url = Bundle(for: DracoonNodesS3Tests.self).resourceURL!.appendingPathComponent("testUpload")
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback, sessionConfig: nil)
        
        self.testWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertTrue(calledOnComplete)
    }
    
    func testUpload_pollsMultipleTimes_callsOnComplete() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        self.setResponseModel(CreateFileUploadResponse.self, statusCode: 200)
        // Set part model
        let lastUrlModel = PresignedUrlList(urls: [PresignedUrl(url: "https://dracoon.team/1", partNumber: 1)])
        MockURLProtocol.responseWithModel(PresignedUrlList.self, model: lastUrlModel, statusCode: 200)
        // Upload response with eTag header
        let headers: [String:String] = ["eTag" : "0123456789abc"]
        let httpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: headers)
        let s3UploadResponse = DataResponse<Sendable?, AFError>(request: nil, response: httpResponse, data: nil, metrics: nil, serializationDuration: TimeInterval(), result: .success(nil))
        
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        
        // Complete request reponse
        let completedHttpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.response(with: DataResponse<Sendable?, AFError>(request: nil, response: completedHttpResponse, data: nil, metrics: nil, serializationDuration: TimeInterval(), result: .success(nil)), statusCode: 200)
        
        // Poll for node
        let finishingModel = S3FileUploadStatus(status: S3FileUploadStatus.S3UploadStatus.finishing.rawValue, node: nil, errorDetails: nil)
        MockURLProtocol.responseWithModel(S3FileUploadStatus.self, model: finishingModel, statusCode: 200)
        MockURLProtocol.responseWithModel(S3FileUploadStatus.self, model: finishingModel, statusCode: 200)
        MockURLProtocol.responseWithModel(S3FileUploadStatus.self, model: finishingModel, statusCode: 200)
        self.setResponseModel(S3FileUploadStatus.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Calls onComplete")
        var calledOnComplete = false
        
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "upload")
        let uploadCallback = UploadCallback()
        
        uploadCallback.onComplete = { node in
            calledOnComplete = true
            expectation.fulfill()
        }
        
        let url = Bundle(for: DracoonNodesS3Tests.self).resourceURL!.appendingPathComponent("testUpload")
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback, sessionConfig: nil)
        
        self.testWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertTrue(calledOnComplete)
    }
    
    func testUpload_pollStatusReturnsError_callsOnError() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        self.setResponseModel(CreateFileUploadResponse.self, statusCode: 200)
        // Set part model
        let lastUrlModel = PresignedUrlList(urls: [PresignedUrl(url: "https://dracoon.team/1", partNumber: 1)])
        MockURLProtocol.responseWithModel(PresignedUrlList.self, model: lastUrlModel, statusCode: 200)
        // Upload response with eTag header
        let headers: [String:String] = ["eTag" : "0123456789abc"]
        let httpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: headers)
        let s3UploadResponse = DataResponse<Sendable?, AFError>(request: nil, response: httpResponse, data: nil, metrics: nil, serializationDuration: TimeInterval(), result: .success(nil))
        
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        
        // Complete request reponse
        let completedHttpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.response(with: DataResponse<Sendable?, AFError>(request: nil, response: completedHttpResponse, data: nil, metrics: nil, serializationDuration: TimeInterval(), result: .success(nil)), statusCode: 200)
        
        // Poll for node
        let error = ModelErrorResponse(code: 404, message: "Not Found", debugInfo: nil, errorCode: nil)
        let errorModel = S3FileUploadStatus(status: S3FileUploadStatus.S3UploadStatus.error.rawValue, node: nil, errorDetails: error)
        MockURLProtocol.responseWithModel(S3FileUploadStatus.self, model: errorModel, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Retunrs error")
        var calledOnError = false
        
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "upload")
        let uploadCallback = UploadCallback()
        
        uploadCallback.onError = { error in
            calledOnError = true
            expectation.fulfill()
        }
        
        let url = Bundle(for: DracoonNodesS3Tests.self).resourceURL!.appendingPathComponent("testUpload")
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback, sessionConfig: nil)
        
        self.testWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertTrue(calledOnError)
    }
    
    func testEncryptedUpload_succeeds_callsOnComplete() {
        
        let encryptedNode = Node(_id: 1337, type: .file, name: "encryptedFile"){$0.isEncrypted = true}
        MockURLProtocol.responseWithModel(Node.self, model: encryptedNode, statusCode: 200)
        self.setResponseModel(CreateFileUploadResponse.self, statusCode: 200)
        // Set part model
        let lastUrlModel = PresignedUrlList(urls: [PresignedUrl(url: "https://dracoon.team/1", partNumber: 1)])
        MockURLProtocol.responseWithModel(PresignedUrlList.self, model: lastUrlModel, statusCode: 200)
        // Upload response with eTag header
        let headers: [String:String] = ["eTag" : "0123456789abc"]
        let httpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: headers)
        let s3UploadResponse = DataResponse<Sendable?, AFError>(request: nil, response: httpResponse, data: nil, metrics: nil, serializationDuration: TimeInterval(), result: .success(nil))
        
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        
        // Complete request reponse
        let completedHttpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.response(with: DataResponse<Sendable?, AFError>(request: nil, response: completedHttpResponse, data: nil, metrics: nil, serializationDuration: TimeInterval(), result: .success(nil)), statusCode: 200)
        
        // Poll for node
        self.setResponseModel(S3FileUploadStatus.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Calls onComplete")
        var calledOnComplete = false
        
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "upload")
        let uploadCallback = UploadCallback()
        
        uploadCallback.onComplete = { node in
            calledOnComplete = true
            expectation.fulfill()
        }
        
        let url = Bundle(for: DracoonNodesS3Tests.self).resourceURL!.appendingPathComponent("testUpload")
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback, sessionConfig: nil)
        
        self.testWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertTrue(calledOnComplete)
    }
    
    func testEncryptedUpload_succeeds_createsMissingFileKeys() {
        
        let encryptedNode = Node(_id: 1337, type: .file, name: "encryptedFile"){$0.isEncrypted = true}
        MockURLProtocol.responseWithModel(Node.self, model: encryptedNode, statusCode: 200)
        self.setResponseModel(CreateFileUploadResponse.self, statusCode: 200)
        // Set part model
        let lastUrlModel = PresignedUrlList(urls: [PresignedUrl(url: "https://dracoon.team/1", partNumber: 1)])
        MockURLProtocol.responseWithModel(PresignedUrlList.self, model: lastUrlModel, statusCode: 200)
        // Upload response with eTag header
        let headers: [String:String] = ["eTag" : "0123456789abc"]
        let httpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: headers)
        let s3UploadResponse = DataResponse<Sendable?, AFError>(request: nil, response: httpResponse, data: nil, metrics: nil, serializationDuration: TimeInterval(), result: .success(nil))
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        
        // Complete request reponse
        let completedHttpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.response(with: DataResponse<Sendable?, AFError>(request: nil, response: completedHttpResponse, data: nil, metrics: nil, serializationDuration: TimeInterval(), result: .success(nil)), statusCode: 200)
        
        // Poll for node
        self.setResponseModel(S3FileUploadStatus.self, statusCode: 200)
        
        // Missing FileKeys response
        self.setResponseModel(MissingKeysResponse.self, statusCode: 200)
        MockURLProtocol.response(with: 200)
        
        let expectation = XCTestExpectation(description: "Waits for missing file keys to be created")
        let cryptoMock = self.crypto as! DracoonCryptoMock
        
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "upload")
        let uploadCallback = UploadCallback()
        
        uploadCallback.onComplete = { node in
            cryptoMock.decryptFileKeyCalled = false
            cryptoMock.encryptFileKeyCalled = false
        }
        
        let url = Bundle(for: DracoonNodesS3Tests.self).resourceURL!.appendingPathComponent("testUpload")
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback, sessionConfig: nil)
        
        self.testWaiter.wait(for: [expectation], timeout: 20.0)
        XCTAssertTrue(cryptoMock.decryptFileKeyCalled)
        XCTAssertTrue(cryptoMock.encryptFileKeyCalled)
    }

    func testUpload_getPresignedListFails_returnsError() {

        self.setResponseModel(Node.self, statusCode: 200)
        self.setResponseModel(CreateFileUploadResponse.self, statusCode: 200)
        let error = NSError(domain: "SDKTest", code: -10006, userInfo: nil)
        MockURLProtocol.responseWithError(error, statusCode: 401)
        let expectation = XCTestExpectation(description: "Returns error")
        var calledOnError = false

        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "upload")

        let uploadCallback = UploadCallback()

        uploadCallback.onError = { error in
            calledOnError = true
            expectation.fulfill()
        }

        let url = Bundle(for: DracoonNodesS3Tests.self).resourceURL!.appendingPathComponent("testUpload")
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback, sessionConfig: nil)

        self.testWaiter.wait(for: [expectation], timeout: 4.0)
        XCTAssertTrue(calledOnError)
    }
    
    func testUpload_uploadFails_returnsError() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        self.setResponseModel(CreateFileUploadResponse.self, statusCode: 200)
        // Set part model
        let lastUrlModel = PresignedUrlList(urls: [PresignedUrl(url: "https://dracoon.team/1", partNumber: 1)])
        MockURLProtocol.responseWithModel(PresignedUrlList.self, model: lastUrlModel, statusCode: 200)
        // Upload response without eTag header
        let httpResponse = HTTPURLResponse(url: URL(string:"https://dracoon.team")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let s3UploadResponse = DataResponse<Sendable?, AFError>(request: nil, response: httpResponse, data: nil, metrics: nil, serializationDuration: TimeInterval(), result: .success(nil))
        
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        MockURLProtocol.response(with: s3UploadResponse, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Returns error")
        var calledOnError = false
        
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "upload")
        let uploadCallback = UploadCallback()
        
        uploadCallback.onError = { error in
            calledOnError = true
            expectation.fulfill()
        }
        
        let url = Bundle(for: DracoonNodesS3Tests.self).resourceURL!.appendingPathComponent("testUpload")
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback, sessionConfig: nil)
        
        self.testWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertTrue(calledOnError)
    }
    
    // MARK: S3 Background Upload
    
    func testUploadBackground_withFileSizeTooLarge_callsOnError() {
        
        self.setResponseModel(Node.self, statusCode: 200)
        
        let expectation = XCTestExpectation(description: "Calls onError")
        var calledOnError = false
        (FileUtils.fileHelper as! FileUtilsMock).size = DracoonConstants.S3_BACKGROUND_UPLOAD_MAX_SIZE + 1
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "upload")
        let uploadCallback = UploadCallback()
        
        uploadCallback.onError = { error in
            calledOnError = true
            expectation.fulfill()
        }
        
        let url = Bundle(for: DracoonNodesS3Tests.self).resourceURL!.appendingPathComponent("testUpload")
        let testSessionConfig = URLSessionConfiguration.background(withIdentifier: "com.dracoon.test")
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback, sessionConfig: testSessionConfig)
        
        self.testWaiter.wait(for: [expectation], timeout: 60.0)
        XCTAssertTrue(calledOnError)
    }
    
    func testUploadBackground_withEncryptedTargetRoom_encryptsFile() {
        
        let expectation = XCTestExpectation(description: "Encrypts file")
        
        let encryptedNode = Node(_id: 1337, type: .file, name: "encryptedFile"){$0.isEncrypted = true}
        MockURLProtocol.responseWithModel(Node.self, model: encryptedNode, statusCode: 200)
        self.setResponseModel(CreateFileUploadResponse.self, statusCode: 200)
        // Set part model
        let lastUrlModel = PresignedUrlList(urls: [PresignedUrl(url: "https://dracoon.team/1", partNumber: 1)])
        MockURLProtocol.responseWithModel(PresignedUrlList.self, model: lastUrlModel, statusCode: 200)
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "upload")
        let uploadCallback = UploadCallback()
        uploadCallback.onError = { _ in
            expectation.fulfill()
        }
        
        let url = Bundle(for: DracoonNodesS3Tests.self).resourceURL!.appendingPathComponent("testUpload")
        let testSessionConfig = URLSessionConfiguration.background(withIdentifier: "com.dracoon.test")
        let cryptoMock = self.crypto as! DracoonCryptoMock
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback, sessionConfig: testSessionConfig)
        
        self.testWaiter.wait(for: [expectation], timeout: 30.0)
        XCTAssertTrue(cryptoMock.generateFileKeyCalled)
        XCTAssertTrue(cryptoMock.createdEncryptionCipher)
    }
    
    func testUploadBackground_withEncryptedTargetRoomAndFailingCipher_returnsError() throws {
        
        let expectation = XCTestExpectation(description: "Returns crypto error")
        var returnedError: DracoonError? = nil
        
        let encryptedNode = Node(_id: 1337, type: .file, name: "encryptedFile"){$0.isEncrypted = true}
        MockURLProtocol.responseWithModel(Node.self, model: encryptedNode, statusCode: 200)
        self.setResponseModel(CreateFileUploadResponse.self, statusCode: 200)
        // Set part model
        let lastUrlModel = PresignedUrlList(urls: [PresignedUrl(url: "https://dracoon.team/1", partNumber: 1)])
        MockURLProtocol.responseWithModel(PresignedUrlList.self, model: lastUrlModel, statusCode: 200)
        
        let createFileUploadRequest = CreateFileUploadRequest(parentId: 42, name: "upload")
        let uploadCallback = UploadCallback()
        uploadCallback.onError = { error in
            returnedError = error as? DracoonError
            expectation.fulfill()
        }
        
        let url = Bundle(for: DracoonNodesS3Tests.self).resourceURL!.appendingPathComponent("testUpload")
        let testSessionConfig = URLSessionConfiguration.background(withIdentifier: "com.dracoon.test")
        let cryptoMock = self.crypto as! DracoonCryptoMock
        let testError = DracoonError.encryption_cipher_failure
        cryptoMock.testError = testError
        self.nodes.uploadFile(uploadId: "123", request: createFileUploadRequest, fileUrl: url, callback: uploadCallback, sessionConfig: testSessionConfig)
        
        self.testWaiter.wait(for: [expectation], timeout: 30.0)
        let unwrappedError = try XCTUnwrap(returnedError)
        XCTAssertTrue(unwrappedError.localizedDescription == testError.localizedDescription)
    }
}
