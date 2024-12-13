//
//  Alamofire+Convenience.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

public struct Dracoon {
    public enum Result<T: Sendable> {
        case value(T)
        case error(DracoonError)
    }
    
    public struct Response {
        public let error: DracoonError?
        
        public init(error: DracoonError?) {
            self.error = error
        }
    }
}

public extension DataRequest {
    
    typealias Result = Dracoon.Result
    typealias DecodeCompletion<T> = @Sendable (_ result: Result<T>) -> Void
    typealias DracoonResponseCompletion = @Sendable (Dracoon.Response) -> Void
    
    func decode<D: Decodable & Sendable>(_ type: D.Type, decoder: JSONDecoder, requestType: DracoonErrorParser.RequestType = .other, completion: @escaping DecodeCompletion<D>) {
        self.responseData(completionHandler: { dataResponse in
            do {
                switch dataResponse.result {
                case .success(let data):
                    let success = try decoder.decode(type, from: data)
                    completion(Result.value(success))
                case .failure(let error):
                    let error = try self.handleError(error: error, urlResponse: dataResponse.response,
                                                     responseData: dataResponse.data, decoder: decoder, requestType: requestType)
                    completion(Result.error(error))
                }
            } catch {
                completion(Result.error(DracoonError.decode(error: error, statusCode: self.response?.statusCode)))
            }
        })
    }
    
    func handleResponse(decoder: JSONDecoder, requestType: DracoonErrorParser.RequestType = .other, completion: @escaping DracoonResponseCompletion) {
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
    
    private func handleError(error: AFError?, urlResponse: HTTPURLResponse?, responseData: Data?, decoder: JSONDecoder, requestType: DracoonErrorParser.RequestType) throws -> DracoonError {
        let underlyingError = error?.underlyingError
        if underlyingError?._code == NSURLErrorTimedOut {
            return DracoonError.connection_timeout
        } else if underlyingError?._code == NSURLErrorNotConnectedToInternet {
            return DracoonError.offline
        }
        if requestType == .oauth {
            return self.handleOAuthError(decoder: decoder, error: error, urlResponse: urlResponse, responseData: responseData)
        }
        if let response = urlResponse, response.statusCode == DracoonErrorParser.HTTPStatusCode.FORBIDDEN,
           response.allHeaderFields["X-Forbidden"] as? String == "403" {
            return DracoonError.api(error: DracoonSDKErrorModel(errorCode: DracoonApiCode.SERVER_MALICIOUS_FILE_DETECTED, httpStatusCode: response.statusCode))
        }
        if let response = urlResponse, response.statusCode == DracoonErrorParser.HTTPStatusCode.TOO_MANY_REQUESTS {
            if let waitingTimeSecondsString = response.allHeaderFields["Retry-After"] as? String,
               let waitingTimeSeconds = Int(waitingTimeSecondsString) {
                return DracoonError.too_many_requests_sent(waitingTimeSeconds: waitingTimeSeconds)
            } else {
                return DracoonError.too_many_requests_sent(waitingTimeSeconds: DracoonConstants.DEFAULT_429_WAITING_TIME_SECONDS)
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
    
    private func handleOAuthError(decoder: JSONDecoder, error: AFError?, urlResponse: HTTPURLResponse?, responseData: Data?) -> DracoonError {
        guard let data = responseData else {
            return DracoonError.oauth_error_unknown(statusCode: urlResponse?.statusCode, description: error?.errorDescription)
        }
        do {
            let error = try decoder.decode(OAuthErrorModel.self, from: data)
            return DracoonError.oauth_error(errorModel: error)
        } catch {}
        
        return DracoonError.oauth_error_unknown(statusCode: urlResponse?.statusCode, description: error?.errorDescription)
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
