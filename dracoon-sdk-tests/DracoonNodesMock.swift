//
//  DracoonNodesMock.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 30.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Alamofire
import crypto_sdk
import dracoon_sdk

class DracoonNodesMock: DracoonNodes {
    
    var error: DracoonError?
    var nodeIsEncrypted = false
    
    var nodeListResponse: NodeList
    var nodeResponse: Node
    
    var commentListResponse: CommentList
    var commentResponse: Comment
    
    var createFileUploadResponse: CreateFileUploadResponse
    
    var virusProtectionVerdictResponse: VirusProtectionVerdictResponse
    
    var roomPoliciesResponse: RoomPolicies
    
    init() {
        let modelFactory = ResponseModelFactory()
        self.nodeListResponse = modelFactory.getTestResponseModel(NodeList.self)!
        self.nodeResponse = modelFactory.getTestResponseModel(Node.self)!
        self.commentListResponse = modelFactory.getTestResponseModel(CommentList.self)!
        self.commentResponse = modelFactory.getTestResponseModel(Comment.self)!
        self.createFileUploadResponse = modelFactory.getTestResponseModel(CreateFileUploadResponse.self)!
        self.virusProtectionVerdictResponse = modelFactory.getTestResponseModel(VirusProtectionVerdictResponse.self)!
        self.roomPoliciesResponse = modelFactory.getTestResponseModel(RoomPolicies.self)!
    }
    
    func getNodes(parentNodeId: Int64, limit: Int64?, offset: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>) {
        self.returnErrorOrNodeList(completion)
    }
    
    func getNode(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        self.returnErrorOrNode(completion)
    }
    
    func getNode(nodePath: String, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        self.returnErrorOrNode(completion)
    }
    
    func isNodeEncrypted(nodeId: Int64, completion: @escaping (Dracoon.Result<Bool>) -> Void) {
        completion(Dracoon.Result.value(self.nodeIsEncrypted))
    }
    
    func getFileKey(nodeId: Int64, completion: @escaping (Dracoon.Result<EncryptedFileKey>) -> Void) {
        completion(Dracoon.Result.value(EncryptedFileKey(key: "encryptedFileKey", version: .RSA2048_AES256GCM, iv: "iv", tag: "tag")))
    }
    
    func createRoom(request: CreateRoomRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        self.returnErrorOrNode(completion)
    }
    
    func updateRoom(roomId: Int64, request: UpdateRoomRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        self.returnErrorOrNode(completion)
    }
    
    func updateRoomConfig(roomId: Int64, request: ConfigRoomRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        self.returnErrorOrNode(completion)
    }
    
    func createFolder(request: CreateFolderRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        self.returnErrorOrNode(completion)
    }
    
    func updateFolder(folderId: Int64, request: UpdateFolderRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        self.returnErrorOrNode(completion)
    }
    
    func updateFile(fileId: Int64, request: UpdateFileRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        self.returnErrorOrNode(completion)
    }
    
    func deleteNodes(request: DeleteNodesRequest, completion: @escaping (Dracoon.Response) -> Void) {
        self.returnErrorOrResponse(completion)
    }
    
    func copyNodes(nodeId: Int64, request: CopyNodesRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        self.returnErrorOrNode(completion)
    }
    
    func moveNodes(nodeId: Int64, request: MoveNodesRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        self.returnErrorOrNode(completion)
    }
    
    func uploadFile(uploadId: String, request: CreateFileUploadRequest, fileUrl: URL, callback: UploadCallback, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy, sessionConfig: URLSessionConfiguration?) {}
    
    func createFileUpload(request: CreateFileUploadRequest, fileSize: Int64, completion: @escaping DataRequest.DecodeCompletion<CreateFileUploadResponse>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.createFileUploadResponse))
        }
    }
    
    func completeFileUpload(request: CompleteUploadRequest, uploadUrl: URL, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        self.returnErrorOrNode(completion)
    }
    
    func cancelUpload(uploadId: String) {}
    
    func downloadFile(nodeId: Int64, targetUrl: URL, callback: DownloadCallback, sessionConfig: URLSessionConfiguration?) {}
    
    func cancelDownload(nodeId: Int64) {}
    
    func resumeBackgroundTasks() {}
    
    func searchNodes(parentNodeId: Int64, searchString: String, offset: Int64?, limit: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>) {
        self.returnErrorOrNodeList(completion)
    }
    
    func searchNodes(parentNodeId: Int64, searchString: String, depthLevel: Int?, filter: String?, sorting: String?, offset: Int64?, limit: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>) {
        self.returnErrorOrNodeList(completion)
    }
    
    func getFavorites(completion: @escaping DataRequest.DecodeCompletion<NodeList>) {
        self.returnErrorOrNodeList(completion)
    }
    
    func setFavorite(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<Node>) {
        self.returnErrorOrNode(completion)
    }
    
    func removeFavorite(nodeId: Int64, completion: @escaping (Dracoon.Response) -> Void) {
        self.returnErrorOrResponse(completion)
    }
    
    func createFileKey(version: PlainFileKeyVersion) throws -> PlainFileKey {
        return CryptoMock.getPlainFileKey()
    }
    
    func decryptFileKey(fileKey: EncryptedFileKey, privateKey: UserPrivateKey, password: String) throws -> PlainFileKey {
        return CryptoMock.getPlainFileKey()
    }
    
    func encryptFileKey(fileKey: PlainFileKey, publicKey: UserPublicKey) throws -> EncryptedFileKey {
        switch publicKey.version {
        case .RSA2048:
            return EncryptedFileKey(key: "encryptedFileKey", version: .RSA2048_AES256GCM, iv: "iv", tag: "tag")
        case .RSA4096:
            return EncryptedFileKey(key: "encryptedFileKey", version: .RSA4096_AES256GCM, iv: "iv", tag: "tag")
        @unknown default:
            throw DracoonError.keypair_failure(description: "Unknown version: \(publicKey.version)")
        }
    }
    
    func getComments(for nodeId: Int64, limit: Int64?, offset: Int64?, completion: @escaping DataRequest.DecodeCompletion<CommentList>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.commentListResponse))
        }
    }
    
    func createComment(for nodeId: Int64, commentText: String, completion: @escaping DataRequest.DecodeCompletion<Comment>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.commentResponse))
        }
    }
    
    func updateComment(commentId: Int64, updatedText: String, completion: @escaping DataRequest.DecodeCompletion<Comment>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.commentResponse))
        }
    }
    
    func deleteComment(commentId: Int64, completion: @escaping (Dracoon.Response) -> Void) {
        self.returnErrorOrResponse(completion)
    }
    
    func generateVirusProtectionVerdict(for nodeIds: [Int64], completion: @escaping (Alamofire.DataRequest.DecodeCompletion<dracoon_sdk.VirusProtectionVerdictResponse>)) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.virusProtectionVerdictResponse))
        }
    }
    
    func deleteMaliciousFilePermanently(nodeId: Int64, completion: @escaping (dracoon_sdk.Dracoon.Response) -> Void) {
        self.returnErrorOrResponse(completion)
    }
    
    func getRoomPolicies(roomId: Int64, completion: @escaping Alamofire.DataRequest.DecodeCompletion<dracoon_sdk.RoomPolicies>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.roomPoliciesResponse))
        }
    }
    
    // MARK: Helper
    
    private func returnErrorOrNodeList(_ completion: @escaping DataRequest.DecodeCompletion<NodeList>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.nodeListResponse))
        }
    }
    
    private func returnErrorOrNode(_ completion: @escaping DataRequest.DecodeCompletion<Node>) {
        if let error = self.error {
            completion(Dracoon.Result.error(error))
        } else {
            completion(Dracoon.Result.value(self.nodeResponse))
        }
    }
    
    private func returnErrorOrResponse(_ completion: @escaping (Dracoon.Response) -> Void) {
        if let error = self.error {
            completion(Dracoon.Response(error: error))
        } else {
            completion(Dracoon.Response(error: nil))
        }
    }
    
}
