//
//  DracoonSettings.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

class DracoonSettingsImpl: DracoonSettings {
    let session: Alamofire.Session
    let serverUrl: URL
    let apiPath: String
    let oAuthTokenManager: OAuthInterceptor
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    
    init(config: DracoonRequestConfig) {
        self.session = config.session
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.oAuthTokenManager = config.oauthTokenManager
        self.decoder = config.decoder
        self.encoder = config.encoder
    }
    
    func getServerSettings(completion: @Sendable @escaping (Dracoon.Result<CustomerSettingsResponse>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/settings"
        
        self.session.request(requestUrl, method: .get, parameters: Parameters())
            .validate()
            .decode(CustomerSettingsResponse.self, decoder: self.decoder, completion: completion)
    }
    
    func updateServerSettings(request: CustomerSettingsRequest, completion: @Sendable @escaping (Dracoon.Result<CustomerSettingsResponse>) -> Void) {
        
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/settings"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue(ApiRequestConstants.headerFields.values.applicationJsonCharsetUTF8, forHTTPHeaderField: ApiRequestConstants.headerFields.keys.contentType)
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .decode(CustomerSettingsResponse.self, decoder: self.decoder, completion: completion)
            
        } catch {
            completion(Dracoon.Result.error(DracoonError.encode(error: error)))
        }
    }
}
