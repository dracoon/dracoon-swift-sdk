//
//  DracoonConfigImpl.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

class DracoonConfigImpl: DracoonConfig {
    
    let session: Alamofire.Session
    let serverUrl: URL
    let apiPath: String
    let decoder: JSONDecoder
    
    init(config: DracoonRequestConfig) {
        self.session = config.session
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.decoder = config.decoder
    }
    
    func getSystemDefaults(completion: @escaping DataRequest.DecodeCompletion<SystemDefaults>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/config/info/defaults"
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(SystemDefaults.self, decoder: self.decoder, completion: completion)
    }
    
    func getGeneralSettings(completion: @escaping DataRequest.DecodeCompletion<GeneralSettings>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/config/info/general"
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(GeneralSettings.self, decoder: self.decoder, completion: completion)
    }
    
    func getInfrastructureProperties(completion: @escaping DataRequest.DecodeCompletion<InfrastructureProperties>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/config/info/infrastructure"
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(InfrastructureProperties.self, decoder: self.decoder, completion: completion)
    }
    
    func getClassificationPolicies(completion: @escaping DataRequest.DecodeCompletion<ClassificationPoliciesConfig>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/config/info/policies/classifications"
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
        .validate()
        .decode(ClassificationPoliciesConfig.self, decoder: self.decoder, completion: completion)
    }
    
    func getPasswordPolicies(completion: @escaping DataRequest.DecodeCompletion<PasswordPoliciesConfig>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/config/info/policies/passwords"
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
        .validate()
        .decode(PasswordPoliciesConfig.self, decoder: self.decoder, completion: completion)
    }
    
    func getCryptoAlgorithms(completion: @escaping DataRequest.DecodeCompletion<AlgorithmVersionInfoList>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/config/info/policies/algorithms"
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
        .validate()
        .decode(AlgorithmVersionInfoList.self, decoder: self.decoder, completion: completion)
    }
}
