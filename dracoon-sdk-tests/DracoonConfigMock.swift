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
    
    var error: DracoonError?
    var systemDefaultsResponse = ResponseModelFactory.getTestResponseModel(SystemDefaults.self)!
    var generalSettingsResponse = ResponseModelFactory.getTestResponseModel(GeneralSettings.self)!
    var infrastructurePropertiesResponse = ResponseModelFactory.getTestResponseModel(InfrastructureProperties.self)!
    
    func getSystemDefaults(completion: @escaping DataRequest.DecodeCompletion<SystemDefaults>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value((self.systemDefaultsResponse)))
        }
    }
    
    func getGeneralSettings(completion: @escaping DataRequest.DecodeCompletion<GeneralSettings>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value((self.generalSettingsResponse)))
        }
    }
    
    func getInfrastructureProperties(completion: @escaping DataRequest.DecodeCompletion<InfrastructureProperties>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value((self.infrastructurePropertiesResponse)))
        }
    }
}
