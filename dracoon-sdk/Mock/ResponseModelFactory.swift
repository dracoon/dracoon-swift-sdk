//
//  ResponseModelFactory.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 25.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import crypto_sdk

public class ResponseModelFactory {
    
    public init() {}
    
    public func getTestResponseModel<E: Encodable>(_ type: E.Type) -> E? {
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
        } else if type == EncryptedFileKey.self {
            return self.getFileKey() as? E
        } else if type == MissingKeysResponse.self {
            return self.getMissingKeysResponse() as? E
        } else if type == PresignedUrlList.self {
            return self.getPresignedUrlList() as? E
        } else if type == S3FileUploadStatus.self {
            return self.getS3FileUploadStatus() as? E
        } else if type == AttributesResponse.self {
            return self.getAttributesResponse() as? E
        } else if type == ProfileAttributes.self {
            return self.getProfileAttributes() as? E
        } else if type == PasswordPoliciesConfig.self {
            return self.getPasswordPoliciesConfig() as? E
        } else if type == AlgorithmVersionInfoList.self {
            return self.getAlgorithmVersionInfoList() as? E
        } else if type == Comment.self {
            return self.getComment() as? E
        } else if type == CommentList.self {
            return self.getCommentList() as? E
        } else if type == ClassificationPoliciesConfig.self {
            return self.getClassificationPoliciesConfig() as? E
        }
        return nil
    }
    
    private func getTestUserAccount() -> UserAccount {
        let userRoles = RoleList(items: [])
        let userAuthData = UserAuthData(method: .openid, login: "testUser", password: nil, mustChangePassword: false, adConfigId: nil, oidConfigId: 1337)
        
        let responseModel = UserAccount(_id: 42, userName: "test", firstName: "test", lastName: "test", isLocked: false, hasManageableRooms: false, userRoles: userRoles, language: nil, authData: userAuthData, mustSetEmail: false, needsToAcceptEULA: false, expireAt: nil, isEncryptionEnabled: true, lastLoginSuccessAt: nil, lastLoginFailAt: nil, email: nil, phone: nil, homeRoomId: nil, userGroups: nil, userAttributes: nil, title: nil, login: "testUser", authMethods: nil, needsToChangePassword: nil, needsToChangeUserName: nil, gender: nil)
        return responseModel
    }
    
    private func getTestCustomerData() -> CustomerData {
        return CustomerData(_id: 1, name: "Customer", isProviderCustomer: false, spaceLimit: 10000, spaceUsed: 1000, accountsLimit: 100, accountsUsed: 98, customerEncryptionEnabled: true)
    }
    
    private func getNode() -> Node {
        let userInfo = UserInfo(_id: 1338)
        
        return Node(_id: 1337, type: .room, name: "name", timestampCreation: Date(), timestampModification: Date(), parentId: 42, parentPath: "/root", createdAt: Date(), createdBy: userInfo, updatedAt: Date(), updatedBy: userInfo, expireAt: nil, hash: nil, fileType: nil, mediaType: nil, size: nil, classification: nil, notes: nil, permissions: nil, inheritPermissions: false, isEncrypted: false, encryptionInfo: nil, cntDeletedVersions: 0, cntComments: 0, cntDownloadShares: 0, cntUploadShares: 0, recycleBinRetentionPeriod: 0, hasActivitiesLog: false, quota: nil, isFavorite: true, branchVersion: nil, mediaToken: nil, isBrowsable: true, cntRooms: 0, cntFolders: 1, cntFiles: 5, authParentId: nil)
    }
    
    private func getNodeList() -> NodeList {
        
        let range = ModelRange(offset: 0, limit: 1, total: 1)
        let nodes = [self.getNode()]
        
        return NodeList(range: range, items: nodes)
    }
    
    private func getUserKeyPairContainer() -> UserKeyPairContainer {
        return UserKeyPairContainer(publicKey: "public", publicVersion: .RSA2048, privateKey: "private", privateVersion: .RSA2048)
    }
    
    private func getUserAvatar() -> Avatar {
        return Avatar(avatarUri: "https://dracoon.team/avatar", avatarUuid: "testUUID", isCustomAvatar: true)
    }
    
    private func getCreateFileUploadResponse() -> CreateFileUploadResponse {
        return CreateFileUploadResponse(uploadUrl: "https://dracoon.team/api/v4/uploads/uploadToken", uploadId: "uploadId")
    }
    
    private func getDownloadTokenGenerateResponse() -> DownloadTokenGenerateResponse {
        return DownloadTokenGenerateResponse(downloadUrl: "https://dracoon.team/api/v4/downloads/downloadToken")
    }
    
    private func getSoftwareVersionData() -> SoftwareVersionData {
        return SoftwareVersionData(restApiVersion: "4.13.0", sdsServerVersion: "4.13.0", buildDate: Date(), scmRevisionNumber: nil)
    }
    
    private func getSdsServerTime() -> SdsServerTime {
        return SdsServerTime(time: Date())
    }
    
    private func getSystemDefaults() -> SystemDefaults {
        return SystemDefaults(languageDefault: "en", downloadShareDefaultExpirationPeriod: nil, uploadShareDefaultExpirationPeriod: nil, fileDefaultExpirationPeriod: nil)
    }
    
    private func getGeneralSettings() -> GeneralSettings {
        return GeneralSettings(sharePasswordSmsEnabled: false, cryptoEnabled: true, emailNotificationButtonEnabled: true, eulaEnabled: true, weakPasswordEnabled: false, useS3Storage: true, mediaServerEnabled: true)
    }
    
    private func getInfrastructureProperties() -> InfrastructureProperties {
        return InfrastructureProperties(smsConfigEnabled: false, mediaServerConfigEnabled: true, s3DefaultRegion: nil, s3EnforceDirectUpload: false)
    }
    
    private func getDownloadShare() -> DownloadShare {
        let userInfo = UserInfo(_id: 32)
        return DownloadShare(_id: 1337, nodeId: 42, accessKey: "accessKey", cntDownloads: 10, createdAt: Date(), createdBy: userInfo, name: nil, notes: nil, showCreatorName: false, showCreatorUsername: false, isProtected: false, expireAt: nil, maxDownloads: nil, nodePath: nil, dataUrl: nil, isEncrypted: false, internalNotes: nil, notifyCreator: false)
    }
    
    private func getDownloadShareList() -> DownloadShareList {
        let range = ModelRange(offset: 0, limit: 1, total: 1)
        return DownloadShareList(range: range, items: [self.getDownloadShare()])
    }
    
    private func getUploadShare() -> UploadShare {
        let userInfo = UserInfo(_id: 32)
        return UploadShare(_id: 1337, targetId: 42, name: "name", isProtected: false, accessKey: "accessKey", createdAt: Date(), createdBy: userInfo, targetPath: nil, expireAt: nil, isEncrypted: true, notes: nil, filesExpiryPeriod: nil, cntFiles: nil, cntUploads: nil, showUploadedFiles: false, dataUrl: nil, maxSlots: nil, maxSize: nil, showCreatorName: false, showCreatorUsername: false, internalNotes: nil, notifyCreator: nil)
    }
    
    private func getUploadShareList() -> UploadShareList {
        let range = ModelRange(offset: 0, limit: 1, total: 1)
        return UploadShareList(range: range, items: [self.getUploadShare()])
    }
    
    private func getCustomerSettingsResponse() -> CustomerSettingsResponse {
        return CustomerSettingsResponse(homeRoomParentName: "home", homeRoomQuota: 5000000000, homeRoomsActive: true, homeRoomParentId: 1337)
    }
    
    private func getFileKey() -> EncryptedFileKey {
        return EncryptedFileKey(key: "encryptedFileKey", version: .RSA2048_AES256GCM, iv: "iv", tag: "tag")
    }
    
    private func getMissingKeysResponse() -> MissingKeysResponse {
        let range = ModelRange(offset: 0, limit: 1, total: 1)
        let userFileMapping = UserIdFileIdItem(userId: 42, fileId: 1337)
        let userKeyMapping = UserUserPublicKey(_id: 42, publicKeyContainer: UserPublicKey(publicKey: "publicKey", version: .RSA2048))
        let fileKey = FileFileKeys(_id: 1337, fileKeyContainer: EncryptedFileKey(key: "encryptedKey", version: .RSA2048_AES256GCM, iv: "iv", tag: "tag"))
        return MissingKeysResponse(range: range, items: [userFileMapping], users: [userKeyMapping], files: [fileKey])
    }
    
    private func getPresignedUrlList() -> PresignedUrlList {
        let presignedUrl1 = PresignedUrl(url: "https://dracoon.team/1", partNumber: 1)
        let presignedUrl2 = PresignedUrl(url: "https://dracoon.team/2", partNumber: 2)
        let presignedUrl3 = PresignedUrl(url: "https://dracoon.team/3", partNumber: 3)
        return PresignedUrlList(urls: [presignedUrl1, presignedUrl2, presignedUrl3])
    }
    
    private func getS3FileUploadStatus() -> S3FileUploadStatus {
        return S3FileUploadStatus(status: S3FileUploadStatus.S3UploadStatus.done.rawValue, node: self.getNode(), errorDetails: nil)
    }
    
    private func getAttributesResponse() -> AttributesResponse {
        let keyValueEntry1 = KeyValueEntry(key: "testKey1", value: "testValue1")
        let keyValueEntry2 = KeyValueEntry(key: "testKey2", value: "testValue2")
        return AttributesResponse(range: ModelRange(offset: 0, limit: 2, total: 2), items: [keyValueEntry1, keyValueEntry2])
    }
    
    private func getProfileAttributes() -> ProfileAttributes {
        let keyValueEntry1 = KeyValueEntry(key: "testKey1", value: "testValue1")
        let keyValueEntry2 = KeyValueEntry(key: "testKey2", value: "testValue2")
        return ProfileAttributes(items: [keyValueEntry1, keyValueEntry2])
    }
    
    private func getClassificationPoliciesConfig() -> ClassificationPoliciesConfig {
        let shareClassifications = ShareClassificationPolicies(classificationRequiresSharePassword: 0)
        return ClassificationPoliciesConfig(shareClassificationPolicies: shareClassifications)
    }
    
    private func getPasswordPoliciesConfig() -> PasswordPoliciesConfig {
        let characterRules = CharacterRules(mustContainCharacters: [.lowercase, .uppercase, .numeric, .special], numberOfCharacteristicsToEnforce: 2)
        let loginPasswordPolicies = LoginPasswordPolicies(characterRules: characterRules, minLength: 8, rejectDictionaryWords: false, rejectUserInfo: true, rejectKeyboardPatterns: false, numberOfArchivedPasswords: nil, passwordExpiration: nil, userLockout: nil, updatedAt: nil, updatedBy: nil)
        let sharePasswordPolicies = SharesPasswordPolicies(characterRules: characterRules, minLength: 8, rejectDictionaryWords: false, rejectUserInfo: true, rejectKeyboardPatterns: false, updatedAt: nil, updatedBy: nil)
        let encryptionPasswordPolicies = EncryptionPasswordPolicies(characterRules: characterRules, minLength: 8, rejectUserInfo: true, rejectKeyboardPatterns: false, updatedAt: nil, updatedBy: nil)
        return PasswordPoliciesConfig(loginPasswordPolicies: loginPasswordPolicies, sharesPasswordPolicies: sharePasswordPolicies, encryptionPasswordPolicies: encryptionPasswordPolicies)
    }
    
    private func getAlgorithmVersionInfoList() -> AlgorithmVersionInfoList {
        let fileKeyAlgos = [FileKeyAlgorithm(version: .RSA2048_AES256GCM, description: "", status: .REQUIRED)]
        let keyPairAlgos = [KeyPairAlgorithm(version: .RSA2048, description: "", status: .REQUIRED)]
        return AlgorithmVersionInfoList(fileKeyAlgorithms: fileKeyAlgos, keyPairAlgorithms: keyPairAlgos)
    }
    
    private func getComment() -> Comment {
        return Comment(id: 42, text: "test", createdAt: Date(), createdBy: nil, updatedAt: nil, updatedBy: nil, isChanged: false, isDeleted: false)
    }
    
    private func getCommentList() -> CommentList {
        let range = ModelRange(offset: 0, limit: 1, total: 1)
        let items = [self.getComment()]
        return CommentList(range: range, items: items)
    }
}
