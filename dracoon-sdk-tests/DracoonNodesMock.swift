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
    
    var nodeIsEncrypted = false
    
    func getNodes(parentNodeId: Int64, limit: Int64?, offset: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>) {}
    
    func getNode(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<Node>) {}
    
    func getNode(nodePath: String, completion: @escaping DataRequest.DecodeCompletion<Node>) {}
    
    func isNodeEncrypted(nodeId: Int64, completion: @escaping (Dracoon.Result<Bool>) -> Void) {
        completion(Dracoon.Result.value(self.nodeIsEncrypted))
    }
    
    func getFileKey(nodeId: Int64, completion: @escaping (Dracoon.Result<EncryptedFileKey>) -> Void) {
        completion(Dracoon.Result.value(EncryptedFileKey(key: "encryptedFileKey", version: "test", iv: "iv", tag: "tag")))
    }
    
    func createRoom(request: CreateRoomRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {}
    
    func updateRoom(roomId: Int64, request: UpdateRoomRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {}
    
    func createFolder(request: CreateFolderRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {}
    
    func updateFolder(folderId: Int64, request: UpdateFolderRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {}
    
    func updateFile(fileId: Int64, request: UpdateFileRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {}
    
    func deleteNodes(request: DeleteNodesRequest, completion: @escaping (Dracoon.Response) -> Void) {}
    
    func copyNodes(nodeId: Int64, request: CopyNodesRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {}
    
    func moveNodes(nodeId: Int64, request: MoveNodesRequest, completion: @escaping DataRequest.DecodeCompletion<Node>) {}
    
    func uploadFile(uploadId: String, request: CreateFileUploadRequest, fileUrl: URL, callback: UploadCallback, resolutionStrategy: CompleteUploadRequest.ResolutionStrategy) {}
    
    func cancelUpload(uploadId: String) {}
    
    func downloadFile(nodeId: Int64, targetUrl: URL, callback: DownloadCallback) {}
    
    func cancelDownload(nodeId: Int64) {}
    
    func searchNodes(parentNodeId: Int64, searchString: String, offset: Int64?, limit: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>) {}
    
    func searchNodes(parentNodeId: Int64, searchString: String, depthLevel: Int?, filter: String?, offset: Int64?, limit: Int64?, completion: @escaping DataRequest.DecodeCompletion<NodeList>) {}
    
    func getFavorites(completion: @escaping DataRequest.DecodeCompletion<NodeList>) {}
    
    func setFavorite(nodeId: Int64, completion: @escaping DataRequest.DecodeCompletion<Node>) {}
    
    func removeFavorite(nodeId: Int64, completion: @escaping (Dracoon.Response) -> Void) {}
    
    func createFileKey(version: String) throws -> PlainFileKey {
        return CryptoMock.getPlainFileKey()
    }
    
    func decryptFileKey(fileKey: EncryptedFileKey, privateKey: UserPrivateKey, password: String) throws -> PlainFileKey {
        return CryptoMock.getPlainFileKey()
    }
    
    func encryptFileKey(fileKey: PlainFileKey, publicKey: UserPublicKey) throws -> EncryptedFileKey {
        return EncryptedFileKey(key: "encryptedFileKey", version: "test", iv: "iv", tag: "tag")
    }
    
    
}
