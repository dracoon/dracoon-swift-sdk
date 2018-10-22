//
//  DracoonServerImpl.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

class DracoonServerImpl: DracoonServer {
    
    let sessionManager: Alamofire.SessionManager
    let serverUrl: URL
    let apiPath: String
    let decoder: JSONDecoder
    
    init(config: DracoonRequestConfig) {
        self.sessionManager = config.sessionManager
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.decoder = config.decoder
    }
    
    func getServerVersion(completion: @escaping DataRequest.DecodeCompletion<SoftwareVersionData>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/public/software/version"
        
        sessionManager.request(requestUrl, method: .get)
            .validate()
            .decode(SoftwareVersionData.self, decoder: self.decoder, completion: completion)
        
    }
    
    func getServerTime(completion: @escaping DataRequest.DecodeCompletion<SdsServerTime>) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/public/time"
        
        sessionManager.request(requestUrl, method: .get)
            .validate()
            .decode(SdsServerTime.self, decoder: self.decoder, completion: completion)
    }
}
