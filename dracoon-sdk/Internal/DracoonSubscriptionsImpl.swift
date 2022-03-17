//
//  DracoonSubscriptionsImpl.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 04.03.22.
//  Copyright © 2022 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

class DracoonSubscriptionsImpl: DracoonSubscriptions {
    
    let session: Alamofire.Session
    let serverUrl: URL
    let apiPath: String
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    
    init(config: DracoonRequestConfig) {
        self.session = config.session
        self.serverUrl = config.serverUrl
        self.apiPath = config.apiPath
        self.encoder = config.encoder
        self.decoder = config.decoder
    }
    
    private enum ApiSuffix: String {
        case nodes = "nodes"
        case download_shares = "download_shares"
        case upload_shares = "upload_shares"
    }
    
    func getNodeSubscriptions(filter: String?, limit: Int?, offset: Int?, sort: String?, completion: @escaping (Dracoon.Result<SubscribedNodeList>) -> Void) {
        self.getSubscriptions(filter: filter, limit: limit, offset: offset, sort: sort, apiSuffix: .nodes, completion: completion)
    }
    
    func updateNodeSubscriptions(subscribe: Bool, nodeIds: [Int64], completion: @escaping (Dracoon.Response) -> Void) {
        self.updateSubscriptions(subscribe: subscribe, ids: nodeIds, apiSuffix: .nodes, completion: completion)
    }
    
    func subscribeNode(nodeId: Int64, completion: @escaping (Dracoon.Result<SubscribedNode>) -> Void) {
        self.subscribe(id: nodeId, apiSuffix: .nodes, completion: completion)
    }
    
    func unsubscribeNode(nodeId: Int64, completion: @escaping (Dracoon.Response) -> Void) {
        self.unsubscribe(id: nodeId, apiSuffix: .nodes, completion: completion)
    }
    
    func getDownloadShareSubscriptions(filter: String?, limit: Int?, offset: Int?, sort: String?, completion: @escaping (Dracoon.Result<SubscribedDownloadShareList>) -> Void) {
        self.getSubscriptions(filter: filter, limit: limit, offset: offset, sort: sort, apiSuffix: .download_shares, completion: completion)
    }
    
    func updateDownloadShareSubscriptions(subscribe: Bool, shareIds: [Int64], completion: @escaping (Dracoon.Response) -> Void) {
        self.updateSubscriptions(subscribe: subscribe, ids: shareIds, apiSuffix: .download_shares, completion: completion)
    }
    
    func subscribeDownloadShare(shareId: Int64, completion: @escaping (Dracoon.Result<SubscribedDownloadShare>) -> Void) {
        self.subscribe(id: shareId, apiSuffix: .download_shares, completion: completion)
    }
    
    func unsubscribeDownloadShare(shareId: Int64, completion: @escaping (Dracoon.Response) -> Void) {
        self.unsubscribe(id: shareId, apiSuffix: .download_shares, completion: completion)
    }
    
    func getUploadShareSubscriptions(filter: String?, limit: Int?, offset: Int?, sort: String?, completion: @escaping (Dracoon.Result<SubscribedUploadShareList>) -> Void) {
        self.getSubscriptions(filter: filter, limit: limit, offset: offset, sort: sort, apiSuffix: .upload_shares, completion: completion)
    }
    
    func updateUploadShareSubscriptions(subscribe: Bool, shareIds: [Int64], completion: @escaping (Dracoon.Response) -> Void) {
        self.updateSubscriptions(subscribe: subscribe, ids: shareIds, apiSuffix: .upload_shares, completion: completion)
    }
    
    func subscribeUploadShare(shareId: Int64, completion: @escaping (Dracoon.Result<SubscribedUploadShare>) -> Void) {
        self.subscribe(id: shareId, apiSuffix: .upload_shares, completion: completion)
    }
    
    func unsubscribeUploadShare(shareId: Int64, completion: @escaping (Dracoon.Response) -> Void) {
        self.unsubscribe(id: shareId, apiSuffix: .upload_shares, completion: completion)
    }
    
    private func getSubscriptions<T>(filter: String?, limit: Int?, offset: Int?, sort: String?, apiSuffix: ApiSuffix, completion: @escaping (Dracoon.Result<T>) -> Void) where T : Codable {
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/subscriptions/\(apiSuffix.rawValue)"
        
        var parameters: Parameters = [:]
        
        if let filter = filter {
            parameters["filter"] = filter
        }
        
        if let limit = limit {
            parameters["limit"] = limit
        }
        
        if let offset = offset {
            parameters["offset"] = offset
        }
        
        if let sort = sort {
            parameters["sort"] = sort
        }
        
        self.session.request(requestUrl, method: .get, parameters: parameters)
            .validate()
            .decode(T.self, decoder: self.decoder, requestType: .other, completion: completion)
    }
    
    private func updateSubscriptions(subscribe: Bool, ids: [Int64], apiSuffix: ApiSuffix, completion: @escaping (Dracoon.Response) -> Void) {
        let request = UpdateSubscriptionsBulkRequest(isSubscribed: subscribe, objectIds: ids)
        do {
            let jsonBody = try encoder.encode(request)
            
            let requestUrl = serverUrl.absoluteString + apiPath + "/user/subscriptions/\(apiSuffix.rawValue)"
            
            var urlRequest = URLRequest(url: URL(string: requestUrl)!)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonBody
            
            self.session.request(urlRequest)
                .validate()
                .handleResponse(decoder: self.decoder, completion: completion)
            
        } catch {
            completion(Dracoon.Response(error: DracoonError.encode(error: error)))
        }
    }
    
    private func subscribe<T>(id: Int64, apiSuffix: ApiSuffix, completion: @escaping (Dracoon.Result<T>) -> Void) where T : Codable {
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/subscriptions/\(apiSuffix.rawValue)/\(String(id))"
        
        var urlRequest = URLRequest(url: URL(string: requestUrl)!)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        
        self.session.request(urlRequest)
            .validate()
            .decode(T.self, decoder: self.decoder, requestType: .other, completion: completion)
    }
    
    private func unsubscribe(id: Int64, apiSuffix: ApiSuffix, completion: @escaping (Dracoon.Response) -> Void) {
        let requestUrl = serverUrl.absoluteString + apiPath + "/user/subscriptions/\(apiSuffix.rawValue)/\(String(id))"
        
        self.session.request(requestUrl, method: .delete)
            .validate()
            .handleResponse(decoder: self.decoder, completion: completion)
    }
}

