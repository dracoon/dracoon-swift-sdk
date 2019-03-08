//
//  DracoonSDKErrorModel.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 08.03.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

public struct DracoonSDKErrorModel: Codable {
    
    /** HTTP status code */
    public var httpStatusCode: Int?
    /** SDK error code */
    public var errorCode: DracoonApiCode
    
    public init(errorCode: DracoonApiCode, httpStatusCode: Int?) {
        self.errorCode = errorCode
        self.httpStatusCode = httpStatusCode
    }
}
