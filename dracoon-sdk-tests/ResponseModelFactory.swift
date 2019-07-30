//
//  ResponseModelFactory.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 25.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
@testable import dracoon_sdk

struct ResponseModelFactory {
    static func getTestResponseModel<E: Encodable>(_ type: E.Type) -> E? {
        if type == UserAccount.self {
            return self.getTestUserAccount() as? E
        } else if type == CustomerData.self {
            return self.getTestCustomerData() as? E
        } else if type == Node.self {
            return self.getNode() as? E
        } else if type == NodeList.self {
            return self.getNodeList() as? E
        } else if type == UserKeyPairContainer.self {
            return self.getUserKeyPairContainer() as? E
        } else if type == Avatar.self {
            return self.getUserAvatar() as? E
        } else if type == CreateFileUploadResponse.self {
            return self.getCreateFileUploadResponse() as? E
        } else if type == DownloadTokenGenerateResponse.self {
            return self.getDownloadTokenGenerateResponse() as? E
        }
        return nil
    }
    
    private static func getTestUserAccount() -> UserAccount {
        
        let userRoles = RoleList(items: [])
        
        let responseModel = UserAccount(_id: 42, login: "test", needsToChangePassword: false, firstName: "Test", lastName: "Test", lockStatus: 0, hasManageableRooms: true, customer: ResponseModelFactory.getTestCustomerData(), userRoles: userRoles, authMethods: [], needsToChangeUserName: nil, needsToAcceptEULA: nil, title: nil, gender: nil, expireAt: nil, isEncryptionEnabled: true, lastLoginSuccessAt: nil, lastLoginFailAt: nil, userGroups: nil, userAttributes: nil, email: nil, lastLoginSuccessIp: nil, lastLoginFailIp: nil, homeRoomId: 2345)
        return responseModel
    }
    
    private static func getTestCustomerData() -> CustomerData {
        return CustomerData(_id: 1, name: "Customer", isProviderCustomer: false, spaceLimit: 10000, spaceUsed: 1000, accountsLimit: 100, accountsUsed: 98, customerEncryptionEnabled: true, cntFiles: 2000000, cntFolders: 321, cntRooms: 10000)
    }
    
    private static func getNode() -> Node {
        return Node(_id: 1337, type: .room, name: "name", parentId: nil, parentPath: nil, createdAt: nil, createdBy: nil, updatedAt: nil, updatedBy: nil, expireAt: nil, hash: nil, fileType: nil, mediaType: nil, size: nil, classification: nil, notes: nil, permissions: nil, isEncrypted: nil, cntChildren: nil, cntDeletedVersions: nil, hasRecycleBin: nil, recycleBinRetentionPeriod: nil, quota: nil, cntDownloadShares: nil, cntUploadShares: nil, isFavorite: nil, inheritPermissions: nil, encryptionInfo: nil, branchVersion: nil, mediaToken: nil, s3Key: nil, hasActivitiesLog: nil, children: nil, cntAdmins: nil, cntUsers: nil)
    }
    
    private static func getNodeList() -> NodeList {
        
        let range = ModelRange(offset: 0, limit: 0, total: 1)
        let nodes = [ResponseModelFactory.getNode()]
        
        return NodeList(range: range, items: nodes)
    }
    
    private static func getUserKeyPairContainer() -> UserKeyPairContainer {
        return UserKeyPairContainer(publicKey: "public", publicVersion: "test", privateKey: "private", privateVersion: "test")
    }
    
    private static func getUserAvatar() -> Avatar {
        return Avatar(avatarUri: "https://dracoon.team/avatar", avatarUuid: "testUUID", isCustomAvatar: true)
    }
    
    private static func getCreateFileUploadResponse() -> CreateFileUploadResponse {
        return CreateFileUploadResponse(uploadId: "uploadId", token: "uploadToken", uploadUrl: nil)
    }
    
    private static func getDownloadTokenGenerateResponse() -> DownloadTokenGenerateResponse {
        return DownloadTokenGenerateResponse(downloadUrl: nil, token: "downloadToken")
    }
}
