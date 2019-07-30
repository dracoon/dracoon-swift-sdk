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
        } else if type == SoftwareVersionData.self {
            return self.getSoftwareVersionData() as? E
        } else if type == SdsServerTime.self {
            return self.getSdsServerTime() as? E
        } else if type == SystemDefaults.self {
            return self.getSystemDefaults() as? E
        } else if type == GeneralSettings.self {
            return self.getGeneralSettings() as? E
        } else if type == InfrastructureProperties.self {
            return self.getInfrastructureProperties() as? E
        } else if type == DownloadShare.self {
            return self.getDownloadShare() as? E
        } else if type == DownloadShareList.self {
            return self.getDownloadShareList() as? E
        } else if type == UploadShare.self {
            return self.getUploadShare() as? E
        } else if type == UploadShareList.self {
            return self.getUploadShareList() as? E
        } else if type == CustomerSettingsResponse.self {
            return self.getCustomerSettingsResponse() as? E
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
    
    private static func getSoftwareVersionData() -> SoftwareVersionData {
        return SoftwareVersionData(restApiVersion: "4.13.0", sdsServerVersion: "4.13.0", buildDate: Date(), scmRevisionNumber: nil)
    }
    
    private static func getSdsServerTime() -> SdsServerTime {
        return SdsServerTime(time: Date())
    }
    
    private static func getSystemDefaults() -> SystemDefaults {
        return SystemDefaults(languageDefault: "en", downloadShareDefaultExpirationPeriod: nil, uploadShareDefaultExpirationPeriod: nil, fileDefaultExpirationPeriod: nil)
    }
    
    private static func getGeneralSettings() -> GeneralSettings {
        return GeneralSettings(sharePasswordSmsEnabled: false, cryptoEnabled: true, emailNotificationButtonEnabled: true, eulaEnabled: true, mediaServerEnabled: true, weakPasswordEnabled: false, useS3Storage: true)
    }
    
    private static func getInfrastructureProperties() -> InfrastructureProperties {
        return InfrastructureProperties(smsConfigEnabled: false, mediaServerConfigEnabled: true, s3DefaultRegion: nil)
    }
    
    private static func getDownloadShare() -> DownloadShare {
        let userInfo = UserInfo(_id: 32, displayName: "displayName")
        return DownloadShare(_id: 1337, nodeId: 42, accessKey: "accessKey", notifyCreator: false, cntDownloads: 10, createdAt: Date(), createdBy: userInfo, name: nil, notes: nil, showCreatorName: false, showCreatorUsername: false, isProtected: nil, expireAt: nil, maxDownloads: nil, recipients: nil, smsRecipients: nil, nodePath: nil, dataUrl: nil, isEncrypted: nil)
    }
    
    private static func getDownloadShareList() -> DownloadShareList {
        let range = ModelRange(offset: 0, limit: 0, total: 1)
        return DownloadShareList(range: range, items: [self.getDownloadShare()])
    }
    
    private static func getUploadShare() -> UploadShare {
        let userInfo = UserInfo(_id: 32, displayName: "displayName")
        return UploadShare(_id: 1337, targetId: 42, name: "name", isProtected: false, accessKey: "accessKey", notifyCreator: false, createdAt: Date(), createdBy: userInfo, targetPath: nil, expireAt: nil, isEncrypted: false, notes: nil, filesExpiryPeriod: nil, recipients: nil, smsRecipients: nil, cntFiles: nil, cntUploads: nil, showUploadedFiles: false, dataUrl: nil, maxSlots: nil, maxSize: nil)
    }
    
    private static func getUploadShareList() -> UploadShareList {
        let range = ModelRange(offset: 0, limit: 0, total: 1)
        return UploadShareList(range: range, items: [self.getUploadShare()])
    }
    
    private static func getCustomerSettingsResponse() -> CustomerSettingsResponse {
        return CustomerSettingsResponse(homeRoomParentName: "home", homeRoomQuota: 5000000000, homeRoomsActive: true, homeRoomParentId: 1337)
    }
}
