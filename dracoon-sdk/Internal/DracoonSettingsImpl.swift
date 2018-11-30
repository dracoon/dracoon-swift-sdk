//
//  DracoonSettings.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

class DracoonSettingsImpl: DracoonSettings{
    let sessionManager: Alamofire.SessionManager
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthTokenManager
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    
    init(config: DracoonRequestConfig) {
        self.sessionManager = config.sessionManager
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.oAuthTokenManager = config.oauthTokenManager
        self.decoder = config.decoder
        self.encoder = config.encoder
    }
    
    func getServerSettings(completion: @escaping (Dracoon.Result<CustomerSettingsResponse>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/settings"
        
        self.sessionManager.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(CustomerSettingsResponse.self, decoder: self.decoder, completion: completion)
    }
    
    func putServerSettings(request: CustomerSettingsRequest, completion: @escaping (Dracoon.Result<CustomerSettingsResponse>) -> Void) {
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/settings"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = "Put"
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.sessionManager.request(urlRequest)
                .validate()
                .decode(CustomerSettingsResponse.self, decoder: self.decoder, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.nodes(error: error)))
        }
    }
}
