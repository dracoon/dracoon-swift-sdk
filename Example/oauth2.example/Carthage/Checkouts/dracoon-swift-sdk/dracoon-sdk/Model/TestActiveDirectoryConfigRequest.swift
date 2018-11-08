//
// TestActiveDirectoryConfigRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct TestActiveDirectoryConfigRequest: Codable {

    /** IPv4 or IPv6 address or host name */
    public var serverIp: String
    /** Port */
    public var serverPort: Int
    /** Distinguished Name (DN) of Active Directory administrative account */
    public var serverAdminName: String
    /** Password of Active Directory administrative account */
    public var serverAdminPassword: String
    /** Search scope of Active Directory; only users below this node can log on. */
    public var ldapUsersDomain: String
    /** Determines whether LDAPS should be used instead of plain LDAP. */
    public var useLdaps: Bool
    /** SSL finger print of Active Directory server. Mandatory for LDAPS connections. Format: &#x60;Algorithm/Fingerprint&#x60; */
    public var sslFingerPrint: String?



}

