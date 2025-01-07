//
//  DracoonServerMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 07.07.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
@testable import dracoon_sdk

final class DracoonServerMock: DracoonServer, Sendable {
    
    func getServerVersion(completion: @escaping DataRequest.DecodeCompletion<SoftwareVersionData>) {
        let data = ResponseModelFactory().getTestResponseModel(SoftwareVersionData.self)!
        completion(Dracoon.Result.value((data)))
    }
    
    func getServerTime(completion: @escaping DataRequest.DecodeCompletion<SdsServerTime>) {
        let data = ResponseModelFactory().getTestResponseModel(SdsServerTime.self)!
        completion(Dracoon.Result.value((data)))
    }
}
