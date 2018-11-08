//
//  DracoonConstants.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public struct DracoonConstants {
    
    public static let API_PATH = "/api/v4"
    public static let API_MIN_VERSION = "4.0.0"
    
    public static let AUTHORIZATION_HEADER = "Authorization"
    public static let AUTHORIZATION_TYPE = "Bearer"
    public static let AUTHORIZATION_REFRESH_INTERVAL = 60 * 60
    
    public static let CHUNK_UPLOAD_MAX_RETRIES = 3
    
    public static let MISSING_FILEKEYS_MAX_COUNT = 5 as Int64
    
    public static let DECRYPTION_BUFFER_SIZE = 200 * 1024
    public static let UPLOAD_CHUNK_SIZE = 200 * 1024
}

