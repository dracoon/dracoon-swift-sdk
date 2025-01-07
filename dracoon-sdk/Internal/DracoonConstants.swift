//
//  DracoonConstants.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public struct DracoonConstants {
    
    public static let API_PATH = "/api/v4"
    public static let API_MIN_VERSION = "4.26.0"
    
    public static let AUTHORIZATION_HEADER = "Authorization"
    public static let AUTHORIZATION_TYPE = "Bearer"
    public static let AUTHORIZATION_REFRESH_INTERVAL = 60 * 60
    
    public static let S3_CHUNK_SIZE = 1024*1024*5
    public static let S3_UPLOAD_MAX_RETRIES = 3
    public static let S3_MAX_URL_FETCH_COUNT: Int32 = 10
    public static let S3_BACKGROUND_UPLOAD_MAX_SIZE: Int64 = 1024*1024*1024*5
    
    public static let MISSING_FILEKEYS_MAX_COUNT = 5 as Int64
    
    public static let ENCRYPTION_BUFFER_SIZE = 200 * 1024
    public static let DECRYPTION_BUFFER_SIZE = 200 * 1024
    
    public static let DEFAULT_429_WAITING_TIME_SECONDS = 1
    public static let MAX_429_WAITING_TRESHOLD_SECONDS = 20
}

