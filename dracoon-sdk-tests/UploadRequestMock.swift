//
//  UploadRequestMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 01.08.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import Foundation

class UploadRequestMock {
    
    var totalUnitCount: Int64 = 2
    var completedUnitCount: Int64 = 1
    
    var request: URLRequest?
    var uploadProgress: Progress
    var ProgressHandler: UploadRequest.ProgressHandler?
    
    init() {
        self.request = URLRequest(url: URL(string: "https://dracoon.team")!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: TimeInterval())
        let progress = Progress(totalUnitCount: totalUnitCount)
        progress.completedUnitCount = completedUnitCount
        self.uploadProgress = progress
    }
    
    func uploadProgress(queue: DispatchQueue = DispatchQueue.main, closure: @escaping UploadRequest.ProgressHandler) -> Self {
        closure(self.uploadProgress)
        return self
    }
}
