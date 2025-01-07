//
//  DracoonConfigMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 06.08.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Alamofire
import dracoon_sdk

class DracoonConfigMock: DracoonConfig, @unchecked Sendable {
    
    var error: DracoonError?
    var systemDefaultsResponse: SystemDefaults
    var generalSettingsResponse: GeneralSettings
    var infrastructurePropertiesResponse: InfrastructureProperties
    var classificationPoliciesResponse: ClassificationPoliciesConfig
    var passwordPoliciesResponse: PasswordPoliciesConfig
    var algoVersionInfoList: AlgorithmVersionInfoList
    
    init() {
        let modelFactory = ResponseModelFactory()
        self.systemDefaultsResponse = modelFactory.getTestResponseModel(SystemDefaults.self)!
        self.generalSettingsResponse = modelFactory.getTestResponseModel(GeneralSettings.self)!
        self.infrastructurePropertiesResponse = modelFactory.getTestResponseModel(InfrastructureProperties.self)!
        self.classificationPoliciesResponse = modelFactory.getTestResponseModel(ClassificationPoliciesConfig.self)!
        self.passwordPoliciesResponse = modelFactory.getTestResponseModel(PasswordPoliciesConfig.self)!
        self.algoVersionInfoList = modelFactory.getTestResponseModel(AlgorithmVersionInfoList.self)!
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
    
    func getClassificationPolicies(completion: @escaping DataRequest.DecodeCompletion<ClassificationPoliciesConfig>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value((self.classificationPoliciesResponse)))
        }
    }
    
    func getPasswordPolicies(completion: @escaping DataRequest.DecodeCompletion<PasswordPoliciesConfig>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value((self.passwordPoliciesResponse)))
        }
    }
    
    func getCryptoAlgorithms(completion: @escaping DataRequest.DecodeCompletion<AlgorithmVersionInfoList>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value((self.algoVersionInfoList)))
        }
    }
}
