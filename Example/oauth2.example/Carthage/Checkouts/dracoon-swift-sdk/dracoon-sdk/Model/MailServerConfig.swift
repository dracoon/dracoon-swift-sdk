//
// MailServerConfig.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct MailServerConfig: Codable {

    /** Email server host */
    public var host: String?
    /** Email server port */
    public var port: Int?
    /** User name for email server */
    public var username: String?
    /** Is password defined for email server? */
    public var passwordDefined: Bool?
    /** Set &#39;true&#39; if the email server requires authentication. */
    public var authenticationEnabled: Bool?
    /** Email server requires SSL connection? Requires &#39;starttlsEnabled&#39; to be &#39;false&#39; */
    public var sslEnabled: Bool?
    /** Email server requires StartTLS connection? Requires &#39;sslEnabled&#39; to be &#39;false&#39; */
    public var starttlsEnabled: Bool?



}

