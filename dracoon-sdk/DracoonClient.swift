//
//  DracoonClient.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk


public protocol DracoonClient {
    var server: DracoonServer { get }
    var account: DracoonAccount { get }
    var config: DracoonConfig { get }
    var users: DracoonUsers { get }
    var groups: DracoonGroups { get }
    var nodes: DracoonNodes { get }
    var shares: DracoonShares { get }
    var settings: DracoonSettings { get }
    
    func getAccessToken() -> String?
    func getRefreshToken() -> String?
}


public protocol DracoonServer {
    func getServerVersion(completion: @escaping DataRequest.DecodeCompletion<SoftwareVersionData>)
    func getServerTime(completion: @escaping DataRequest.DecodeCompletion<SdsServerTime>)
}

public protocol DracoonAccount {
    func getUserAccount(completion: @escaping DataRequest.DecodeCompletion<UserAccount>)
    func getCustomerAccount(completion: @escaping DataRequest.DecodeCompletion<CustomerData>)
    func generateUserKeyPair(password: String) throws -> UserKeyPair
    func setUserKeyPair(password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void)
    func getUserKeyPair(completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void)
    func checkUserKeyPairPassword(password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void)
    func deleteUserKeyPair(completion: @escaping (Dracoon.Response) -> Void)
}

public protocol DracoonConfig {
    func getSystemDefaults(completion: @escaping DataRequest.DecodeCompletion<SystemDefaults>)
    func getGeneralSettings(completion: @escaping DataRequest.DecodeCompletion<GeneralSettings>)
    func getInfrastructureProperties(completion: @escaping DataRequest.DecodeCompletion<InfrastructureProperties>)
}

public protocol DracoonUsers {}

public protocol DracoonGroups {}

public protocol DracoonSettings {
    func getServerSettings(completion: @escaping (Dracoon.Result<CustomerSettingsResponse>) -> Void)
    func putServerSettings(request: CustomerSettingsRequest, completion: @escaping (Dracoon.Result<CustomerSettingsResponse>) -> Void) 
}

public protocol DracoonNodes {
    func getNodes(parentNodeId: Int64, limit: Int64?, offset: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>)
    func getNode(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<Node>)
    func getNode(nodePath: String, completion: @escaping DataRequest.DecodeCompletion<Node>)
    func isNodeEncrypted(nodeId: Int64, completion: @escaping (Dracoon.Result<Bool>) -> Void)
    func getFileKey(nodeId: Int64, completion: @escaping (Dracoon.Result<EncryptedFileKey>) -> Void)
    
    func createRoom(request: CreateRoomRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)
    func updateRoom(roomId: Int64, request: UpdateRoomRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)
    func createFolder(request: CreateFolderRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)
    func updateFolder(folderId: Int64, request: UpdateFolderRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)
    func updateFile(fileId: Int64, request: UpdateFileRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)
    func deleteNodes(request: DeleteNodesRequest, completion: @escaping (Dracoon.Response) -> Void)
    func copyNodes(nodeId: Int64, request: CopyNodesRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)
    func moveNodes(nodeId: Int64, request: MoveNodesRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)
    
    func uploadFile(uploadId: String, request: CreateFileUploadRequest, filePath: URL, callback: UploadCallback, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy)
    func cancelUpload(uploadId: String)
    func downloadFile(nodeId: Int64, targetUrl: URL, callback: DownloadCallback)
    func cancelDownload(nodeId: Int64)
    
    func searchNodes(parentNodeId: Int64, searchString: String, offset: Int64?, limit: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>)
    func getFavorites(completion: @escaping DataRequest.DecodeCompletion<NodeList>)
    func setFavorite(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<Node>)
    func removeFavorite(nodeId: Int64, completion: @escaping (Dracoon.Response) -> Void)
    
    func createFileKey(version: String) throws -> PlainFileKey
    func decryptFileKey(fileKey: EncryptedFileKey, privateKey: UserPrivateKey, password: String) throws -> PlainFileKey
    func encryptFileKey(fileKey: PlainFileKey, publicKey: UserPublicKey) throws -> EncryptedFileKey
}

public protocol DracoonShares {
    func createDownloadShare(nodeId: Int64, password: String?, completion: @escaping (Dracoon.Result<DownloadShare>) -> Void)
    func requestCreateDownloadShare(request: CreateDownloadShareRequest, completion: @escaping (Dracoon.Result<DownloadShare>) -> Void)
    func getDownloadShares(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<DownloadShareList>)
    func getDownloadShareQrCode(shareId: Int64, completion: @escaping (Dracoon.Result<DownloadShare>) -> Void)
    func createUploadShare(nodeId: Int64, name: String, password: String?, completion: @escaping (Dracoon.Result<UploadShare>) -> Void)
    func requestCreateUploadShare(request: CreateUploadShareRequest, completion: @escaping (Dracoon.Result<UploadShare>) -> Void)
    func getUploadShares(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<UploadShareList>)
    func getUploadShareQrCode(shareId: Int64, completion: @escaping (Dracoon.Result<UploadShare>) -> Void)
}
