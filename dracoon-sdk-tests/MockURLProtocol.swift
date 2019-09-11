//
//  MockURLProtocol.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 24.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import dracoon_sdk
import Alamofire

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
        } else if let data = MockURLProtocol.responseData.peek() as? Data {
            _ = MockURLProtocol.responseData.poll()
            client?.urlProtocol(self, didLoad: data)
        } else if let downloadResponse = MockURLProtocol.responseData.peek() as? DefaultDownloadResponse {
            client?.urlProtocol(self, didReceive: downloadResponse.response!, cacheStoragePolicy: .notAllowed)
            _ = MockURLProtocol.responseData.poll()
        } else if let dataResponse = MockURLProtocol.responseData.peek() as? DefaultDataResponse, let httpResponse = dataResponse.response {
            client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
            _ = MockURLProtocol.responseData.poll()
        } else {
            let urlResponse = HTTPURLResponse(url: URL(string: "https://dracoon.team")!, statusCode: MockURLProtocol.statusCodes.poll()!, httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
}

extension MockURLProtocol {
    
    private static var responseData = TestQueue<Any>()
    private static var responseError: Error?
    private static var statusCodes: TestQueue<Int>!
    
    static func responseWithError(_ error: Error, statusCode: Int) {
        self.statusCodes.add(statusCode)
        MockURLProtocol.responseError = error
    }
    
    static func responseWithModel<E: Encodable>(_ type: E.Type,  model: Encodable, statusCode: Int) {
        self.statusCodes.add(statusCode)
        let data = try? JSONEncoder().encode(model as! E)
        self.responseData.add(data!)
    }
    
    static func response(with element: Any, statusCode: Int) {
        self.statusCodes.add(statusCode)
        self.responseData.add(element)
    }
    
    static func response(with statusCode: Int) {
        self.statusCodes.add(statusCode)
    }
    
    static func resetMockData() {
        MockURLProtocol.statusCodes = TestQueue<Int>()
        MockURLProtocol.responseError = nil
        MockURLProtocol.responseData = TestQueue<Any>()
    }
}
