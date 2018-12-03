//
// UpdateActiveDirectoryConfigRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct UpdateActiveDirectoryConfigRequest: Codable {

    /** Alias name */
    public var alias: String?
    /** IPv4 or IPv6 address or host name */
    public var serverIp: String?
    /** Port */
    public var serverPort: Int?
    /** Distinguished Name (DN) of Active Directory administrative account */
    public var serverAdminName: String?
    /** Password of Active Directory administrative account */
    public var serverAdminPassword: String?
    /** Search scope of Active Directory; only users below this node can log on. */
    public var ldapUsersDomain: String?
    /** Name of Active Directory attribute that is used as login name. */
    public var userFilter: String?
    /** Determines if an DRACOON account is automatically created for a new user who successfully logs on with his / her AD account. */
    public var userImport: Bool?
    /** If &#x60;userImport&#x60; is set to true, the user must be member of this Active Directory group to receive a newly created DRACOON account. */
    public var adExportGroup: String?
    /** User group that is assigned to users who are created by automatic import. */
    public var sdsImportGroup: Int64?
    /** Determines whether a room is created for each user that is created by automatic import (like a home folder). Room&#39;s name will equal the user&#39;s login name. (default: false) */
    public var createHomeFolder: Bool?
    /** ID of the room in which the individual rooms for users will be created. cf. &#x60;createHomeFolder&#x60; */
    public var homeFolderParent: Int64?
    /** Determines whether LDAPS should be used instead of plain LDAP. */
    public var useLdaps: Bool?
    /** SSL finger print of Active Directory server. Mandatory for LDAPS connections. Format: &#x60;Algorithm/Fingerprint&#x60; */
    public var sslFingerPrint: String?



}

