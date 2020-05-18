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
    var systemDefaultsResponse: SystemDefaults
    var generalSettingsResponse: GeneralSettings
    var infrastructurePropertiesResponse: InfrastructureProperties
    var passwordPoliciesResponse: PasswordPoliciesConfig
    
    init() {
        let modelFactory = ResponseModelFactory()
        self.systemDefaultsResponse = modelFactory.getTestResponseModel(SystemDefaults.self)!
        self.generalSettingsResponse = modelFactory.getTestResponseModel(GeneralSettings.self)!
        self.infrastructurePropertiesResponse = modelFactory.getTestResponseModel(InfrastructureProperties.self)!
        self.passwordPoliciesResponse = modelFactory.getTestResponseModel(PasswordPoliciesConfig.self)!
    }
    
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
    
    func getPasswordPolicies(completion: @escaping DataRequest.DecodeCompletion<PasswordPoliciesConfig>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value((self.passwordPoliciesResponse)))
        }
    }
}
