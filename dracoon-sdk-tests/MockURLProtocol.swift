//
//  MockURLProtocol.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 24.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import dracoon_sdk

final class MockURLProtocol: URLProtocol {
    
    private(set) var activeTask: URLSessionDataTask?
    
    private lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    override class func canInit(with request: URLRequest) -> Bool {
    return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
    return false
    }
    
    override func startLoading() {
        activeTask = session.dataTask(with: request.urlRequest!)
        activeTask?.cancel() // cancel to intercept in didCompleteWithError
    }
    
    override func stopLoading() {
        activeTask?.cancel()
    }
}

extension MockURLProtocol: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let responseError = MockURLProtocol.responseError {
            client?.urlProtocol(self, didFailWithError: responseError)
        } else if let data = MockURLProtocol.responseData {
            client?.urlProtocol(self, didLoad: data)
        } else {
            let urlResponse = HTTPURLResponse(url: URL(string: "https://dracoon.team")!, statusCode: MockURLProtocol.statusCode, httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
        }
        
        client?.urlProtocolDidFinishLoading(self)
        self.resetMockData()
    }
    
}

extension MockURLProtocol {
    
    private static var responseData: Data?
    private static var responseError: Error?
    private static var statusCode: Int!
    
    static func responseWithError(_ error: Error, statusCode: Int) {
        MockURLProtocol.statusCode = statusCode
        MockURLProtocol.responseError = error
    }
    
    static func responseWithModel<E: Encodable>(_ type: E.Type,  model: Codable, statusCode: Int) {
        MockURLProtocol.statusCode = statusCode
        MockURLProtocol.responseData = try? JSONEncoder().encode(model as! E)
    }
    
    func resetMockData() {
        MockURLProtocol.statusCode = nil
        MockURLProtocol.responseError = nil
        MockURLProtocol.responseData = nil
    }
}
