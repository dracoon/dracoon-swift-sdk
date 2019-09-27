//
//  RequestBuilders.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

extension CreateRoomRequest {
    public init(name: String, _ customize: ((inout CreateRoomRequest) -> Void)? = nil) {
        self.init(name: name,
                  parentId: nil,
                  hasRecycleBin: nil,
                  recycleBinRetentionPeriod: nil,
                  quota: nil,
                  inheritPermissions: nil,
                  adminIds: nil,
                  adminGroupIds: nil,
                  newGroupMemberAcceptance: nil,
                  notes: nil,
                  hasActivitiesLog: nil,
                  classification: nil)
        customize?(&self)
    }
}

extension CreateShareUploadChannelRequest {
    public init(name: String, _ customize: ((inout CreateShareUploadChannelRequest) -> Void)? = nil) {
        self.init(name: name,
                  size: nil,
                  password: nil)
        customize?(&self)
    }
    
}

extension CreateFileUploadRequest {
    public init(parentId: Int64,name: String, _ customize: ((inout CreateFileUploadRequest) -> Void)? = nil) {
        self.init(parentId: parentId,
                  name: name,
                  classification: nil,
                  size: nil,
                  expiration: nil,
                  notes: nil,
                  directS3Upload: nil)
        customize?(&self)
    }
}

extension CreateDownloadShareRequest {
    public init(nodeId:Int64, _ customize: ((inout CreateDownloadShareRequest) -> Void)? = nil) {
        self.init(nodeId: nodeId,
                  name: nil,
                  password: nil,
                  expiration: nil,
                  notes: nil,
                  showCreatorName: nil,
                  showCreatorUsername: nil,
                  notifyCreator: nil,
                  maxDownloads: nil,
                  sendMail: nil,
                  mailRecipients: nil,
                  mailSubject: nil,
                  mailBody: nil,
                  keyPair: nil,
                  fileKey: nil,
                  sendSms: nil,
                  smsRecipients: nil)
        customize?(&self)
    }
    
}

extension CreateUploadShareRequest {
    public init(targetId:Int64, _ customize: ((inout CreateUploadShareRequest) -> Void)? = nil) {
        self.init(targetId: targetId,
                  name: nil,
                  password: nil,
                  expiration: nil,
                  filesExpiryPeriod: nil,
                  notes: nil,
                  notifyCreator: nil,
                  sendMail: nil,
                  mailRecipients: nil,
                  mailSubject: nil,
                  mailBody: nil,
                  sendSms: nil,
                  smsRecipients: nil,
                  showUploadedFiles: nil,
                  maxSlots: nil,
                  maxSize: nil)
        customize?(&self)
    }
}
