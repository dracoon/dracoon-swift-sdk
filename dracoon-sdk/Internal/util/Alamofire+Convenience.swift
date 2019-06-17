//
//  Alamofire+Convenience.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

public struct Dracoon {
    public enum Result<T> {
        case value(T)
        case error(DracoonError)
    }
    
    public struct Response {
        public let error: DracoonError?
    }
}

public extension DataRequest {
    
    typealias Result = Dracoon.Result
    
    typealias DecodeCompletion<T> = (_ result: Result<T>) -> Void
    
    func decode<D: Decodable>(_ type: D.Type, decoder: JSONDecoder, requestType: DracoonErrorParser.RequestType = .other, completion: @escaping DecodeCompletion<D>) {
        self.responseData(completionHandler: { dataResponse in
            do {
                if let responseError = dataResponse.error {
                    let error = try self.handleError(error: responseError, urlResponse: dataResponse.response,
                                         responseData: dataResponse.data, decoder: decoder, requestType: requestType)
                    completion(Result.error(error))
                } else if dataResponse.result.isSuccess {
                    let success = try decoder.decode(type, from: dataResponse.result.value!)
                    completion(Result.value(success))
                }
            } catch {
                completion(Result.error(DracoonError.decode(error: error, statusCode: self.response?.statusCode)))
            }
        })
    }
    
    func handleResponse(decoder: JSONDecoder, requestType: DracoonErrorParser.RequestType = .other, completion: @escaping (Dracoon.Response) -> Void) {
        self.response(completionHandler: { response in
            if let error = response.error {
                do {
                    let dracoonError = try self.handleError(error: error, urlResponse: response.response, responseData: response.data, decoder: decoder, requestType: requestType)
                    completion(Dracoon.Response(error: dracoonError))
                } catch {
                    completion(Dracoon.Response(error: DracoonError.decode(error: error, statusCode: self.response?.statusCode)))
                }
            } else {
                completion(Dracoon.Response(error: nil))
            }
        })
    }
    
    private func handleError(error: Error?, urlResponse: HTTPURLResponse?, responseData: Data?, decoder: JSONDecoder, requestType: DracoonErrorParser.RequestType) throws -> DracoonError {
        if error?._code == NSURLErrorTimedOut {
            return DracoonError.connection_timeout
        } else if error?._code == NSURLErrorNotConnectedToInternet {
            return DracoonError.offline
        }
        if let response = urlResponse, response.statusCode == DracoonErrorParser.HTTPStatusCode.FORBIDDEN {
            if response.allHeaderFields["X-Forbidden"] as? String == "403" {
                return DracoonError.api(error: DracoonSDKErrorModel(errorCode: DracoonApiCode.SERVER_MALICIOUS_FILE_DETECTED, httpStatusCode: response.statusCode))
            }
        }
        guard let data = responseData else {
            return DracoonError.generic(error: error)
        }
        let error = try decoder.decode(ModelErrorResponse.self, from: data)
        let sdkError = self.parseError(error: error, requestType: requestType)
        return DracoonError.api(error: sdkError)
    }
    
    private func parseError(error: ModelErrorResponse, requestType: DracoonErrorParser.RequestType) -> DracoonSDKErrorModel {
        let code = DracoonErrorParser.shared.parseApiErrorResponse(error, requestType: requestType)
        return DracoonSDKErrorModel(errorCode: code, httpStatusCode: error.code)
    }
}

public extension OutputStream {
    func write(data: Data) -> Int {
        return data.withUnsafeBytes({ (rawBufferPointer: UnsafeRawBufferPointer) -> Int in
            let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
            guard let pointer = bufferPointer.baseAddress else {
                return 0
            }
            return self.write(pointer, maxLength: data.count)
        })
    }
}
