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
        public let error: Error?
    }
}

public extension DataRequest {
    
    typealias Result = Dracoon.Result
    
    typealias DecodeCompletion<T> = (_ result: Result<T>) -> Void
    
    func decode<D: Decodable>(_ type: D.Type, decoder: JSONDecoder, completion: @escaping DecodeCompletion<D>) {
        self.responseData(completionHandler: { dataResponse in
            do {
                if dataResponse.result.isSuccess {
                    
                    let success = try decoder.decode(type, from: dataResponse.result.value!)
                    completion(Result.value(success))
                    
                } else {
                    
                    if let dracoonError = dataResponse.result.error as? DracoonError {
                        completion(Result.error(dracoonError))
                    } else {
                        if dataResponse.result.error?._code == NSURLErrorTimedOut {
                            completion(Result.error(DracoonError.connection_timeout))
                        } else {
                            let error = try decoder.decode(ModelErrorResponse.self, from: dataResponse.data!)
                            completion(Result.error(DracoonError.api(error: error)))
                        }
                    }
                }
                
            } catch {
                
                completion(Result.error(DracoonError.decode(error: error)))
            }
            
        })
    }
}

public extension OutputStream {
    func write(data: Data) -> Int {
        return data.withUnsafeBytes { write($0, maxLength: data.count) }
    }
}
