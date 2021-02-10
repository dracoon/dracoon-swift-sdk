//
//  DracoonUsersMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 08.02.21.
//  Copyright © 2021 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
@testable import dracoon_sdk

class DracoonUsersMock: DracoonUsers {
    
    var error: DracoonError?
    
    func downloadUserAvatar(userId: Int64, avatarUuid: String, targetUrl: URL, completion: @escaping (Dracoon.Response) -> Void) {
        if let error = self.error {
            completion(Dracoon.Response(error: error))
        } else {
            completion(Dracoon.Response(error: nil))
        }
    }
}
