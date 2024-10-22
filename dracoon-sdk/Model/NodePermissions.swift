//
// NodePermissions.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct NodePermissions: Codable, Sendable {

    /** User / Group may grant all of the above permissions to other users and groups independently, may update room metadata and create / update / delete subordinary rooms, has all permissions. */
    public var manage: Bool
    /** User / Group may see all rooms, files and folders in the room and download everything, copy files from this room. */
    public var read: Bool
    /** User / Group may upload files, create folders and copy / move files to this room, overwriting is not possible. */
    public var create: Bool
    /** User / Group may update meta data of nodes: rename files and folders, change classification, etc. */
    public var change: Bool
    /** User / Group may overwrite and remove files / folders, move files from this room. */
    public var delete: Bool
    /** User / Group may create Download Shares for files and containers view all previously created Download Shares in this room. */
    public var manageDownloadShare: Bool
    /** User / Group may create Upload Shares for containers, view all previously created Upload Shares in this room. */
    public var manageUploadShare: Bool
    /** User / Group may look up files / folders in the Recycle Bin. */
    public var readRecycleBin: Bool
    /** User / Group may restore files / folders from Recycle Bin - room permissions required. */
    public var restoreRecycleBin: Bool
    /** User / Group may permanently remove files / folders from the Recycle Bin. */
    public var deleteRecycleBin: Bool



}

