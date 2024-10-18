//
//  DracoonUsersImpl.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 08.02.21.
//  Copyright © 2021 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

class DracoonUsersImpl: DracoonUsers {
    
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
    
    func downloadUserAvatar(userId: Int64, avatarUuid: String, targetUrl: URL, completion: @Sendable @escaping (Dracoon.Response) -> Void) {
        let downloadUrl = serverUrl.absoluteString + apiPath + "/downloads/avatar/\(String(userId))/\(avatarUuid)"
        var request = URLRequest(url: URL(string: downloadUrl)!)
        request.addValue("application/octet-stream", forHTTPHeaderField: "Accept")
        self.session
            .download(request, to: { _, _ in
                return (targetUrl, [.removePreviousFile, .createIntermediateDirectories])
            })
            .response(completionHandler: { downloadResponse in
                switch downloadResponse.result {
                case .success(_):
                    completion(Dracoon.Response(error: nil))
                case .failure(let error):
                    completion(Dracoon.Response(error: DracoonError.generic(error: error)))
                }
            })
    }
    
}
