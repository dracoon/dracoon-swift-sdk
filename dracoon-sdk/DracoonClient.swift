//
//  DracoonClient.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation
import Alamofire
import crypto_sdk


/// DracoonClient is the main class of DRACOON SDK.
/// It contains several handlers which group the SDK functions logically.
public protocol DracoonClient {
    var server: DracoonServer { get }
    var account: DracoonAccount { get }
    var config: DracoonConfig { get }
    var users: DracoonUsers { get }
    var groups: DracoonGroups { get }
    var nodes: DracoonNodes { get }
    var shares: DracoonShares { get }
    var settings: DracoonSettings { get }
    var subscriptions: DracoonSubscriptions { get }

    /// Get current OAuth access token.
    ///
    /// - Returns: The token if available.
    func getAccessToken() -> String?

    /// Get current OAuth refresh token.
    ///
    /// - Returns: The token if available.
    func getRefreshToken() -> String?
    
    /// Revoke current OAuth tokens
    ///
    func revokeOAuthToken()

    /// Sets rate limit if date is in the future.
    ///
    /// - Parameter date: The expiration date of the rate limit.
    func restoreRateLimitExpiration(_ date: Date)
}

// MARK: DracoonServer

public protocol DracoonServer {
    /// Retrieves the server's version.
    ///
    /// - Parameter completion: Returns [version data](x-source-tag://SoftwareVersionData) on success or an error.
    func getServerVersion(completion: @escaping DataRequest.DecodeCompletion<SoftwareVersionData>)

    /// Retrieves the server's time.
    ///
    /// - Parameter completion: Returns [server time](x-source-tag://SdsServerTime) on success or an error.
    func getServerTime(completion: @escaping DataRequest.DecodeCompletion<SdsServerTime>)
}

// MARK: DracoonAccount

public protocol DracoonAccount {
    /// Retrieves user account information.
    ///
    /// - Parameter completion: Returns [user account information](x-source-tag://UserAccount) on success or an error.
    func getUserAccount(completion: @escaping DataRequest.DecodeCompletion<UserAccount>)

    /// Retrieves customer account information.
    ///
    /// - Parameter completion: Returns [customer account information](x-source-tag://CustomerData) on success or an error.
    func getCustomerAccount(completion: @escaping DataRequest.DecodeCompletion<CustomerData>)

    /// Generates a RSA keypair. See [Crypto SDK](https://github.com/dracoon/dracoon-swift-crypto-sdk) for more information.
    ///
    /// - Parameters:
    ///     - version: The version of the user key pair
    ///     - password: The password used to encrypt the private key
    /// - Returns: The generated keypair
    /// - Throws: CryptoError if an error occured during key pair generation
    func generateUserKeyPair(version: UserKeyPairVersion, password: String) throws -> UserKeyPair

    /// Generates and sets the user's encryption key pair. See [Crypto SDK](https://github.com/dracoon/dracoon-swift-crypto-sdk) for more information.
    ///
    /// - Parameters:
    ///   - version: The version of the user key pair
    ///   - password: The password used to encrypt the private key
    ///   - completion: Returns the [user's key pair](x-source-tag://UserKeyPairContainer) on success or an error.
    func setUserKeyPair(version: UserKeyPairVersion, password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void)

    /// API version up to 4.24.0: Retrieves the user's key pair.
    /// API version from 4.24.0: Retrieves the user's highest preference key pair.
    ///
    /// - Parameter completion: Returns the user's highest preference key pair on success or an error
    func getUserKeyPair(completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void)

    /// Retrieves the user's key pair.
    /// - Requires:  API version from 4.24.0.
    ///
    /// - Parameters:
    ///   - version: The version of the user key pair
    ///   - completion: Returns the user's key pair on success or an error
    func getUserKeyPair(version: UserKeyPairVersion, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void)

    /// API version up to 4.24.0: Checks if the user's private key can be decrypted with the provided password.
    /// API version from 4.24.0: Checks if the private key of the user's highest preference keypair can be decrypted with the provided password.
    ///
    /// - Parameters:
    ///   - password: The password used to encrypt the private key
    ///   - completion: Returns [user's key pair](x-source-tag://UserKeyPairContainer) on success or an error.
    func checkUserKeyPairPassword(password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void)

    /// Checks if the user's private key can be decrypted with the provided password.
    /// - Requires:  API version from 4.24.0.
    ///
    /// - Parameters:
    ///   - version: The version of the user key pair
    ///   - password: The password used to encrypt the private key
    ///   - completion: Returns [user's key pair](x-source-tag://UserKeyPairContainer) on success or an error.
    func checkUserKeyPairPassword(version: UserKeyPairVersion, password: String, completion: @escaping (Dracoon.Result<UserKeyPairContainer>) -> Void)

    /// API version up to 4.24.0: Deletes the user's keypair.
    /// API version from 4.24.0: Deletes the user's lowest preference keypair.
    ///
    /// - Parameter completion: Returns an empty response on success or an error.
    func deleteUserKeyPair(completion: @escaping (Dracoon.Response) -> Void)

    /// Deletes the user's keypair.
    /// - Requires:  API version from 4.24.0.
    ///
    /// - Parameters:
    ///   - version: The version of the user key pair
    ///   - completion: Returns an empty response on success or an error.
    func deleteUserKeyPair(version: UserKeyPairVersion, completion: @escaping (Dracoon.Response) -> Void)

    /// Retrieves the user's avatar.
    ///
    /// - Parameter completion: Returns user avatar on success or an error.
    func getUserAvatar(completion: @escaping (Dracoon.Result<Avatar>) -> Void)

    /// Retrieves and downloads the user's avatar.
    ///
    /// - Parameters:
    ///   - targetUrl: URL to which the avatar image will be downloaded.
    ///   - completion: Returns user avatar on success or an error.
    func downloadUserAvatar(targetUrl: URL, completion: @escaping (Dracoon.Result<Avatar>) -> Void)

    /// Updates the user's avatar.
    ///
    /// - Parameters:
    ///   - fileUrl: A file url pointing to an image
    ///   - completion: Returns the user's avatar on success or an error.
    func updateUserAvatar(fileUrl: URL, completion: @escaping (Dracoon.Result<Avatar>) -> Void)

    /// Deletes the user's avatar.
    ///
    /// - Parameter completion: Returns default avatar on success or an error.
    func deleteUserAvatar(completion: @escaping (Dracoon.Result<Avatar>) -> Void)

    /// Retrieve a list of user profile attributes.
    ///
    /// - Parameters:
    ///   - completion: Returns user profile attributes on success or an error.
    func getProfileAttributes(completion: @escaping (Dracoon.Result<AttributesResponse>) -> Void)

    /// Set custom user profile attributes.
    ///
    /// - Parameters:
    ///   - request: The [ProfileAttributesRequest](x-source-tag://ProfileAttributesRequest) model
    ///   - completion: Returns user profile attributes on success or an error.
    func updateProfileAttributes(request: ProfileAttributesRequest, completion: @escaping (Dracoon.Result<ProfileAttributes>) -> Void)

    /// Delete custom user profile attribute.
    ///
    /// - Parameters:
    ///   - key: The key of the stored [KeyValueEntry](x-source-tag://KeyValueEntry) to delete
    ///   - completion: Returns an empty response on success or an error.
    func deleteProfileAttributes(key: String, completion: @escaping (Dracoon.Response) -> Void)
}

// MARK: DracoonConfig

public protocol DracoonConfig {
    /// Retrieves the server's system default settings.
    ///
    /// - Parameter completion: Returns [system defaults](x-source-tag://SystemDefaults) on success or an error.
    func getSystemDefaults(completion: @escaping DataRequest.DecodeCompletion<SystemDefaults>)

    /// Retrieves the server's general settings.
    ///
    /// - Parameter completion: Returns [general settings](x-source-tag://GeneralSettings) on success or an error.
    func getGeneralSettings(completion: @escaping DataRequest.DecodeCompletion<GeneralSettings>)

    /// Returns the server's infrastructure properties.
    ///
    /// - Parameter completion: Returns [infrastructure properties](x-source-tag://InfrastructureProperties) on success or an error.
    func getInfrastructureProperties(completion: @escaping DataRequest.DecodeCompletion<InfrastructureProperties>)

    /// Returns the server's password policies.
    /// - Requires: API version from 4.30.0.
    ///
    /// - Parameter completion: Returns [classification policies](x-source-tag://ClassificationPoliciesConfig) on success or an error.
    func getClassificationPolicies(completion: @escaping DataRequest.DecodeCompletion<ClassificationPoliciesConfig>)
    
    /// Returns the server's password policies.
    /// - Requires: API version from 4.14.0.
    ///
    /// - Parameter completion: Returns [password policies](x-source-tag://PasswordPoliciesConfig) on success or an error.
    func getPasswordPolicies(completion: @escaping DataRequest.DecodeCompletion<PasswordPoliciesConfig>)

    /// Returns a list of available algorithms.
    /// - Requires: API version from 4.24.0.
    ///
    /// - Parameter completion: Returns an [algorithm version list](x-source-tag://AlgorithmVersionInfoList) on success or an error.
    func getCryptoAlgorithms(completion: @escaping DataRequest.DecodeCompletion<AlgorithmVersionInfoList>)
}

// MARK: DracoonUsers

public protocol DracoonUsers {
    /// Downloads the user's avatar.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user
    ///   - avatarUuid: The ID string of the avatar
    ///   - targetUrl: URL to which the avatar image will be downloaded.
    ///   - completion: Returns user avatar on success or an error.
    func downloadUserAvatar(userId: Int64, avatarUuid: String, targetUrl: URL, completion: @escaping (Dracoon.Response) -> Void)
}

// MARK: DracoonSubscriptions

public protocol DracoonSubscriptions {
    
    /// Retrieve a list of subscribed nodes for current user.
    ///
    /// Filtering:
    /// All filter fields are connected via logical conjunction (AND)
    /// Filter string syntax: FIELD_NAME:OPERATOR:VALUE[:VALUE...]
    /// Example:
    /// authParentId:eq:#
    /// Get download shares where authParentId equals #.
    ///
    /// Filtering options:
    /// FIELD NAME:OPERATOR:VALUE
    /// nodeId:eq:long value
    /// authParentId:eq:long value
    ///
    /// Sorting:
    /// Sort string syntax: FIELD_NAME:ORDER
    /// ORDER can be asc or desc.
    /// Multiple sort criteria are possible.
    /// Fields are connected via logical conjunction AND.
    /// Example:
    /// nodeId:desc|authParentId:asc
    /// Sort by nodeId descending AND authParentId ascending.
    ///
    /// Sorting options:
    /// FIELD NAME
    /// nodeId
    /// authParentId
    ///
    /// - Requires: API version from 4.20.0
    ///
    /// - Parameters:
    ///   - filter: Filter string
    ///   - limit: Range limit. Maximum 500. For more results please use paging with offset and limit.
    ///   - offset: Range offset
    ///   - sort: Sort string
    ///   - completion: Returns a [list of subscribed nodes](x-source-tag://SubscribedNodeList) on success or an error.
    func getNodeSubscriptions(filter: String?, limit: Int?, offset: Int?, sort: String?, completion: @escaping (Dracoon.Result<SubscribedNodeList>) -> Void)
    
    /// Subscribe/Unsubscribe nodes for notifications.
    /// Maximum number of subscriptions is 200.
    ///
    /// - Requires: API version from 4.25.0
    ///
    /// - Parameters:
    ///   - subscribe: Determines if subscriptions of share IDs in array are created or deleted.
    ///   - nodeIds: List of node IDs to (un)subscribe.
    ///   - completion: Returns an empty response on success or an error.
    func updateNodeSubscriptions(subscribe: Bool, nodeIds: [Int64], completion: @escaping (Dracoon.Response) -> Void)
    
    /// Subscribe node for notifications.
    ///
    /// - Requires: API version from 4.20.0
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node to be subscribed.
    ///   - completion: Returns the [subscribed node](x-source-tag://SubscribedNode) on success or an error.
    func subscribeNode(nodeId: Int64, completion: @escaping (Dracoon.Result<SubscribedNode>) -> Void)
    
    /// Unsubscribe node from notifications.
    ///
    /// - Requires: API version from 4.20.0
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node to be unsubscribed.
    ///   - completion: Returns an empty response on success or an error.
    func unsubscribeNode(nodeId: Int64, completion: @escaping (Dracoon.Response) -> Void)
    
    /// Retrieve a list of subscribed Download Shares for current user.
    ///
    /// Filtering:
    /// All filter fields are connected via logical conjunction (AND)
    /// Filter string syntax: FIELD_NAME:OPERATOR:VALUE[:VALUE...]
    /// Example:
    /// authParentId:eq:#
    /// Get download shares where authParentId equals #.
    ///
    /// Filtering options:
    /// FIELD NAME:OPERATOR:VALUE
    /// downloadShareId:eq:long value
    /// authParentId:eq:long value
    ///
    /// Sorting:
    /// Sort string syntax: FIELD_NAME:ORDER
    /// ORDER can be asc or desc.
    /// Multiple sort criteria are possible.
    /// Fields are connected via logical conjunction AND.
    /// Example:
    /// downloadShareId:desc|authParentId:asc
    /// Sort by downloadShareId descending AND authParentId ascending.
    ///
    /// Sorting options:
    /// FIELD NAME
    /// downloadShareId
    /// authParentId
    ///
    /// - Requires: API version from 4.20.0
    ///
    /// - Parameters:
    ///   - filter: Filter string
    ///   - limit: Range limit. Maximum 500. For more results please use paging with offset and limit.
    ///   - offset: Range offset
    ///   - sort: Sort string
    ///   - completion: Returns a [list of subscribed Download Shares](x-source-tag://SubscribedDownloadShareList) on success or an error.
    func getDownloadShareSubscriptions(filter: String?, limit: Int?, offset: Int?, sort: String?, completion: @escaping (Dracoon.Result<SubscribedDownloadShareList>) -> Void)
    
    /// Subscribe/Unsubscribe download shares for notifications.
    /// Maximum number of subscriptions is 200.
    ///
    /// - Requires: API version from 4.25.0
    ///
    /// - Parameters:
    ///   - subscribe: Determines if subscriptions of share IDs in array are created or deleted.
    ///   - shareIds: List of share IDs to (un)subscribe.
    ///   - completion: Returns an empty response on success or an error.
    func updateDownloadShareSubscriptions(subscribe: Bool, shareIds: [Int64], completion: @escaping (Dracoon.Response) -> Void)
    
    /// Subscribe Download Share for notifications.
    ///
    /// - Requires: API version from 4.20.0
    ///
    /// - Parameters:
    ///   - shareId: The ID of the share to be subscribed.
    ///   - completion: Returns the [subscribed Download Share](x-source-tag://SubscribedDownloadShare) on success or an error.
    func subscribeDownloadShare(shareId: Int64, completion: @escaping (Dracoon.Result<SubscribedDownloadShare>) -> Void)
    
    /// Unsubscribe Download Share from notifications.
    ///
    /// - Requires: API version from 4.20.0
    ///
    /// - Parameters:
    ///   - shareId: The ID of the share to be unsubscribed.
    ///   - completion: Returns an empty response on success or an error.
    func unsubscribeDownloadShare(shareId: Int64, completion: @escaping (Dracoon.Response) -> Void)
    
    /// Retrieve a list of subscribed Upload Shares for current user.
    ///
    /// Filtering:
    /// All filter fields are connected via logical conjunction (AND)
    /// Filter string syntax: FIELD_NAME:OPERATOR:VALUE[:VALUE...]
    /// Example:
    /// targetNodeId:eq:#
    /// Get upload shares where targetNodeId equals #.
    ///
    /// Filtering options:
    /// FIELD NAME:OPERATOR:VALUE
    /// uploadShareId:eq:long value
    /// targetNodeId:eq:long value
    ///
    /// Sorting:
    /// Sort string syntax: FIELD_NAME:ORDER
    /// ORDER can be asc or desc.
    /// Multiple sort criteria are possible.
    /// Fields are connected via logical conjunction AND.
    /// Example:
    /// uploadShareId:desc|targetNodeId:asc
    /// Sort by uploadShareId descending AND targetNodeId ascending.
    ///
    /// Sorting options:
    /// FIELD NAME
    /// uploadShareId
    /// targetNodeId
    ///
    /// - Requires: API version from 4.24.0
    ///
    /// - Parameters:
    ///   - filter: Filter string
    ///   - limit: Range limit. Maximum 500. For more results please use paging with offset and limit.
    ///   - offset: Range offset
    ///   - sort: Sort string
    ///   - completion: Returns a [list of subscribed Upload Shares](x-source-tag://SubscribedUploadShareList) on success or an error.
    func getUploadShareSubscriptions(filter: String?, limit: Int?, offset: Int?, sort: String?, completion: @escaping (Dracoon.Result<SubscribedUploadShareList>) -> Void)
    
    /// Subscribe/Unsubscribe upload shares for notifications.
    /// Maximum number of subscriptions is 200.
    ///
    /// - Requires: API version from 4.25.0
    ///
    /// - Parameters:
    ///   - subscribe: Determines if subscriptions of share IDs in array are created or deleted.
    ///   - shareIds: List of share IDs to (un)subscribe.
    ///   - completion: Returns an empty response on success or an error.
    func updateUploadShareSubscriptions(subscribe: Bool, shareIds: [Int64], completion: @escaping (Dracoon.Response) -> Void)
    
    /// Subscribe Upload Share for notifications.
    ///
    /// - Requires: API version from 4.24.0
    ///
    /// - Parameters:
    ///   - shareId: The ID of the share to be subscribed.
    ///   - completion: Returns the [subscribed Upload Share](x-source-tag://SubscribedUploadShare) on success or an error.
    func subscribeUploadShare(shareId: Int64, completion: @escaping (Dracoon.Result<SubscribedUploadShare>) -> Void)
    
    /// Unsubscribe Upload Share from notifications.
    ///
    /// - Requires: API version from 4.24.0
    ///
    /// - Parameters:
    ///   - shareId: The ID of the share to be unsubscribed.
    ///   - completion: Returns an empty response on success or an error.
    func unsubscribeUploadShare(shareId: Int64, completion: @escaping (Dracoon.Response) -> Void)
}

public protocol DracoonGroups {}

// MARK: DracoonSettings

public protocol DracoonSettings {
    /// Retrieves the customer's settings.
    ///
    /// - Parameter completion: Returns the [customer's settings](x-source-tag://CustomerSettingsResponse) on success or an error.
    func getServerSettings(completion: @escaping (Dracoon.Result<CustomerSettingsResponse>) -> Void)

    /// Updates the customer's settings. The logged in user must have the role Config Manager for the call to succeed.
    ///
    /// - Parameters:
    ///   - request: The [CustomerSettingsRequest](x-source-tag://CustomerSettingsRequest) model
    ///   - completion: Returns new [customer's settings](x-source-tag://CustomerSettingsResponse) on success or an error.
    func updateServerSettings(request: CustomerSettingsRequest, completion: @escaping (Dracoon.Result<CustomerSettingsResponse>) -> Void)
}

// MARK: DracoonNodes

public protocol DracoonNodes {
    /// Retrieves child nodes of a node. Parameters _offset_ and _limit_ restrict the result to a specific range.
    ///
    /// - Parameters:
    ///   - parentNodeId: The ID of the parent node. ID must be 0 (for root) or positive.
    ///   - limit: Limits the number of returned nodes. Must be positive.
    ///   - offset: Puts an offset on the returned nodes. Must be 0 or positive.
    ///   - completion: Returns a [list of nodes](x-source-tag://NodeList) on success or an error.
    func getNodes(parentNodeId: Int64, limit: Int64?, offset: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>)

    /// Retrieves a node.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node.
    ///   - completion: Returns the [node](x-source-tag://Node) on success or an error.
    func getNode(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<Node>)

    /// Retrieves a node.
    ///
    /// - Parameters:
    ///   - nodePath: The path of the node.
    ///   - completion: Returns the [node](x-source-tag://Node) on success or an error.
    func getNode(nodePath: String, completion: @escaping DataRequest.DecodeCompletion<Node>)

    /// Checks if a node is encrypted.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node.
    ///   - completion: Returns if node is encrypted on success or an error.
    func isNodeEncrypted(nodeId: Int64, completion: @escaping (Dracoon.Result<Bool>) -> Void)

    /// Retrieves the file key of a node.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node.
    ///   - completion: Returns the encrypted file key on success or an error.
    func getFileKey(nodeId: Int64, completion: @escaping (Dracoon.Result<EncryptedFileKey>) -> Void)

    /// Creates a new room.
    ///
    /// - Parameters:
    ///   - request: The [CreateRoomRequest](x-source-tag://CreateRoomRequest) model
    ///   - completion: Returns the new [node](x-source-tag://Node) on success or an error.
    func createRoom(request: CreateRoomRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)

    /// Updates a room.
    ///
    /// - Parameters:
    ///   - roomId: The ID of the room node.
    ///   - request: The [UpdateRoomRequest](x-source-tag://UpdateRoomRequest) model
    ///   - completion: Returns the updated [node](x-source-tag://Node) on success or an error.
    func updateRoom(roomId: Int64, request: UpdateRoomRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)
    
    /// Updates a room's configuration.
    ///
    /// - Parameters:
    ///   - roomId: The ID of the room node.
    ///   - request: The [ConfigRoomRequest](x-source-tag://ConfigRoomRequest) model
    ///   - completion: Returns the updated [node](x-source-tag://Node) on success or an error.
    func updateRoomConfig(roomId: Int64, request: ConfigRoomRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)
    
    /// Creates a new folder.
    ///
    /// - Parameters:
    ///   - request: The [CreateFolderRequest](x-source-tag://CreateFolderRequest) model
    ///   - completion: Returns the updated [node](x-source-tag://Node) on success or an error.
    func createFolder(request: CreateFolderRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)

    /// Updates a folder.
    ///
    /// - Parameters:
    ///   - folderId: The ID of the folder node
    ///   - request: The [UpdateFolderRequest](x-source-tag://UpdateFolderRequest) model
    ///   - completion: Returns the updated [node](x-source-tag://Node) on success or an error.
    func updateFolder(folderId: Int64, request: UpdateFolderRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)

    /// Updates a file.
    ///
    /// - Parameters:
    ///   - fileId: The ID of the file node
    ///   - request: The [UpdateFileRequest](x-source-tag://UpdateFileRequest) model
    ///   - completion: Returns the updated [node](x-source-tag://Node) on success or an error.
    func updateFile(fileId: Int64, request: UpdateFileRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)

    /// Deletes nodes.
    ///
    /// - Parameters:
    ///   - request: The [DeleteNodesRequest](x-source-tag://DeleteNodesRequest) model
    ///   - completion: Returns an empty response on success or an error.
    func deleteNodes(request: DeleteNodesRequest, completion: @escaping (Dracoon.Response) -> Void)

    /// Copies nodes to another parent. Nodes to be copied must be in same source parent and of type folder or file.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the target node
    ///   - request: The [CopyNodesRequest](x-source-tag://CopyNodesRequest) model
    ///   - completion: Returns the target [node](x-source-tag://Node) on success or an error.
    func copyNodes(nodeId: Int64, request: CopyNodesRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)

    /// Moves nodes to another parent. Nodes to be moved must be in the same source parent and of type folder or file.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the target node
    ///   - request: The [MoveNodesRequest](x-source-tag://MoveNodesRequest) model
    ///   - completion: Returns the target [node](x-source-tag://Node) on success or an error.
    func moveNodes(nodeId: Int64, request: MoveNodesRequest, completion: @escaping DataRequest.DecodeCompletion<Node>)

    /// Uploads a file.
    ///
    /// - Parameters:
    ///   - uploadId: An ID for the upload. Can be used to keep a reference.
    ///   - request: The [CreateFileUploadRequest](x-source-tag://CreateFileUploadRequest) model
    ///   - filePath: The path of the file to be uploaded
    ///   - callback: [UploadCallback](x-source-tag://UploadCallback) to inform about upload status
    ///   - resolutionStrategy: [CompleteUploadRequest.ResolutionStrategy](x-source-tag://CompleteUploadRequest.ResolutionStrategy) determines behavior if a file with the same name
    ///                         already exists in the target node.
    ///   - session: Optional sessionConfiguration used for the upload
    func uploadFile(uploadId: String, request: CreateFileUploadRequest, fileUrl: URL, callback: UploadCallback, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy, sessionConfig: URLSessionConfiguration?)

    /// Cancels a file upload.
    ///
    /// - Parameter uploadId: The ID of the upload to be canceled
    func cancelUpload(uploadId: String)
    
    /// Creates a file upload channel.
    ///
    /// - warning: You only have to use this if you want to implement your own custom upload. To use the build-in upload just use uploadFile(...).
    ///
    /// - Parameters:
    ///   - request: The [CreateFileUploadRequest](x-source-tag://CreateFileUploadRequest) model
    ///   - fileSize: The size of the file to be uploaded.
    ///   - completion: Returns the response [CreateFileUploadResponse](x-source-tag://CreateFileUploadResponse) on success or an error.
    func createFileUpload(request: CreateFileUploadRequest, fileSize: Int64, completion: @escaping DataRequest.DecodeCompletion<CreateFileUploadResponse>)
    
    /// Closes a file upload channel.
    ///
    /// - warning: You only have to use this if you want to implement your own custom upload. To use the build-in upload just use uploadFile(...).
    ///
    /// - Parameters:
    ///   - request: The [CompleteUploadRequest](x-source-tag://CompleteUploadRequest) model
    ///   - uploadUrl: The uploadUrl of the channel to be closed.
    ///   - completion: Returns the new node [Node](x-source-tag://Node) on success or an error.
    func completeFileUpload(request: CompleteUploadRequest, uploadUrl: URL, completion: @escaping DataRequest.DecodeCompletion<Node>)
    
    /// Downloads a file.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node to be downloaded
    ///   - targetUrl: The target download path
    ///   - callback: [DownloadCallback](x-source-tag://DownloadCallback) to inform about upload status
    ///   - session: Optional sessionConfiguration used for the download
    func downloadFile(nodeId: Int64, targetUrl: URL, callback: DownloadCallback, sessionConfig: URLSessionConfiguration?)

    /// Cancels a file download.
    ///
    /// - Parameter nodeId: The ID of the downloaded node
    func cancelDownload(nodeId: Int64)

    /// Resumes background tasks after application becomes active again
    /// If you started uploads or downloads with a background sessionConfiguration, this needs to be called in [UIApplicationDelegate.applicationDidBecomeActive](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622956-applicationdidbecomeactive).
    /// Otherwise the task will be completed, but your progress handler will not be called anymore.
    func resumeBackgroundTasks()

    /// Searches child nodes by their name. Parameters _offset_ and _limit_ restrict the result to a specific range.
    ///
    /// - Parameters:
    ///   - parentNodeId: The ID of the parent node
    ///   - searchString: Must not be empty.
    ///   - offset: Puts an offset on the returned nodes. Must be 0 or positive.
    ///   - limit: Limits the number of returned nodes. Must be positive.
    ///   - completion: Returns a [list of nodes](x-source-tag://NodeList) on success or an error.
    func searchNodes(parentNodeId: Int64, searchString: String, offset: Int64?, limit: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>)

    /// Searches child nodes by their name. Parameters _offset_ and _limit_ restrict the result to a specific range,
    /// _depthLevel_ determines how many node levels are searched (0 for top level nodes, -1 for full tree).
    /// _filter_ parameter can be used as follows:
    /// Filter string syntax: FIELD_NAME:OPERATOR:VALUE[:VALUE...]
    /// Examples:
    ///
    /// type:eq:room
    /// Get nodes where type equals room
    ///
    /// type:eq:file|createdAt:ge:2019-01-01
    /// Get nodes where type equals file AND file creation date is >= 2019-01-01
    ///
    /// _sorting_ parameter can be used as follows:
    /// Sort string syntax: FIELD_NAME:ORDER
    /// ORDER can be asc or desc.
    /// Multiple sort fields are NOT supported.
    /// Example:
    ///
    /// name:desc
    /// Sort by name descending.
    ///
    /// - Parameters:
    ///   - parentNodeId: The ID of the parent node.
    ///   - searchString: Must not be empty.
    ///   - depthLevel: Depth level of search
    ///   - filter: Filters for specific nodes
    ///   - sorting: Sort result by specific attribute
    ///   - offset: Puts an offset on the returned nodes. Must be 0 or positive.
    ///   - limit: Limits the number of returned nodes. Must be positive.
    ///   - completion: Returns a [list of nodes](x-source-tag://NodeList) on success or an error.
    func searchNodes(parentNodeId: Int64, searchString: String, depthLevel: Int?, filter: String?, sorting: String?, offset: Int64?, limit: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>)

    /// Get comments for a specific node.
    /// - Requires:  API version from 4.10.0.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node
    ///   - limit: Limits the number of returned nodes. Must be positive.
    ///   - offset: Puts an offset on the returned nodes. Must be 0 or positive.
    ///   - completion: Returns the [comments](x-source-tag://CommentList) on success or an error.
    func getComments(for nodeId: Int64, limit: Int64?, offset: Int64?, completion: @escaping DataRequest.DecodeCompletion<CommentList>)

    /// Create a comment for a specific node.
    /// - Requires:  API version from 4.10.0.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node
    ///   - commentText: The text of the comment
    ///   - completion: Returns the [comment](x-source-tag://Comment) on success or an error.
    func createComment(for nodeId: Int64, commentText: String, completion: @escaping DataRequest.DecodeCompletion<Comment>)

    /// Edit the text of an existing comment for a specific node.
    /// - Requires:  API version from 4.10.0.
    ///
    /// - Parameters:
    ///   - commentId: The ID of the comment
    ///   - updatedText: The updated text of the comment
    ///   - completion: Returns the updated [comment](x-source-tag://Comment) on success or an error.
    func updateComment(commentId: Int64, updatedText: String, completion: @escaping DataRequest.DecodeCompletion<Comment>)

    /// Delete an existing comment for a specific node.
    /// - Requires:  API version from 4.10.0.
    ///
    /// - Parameters:
    ///   - commentId: The ID of the comment
    ///   - completion: Returns an empty response on success or an error.
    func deleteComment(commentId: Int64, completion: @escaping (Dracoon.Response) -> Void)

    /// Rerieves favorite nodes.
    ///
    /// - Parameter completion: Returns a [list of nodes](x-source-tag://NodeList) on success or an error.
    func getFavorites(completion: @escaping DataRequest.DecodeCompletion<NodeList>)

    /// Marks a node as favorite.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node
    ///   - completion: Returns the favorited [node](x-source-tag://Node) on success or an error.
    func setFavorite(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<Node>)

    /// Unmarks a node as favorite.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node
    ///   - completion: Returns an empty response on success or an error.
    func removeFavorite(nodeId: Int64, completion: @escaping (Dracoon.Response) -> Void)

    /// Creates a FileKey. See [Crypto SDK](https://github.com/dracoon/dracoon-swift-crypto-sdk) for more information.
    ///
    /// - Parameter version: The crypto version to be used
    /// - Returns: The plain key
    /// - Throws: CryptoError if an error occured during key generation
    func createFileKey(version: PlainFileKeyVersion) throws -> PlainFileKey

    /// Decrypts a FileKey. See [Crypto SDK](https://github.com/dracoon/dracoon-swift-crypto-sdk) for more information.
    ///
    /// - Parameters:
    ///   - fileKey: The encrypted key
    ///   - privateKey: The private key of the user's key pair
    ///   - password: The password used to encrypt the private key
    /// - Returns: The plain key
    /// - Throws: CryptoError if an error occured during decryption
    func decryptFileKey(fileKey: EncryptedFileKey, privateKey: UserPrivateKey, password: String) throws -> PlainFileKey

    /// Encrypts a FileKey. See [Crypto SDK](https://github.com/dracoon/dracoon-swift-crypto-sdk) for more information.
    ///
    /// - Parameters:
    ///   - fileKey: The plain key
    ///   - publicKey: The public key of the user's key pair
    /// - Returns: The encrypted key
    /// - Throws: CryptoError if an error occured during encryption
    func encryptFileKey(fileKey: PlainFileKey, publicKey: UserPublicKey) throws -> EncryptedFileKey
}

public extension DracoonNodes {
    /// Downloads a file.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node to be downloaded
    ///   - targetUrl: The target download path
    ///   - callback: [DownloadCallback](x-source-tag://DownloadCallback) to inform about upload status
    func downloadFile(nodeId: Int64, targetUrl: URL, callback: DownloadCallback) {
        self.downloadFile(nodeId: nodeId, targetUrl: targetUrl, callback: callback, sessionConfig: nil)
    }
    /// Uploads a file.
    ///
    /// - Parameters:
    ///   - uploadId: An ID for the upload. Can be used to keep a reference.
    ///   - request: The [CreateFileUploadRequest](x-source-tag://CreateFileUploadRequest) model
    ///   - filePath: The path of the file to be uploaded
    ///   - callback: [UploadCallback](x-source-tag://UploadCallback) to inform about upload status
    ///   - resolutionStrategy: [CompleteUploadRequest.ResolutionStrategy](x-source-tag://CompleteUploadRequest.ResolutionStrategy) determines behavior if a file with the same name
    ///                         already exists in the target node.
    func uploadFile(uploadId: String, request: CreateFileUploadRequest, fileUrl: URL, callback: UploadCallback, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy) {
        self.uploadFile(uploadId: uploadId, request: request, fileUrl: fileUrl, callback: callback, resolutionStrategy: resolutionStrategy, sessionConfig: nil)
    }
    /// Searches child nodes by their name. Parameters _offset_ and _limit_ restrict the result to a specific range,
    /// _depthLevel_ determines how many node levels are searched (0 for top level nodes, -1 for full tree).
    /// _filter_ parameter can be used as follows:
    /// Filter string syntax: FIELD_NAME:OPERATOR:VALUE[:VALUE...]
    /// Examples:
    ///
    /// type:eq:room
    /// Get nodes where type equals room
    ///
    /// type:eq:file|createdAt:ge:2019-01-01
    /// Get nodes where type equals file AND file creation date is >= 2019-01-01
    ///
    /// - Parameters:
    ///   - parentNodeId: The ID of the parent node
    ///   - searchString: Must not be empty.
    ///   - depthLevel: Depth level of search
    ///   - filter: Filters for specific nodes
    ///   - offset: Puts an offset on the returned nodes. Must be 0 or positive.
    ///   - limit: Limits the number of returned nodes. Must be positive.
    ///   - completion: Returns a [list of nodes](x-source-tag://NodeList) on success or an error.
    func searchNodes(parentNodeId: Int64, searchString: String, depthLevel: Int?, filter: String?, offset: Int64?, limit: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>) {
        self.searchNodes(parentNodeId: parentNodeId, searchString: searchString, depthLevel: depthLevel, filter: filter, sorting: nil, offset: offset, limit: limit, completion: completion)
    }
}

// MARK: DracoonShares

public protocol DracoonShares {
    /// Creates a download share.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node
    ///   - password: Sets an access password to the share. Required if node is encrypted, otherwise optional.
    ///   - completion: Returns the [download share](x-source-tag://DownloadShare) on success or an error.
    func createDownloadShare(nodeId: Int64, password: String?, completion: @escaping (Dracoon.Result<DownloadShare>) -> Void)

    /// Creates a download share.
    ///
    /// - Parameters:
    ///   - request: The [CreateDownloadShareRequest](x-source-tag://CreateDownloadShareRequest) model
    ///   - completion: Returns the [download share](x-source-tag://DownloadShare) on success or an error.
    func requestCreateDownloadShare(request: CreateDownloadShareRequest, completion: @escaping (Dracoon.Result<DownloadShare>) -> Void)

    /// Retrieves existing download shares for a node.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node
    ///   - completion: Returns a [list of existing download shares](x-source-tag://DownloadShareList) on success or an error.
    func getDownloadShares(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<DownloadShareList>)
    
    /// Retrieves existing download shares.
    ///
    /// - Parameters:
    ///   - offset: Range offset
    ///   - limit: Range limit. Maximum 500. For more results please use paging with offset and limit.
    ///   - filter: Filter string
    ///   - sorting: Sort string
    ///   - completion: Returns a [list of existing download shares](x-source-tag://DownloadShareList) on success or an error.
    func getDownloadShares(offset: Int?, limit: Int?, filter: String?, sorting: String?, completion: @escaping DataRequest.DecodeCompletion<DownloadShareList>)

    /// Retrieves download share containing a QR code image.
    ///
    /// - Parameters:
    ///   - shareId: The ID of the download share
    ///   - completion: Returns the [download share](x-source-tag://DownloadShare) on success or an error.
    func getDownloadShareQrCode(shareId: Int64, completion: @escaping (Dracoon.Result<DownloadShare>) -> Void)

    /// Updates a download share.
    ///
    /// - Parameters:
    ///   - shareId: The ID of the share
    ///   - request: The [request](x-source-tag://UpdateDownloadShareRequest) containing the changes
    ///   - completion: Returns the [download share](x-source-tag://DownloadShare) on success or an error.
    func updateDownloadShare(shareId: Int64, request: UpdateDownloadShareRequest, completion: @escaping (Dracoon.Result<DownloadShare>) -> Void)

    /// Deletes a download share.
    ///
    /// - Parameters:
    ///   - shareId: The ID of the share
    ///   - completion: Returns an empty response on success or an error.
    func deleteDownloadShare(shareId: Int64, completion: @escaping (Dracoon.Response) -> Void)
    
    /// Deletes multiple download shares.
    /// [Since version 4.21.0]
    ///
    /// - Parameters:
    ///   - shareIds: The IDs of the shares
    ///   - completion: Returns an empty response on success or an error.
    func deleteDownloadShares(shareIds: [Int64], completion: @escaping (Dracoon.Response) -> Void)

    /// Creates an upload share.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node
    ///   - name: The name of the share. Required for API version < 4.10.0, otherwise optional.
    ///   - password: Sets an access password to the share.
    ///   - completion: Returns the [upload share](x-source-tag://UploadShare) on success or an error.
    func createUploadShare(nodeId: Int64, name: String?, password: String?, completion: @escaping (Dracoon.Result<UploadShare>) -> Void)

    /// Creates an upload share.
    ///
    /// - Parameters:
    ///   - request: The [CreateUploadShareRequest](x-source-tag://CreateUploadShareRequest) model
    ///   - completion: Returns the [upload share](x-source-tag://UploadShare) on success or an error.
    func requestCreateUploadShare(request: CreateUploadShareRequest, completion: @escaping (Dracoon.Result<UploadShare>) -> Void)

    /// Retrieves existing upload shares for a node.
    ///
    /// - Parameters:
    ///   - nodeId: The ID of the node
    ///   - completion: Returns a [list of existing upload shares](x-source-tag://UploadShareList) on success or an error.
    func getUploadShares(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<UploadShareList>)
    
    /// Retrieves existing upload shares for a node.
    ///
    /// - Parameters:
    ///   - offset: Range offset
    ///   - limit: Range limit. Maximum 500. For more results please use paging with offset and limit.
    ///   - filter: Filter string
    ///   - sorting: Sort string
    ///   - completion: Returns a [list of existing upload shares](x-source-tag://UploadShareList) on success or an error.
    func getUploadShares(offset: Int?, limit: Int?, filter: String?, sorting: String?, completion: @escaping DataRequest.DecodeCompletion<UploadShareList>)

    /// Retrieves upload share containing a QR code image.
    ///
    /// - Parameters:
    ///   - shareId: The ID of the upload share
    ///   - completion: Returns the [upload share](x-source-tag://UploadShare) on success or an error.
    func getUploadShareQrCode(shareId: Int64, completion: @escaping (Dracoon.Result<UploadShare>) -> Void)

    /// Updates an upload share.
    ///
    /// - Parameters:
    ///   - shareId: The ID of the share
    ///   - request: The [request](x-source-tag://UpdateUploadShareRequest) containing the changes
    ///   - completion: Returns the [upload share](x-source-tag://UploadShare) on success or an error.
    func updateUploadShare(shareId: Int64, request: UpdateUploadShareRequest, completion: @escaping (Dracoon.Result<UploadShare>) -> Void)

    /// Deletes an upload share.
    ///
    /// - Parameters:
    ///   - shareId: The ID of the share
    ///   - completion: Returns an empty response on success or an error.
    func deleteUploadShare(shareId: Int64, completion: @escaping (Dracoon.Response) -> Void)
    
    /// Deletes multiple upload shares.
    /// [Since version 4.21.0]
    ///
    /// - Parameters:
    ///   - shareIds: The IDs of the shares
    ///   - completion: Returns an empty response on success or an error.
    func deleteUploadShares(shareIds: [Int64], completion: @escaping (Dracoon.Response) -> Void)
}
