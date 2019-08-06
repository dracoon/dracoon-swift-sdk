//
//  DracoonConfigMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 06.08.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Alamofire
import dracoon_sdk

class DracoonConfigMock: DracoonConfig {
    
    func getSystemDefaults(completion: @escaping DataRequest.DecodeCompletion<SystemDefaults>) {
    }
    
    func getGeneralSettings(completion: @escaping DataRequest.DecodeCompletion<GeneralSettings>) {
    }
    
    func getInfrastructureProperties(completion: @escaping DataRequest.DecodeCompletion<InfrastructureProperties>) {
    }
    
    
}
