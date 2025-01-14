//
// EnableCustomerEncryptionRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct EnableCustomerEncryptionRequest: Codable, Sendable {

    /** Set &#x60;true&#x60; to enable encryption for this customer */
    public var enableCustomerEncryption: Bool
    /** System emergency password */
    public var dataSpaceRescueKey: UserKeyPairContainer



}

