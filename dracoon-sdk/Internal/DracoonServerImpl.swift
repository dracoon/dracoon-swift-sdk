//
//  DracoonServerImpl.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

final class DracoonServerImpl: DracoonServer, Sendable {
    
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
    
    func getServerVersion(completion: @Sendable @escaping (Dracoon.Result<SoftwareVersionData>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/public/software/version"
        
        session.request(requestUrl, method: .get)
            .validate()
            .decode(SoftwareVersionData.self, decoder: self.decoder, completion: completion)
        
    }
    
    func getServerTime(completion: @Sendable @escaping (Dracoon.Result<SdsServerTime>) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/public/time"
        
        session.request(requestUrl, method: .get)
            .validate()
            .decode(SdsServerTime.self, decoder: self.decoder, completion: completion)
    }
}
