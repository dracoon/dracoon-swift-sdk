//
//  DracoonSubscriptionsMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 17.03.22.
//  Copyright © 2022 Dracoon. All rights reserved.
//

import Foundation
import dracoon_sdk

class DracoonSubscriptionsMock: DracoonSubscriptions {
    
    var error: DracoonError?
    
    let subscribedNode: SubscribedNode
    let subscribedNodeList: SubscribedNodeList
    
    let subscribedDownloadShare: SubscribedDownloadShare
    let subscribedDownloadShareList: SubscribedDownloadShareList
    
    let subscribedUploadShare: SubscribedUploadShare
    let subscribedUploadShareList: SubscribedUploadShareList
    
    init() {
        let modelFactory = ResponseModelFactory()
        self.subscribedNode = modelFactory.getTestResponseModel(SubscribedNode.self)!
        self.subscribedNodeList = modelFactory.getTestResponseModel(SubscribedNodeList.self)!
        
        self.subscribedDownloadShare = modelFactory.getTestResponseModel(SubscribedDownloadShare.self)!
        self.subscribedDownloadShareList = modelFactory.getTestResponseModel(SubscribedDownloadShareList.self)!
        
        self.subscribedUploadShare = modelFactory.getTestResponseModel(SubscribedUploadShare.self)!
        self.subscribedUploadShareList = modelFactory.getTestResponseModel(SubscribedUploadShareList.self)!
    }
    
    func getNodeSubscriptions(filter: String?, limit: Int?, offset: Int?, sort: String?, completion: @escaping (Dracoon.Result<SubscribedNodeList>) -> Void) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.subscribedNodeList))
        }
    }
    
    func updateNodeSubscriptions(subscribe: Bool, nodeIds: [Int64], completion: @escaping (Dracoon.Response) -> Void) {
        self.returnErrorOrResponse(completion)
    }
    
    func subscribeNode(nodeId: Int64, completion: @escaping (Dracoon.Result<SubscribedNode>) -> Void) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.subscribedNode))
        }
    }
    
    func unsubscribeNode(nodeId: Int64, completion: @escaping (Dracoon.Response) -> Void) {
        self.returnErrorOrResponse(completion)
    }
    
    func getDownloadShareSubscriptions(filter: String?, limit: Int?, offset: Int?, sort: String?, completion: @escaping (Dracoon.Result<SubscribedDownloadShareList>) -> Void) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.subscribedDownloadShareList))
        }
    }
    
    func updateDownloadShareSubscriptions(subscribe: Bool, shareIds: [Int64], completion: @escaping (Dracoon.Response) -> Void) {
        self.returnErrorOrResponse(completion)
    }
    
    func subscribeDownloadShare(shareId: Int64, completion: @escaping (Dracoon.Result<SubscribedDownloadShare>) -> Void) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.subscribedDownloadShare))
        }
    }
    
    func unsubscribeDownloadShare(shareId: Int64, completion: @escaping (Dracoon.Response) -> Void) {
        self.returnErrorOrResponse(completion)
    }
    
    func getUploadShareSubscriptions(filter: String?, limit: Int?, offset: Int?, sort: String?, completion: @escaping (Dracoon.Result<SubscribedUploadShareList>) -> Void) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.subscribedUploadShareList))
        }
    }
    
    func updateUploadShareSubscriptions(subscribe: Bool, shareIds: [Int64], completion: @escaping (Dracoon.Response) -> Void) {
        self.returnErrorOrResponse(completion)
    }
    
    func subscribeUploadShare(shareId: Int64, completion: @escaping (Dracoon.Result<SubscribedUploadShare>) -> Void) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.subscribedUploadShare))
        }
    }
    
    func unsubscribeUploadShare(shareId: Int64, completion: @escaping (Dracoon.Response) -> Void) {
        self.returnErrorOrResponse(completion)
    }
    
    private func returnErrorOrResponse(_ completion: @escaping (Dracoon.Response) -> Void) {
        if let error = self.error {
            completion(Dracoon.Response(error: error))
        } else {
            completion(Dracoon.Response(error: nil))
        }
    }
    
}
