//
//  DracoonError.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

public enum DracoonError: Error {
    case api(error: DracoonSDKErrorModel)
    case encode(error: Error)
    case decode(error: Error, statusCode: Int?)
    case generic(error: Error?)
    
    case encrypted_share_no_password_provided
    case hash_check_failed
    
    case read_data_failure(at: URL)
    case write_data_failure(at: URL)
    case node_path_invalid(path: String)
    case url_invalid(url: URL)
    case path_range_invalid
    case node_not_found(path: String)
    case file_does_not_exist(at: URL)
    case invalidParameter(description: String)
    
    case no_encryption_password
    case filekey_not_found
    case filekey_encryption_failure(description: String)
    case filekey_decryption_failure(description: String)
    case encryption_cipher_failure
    case file_decryption_error(nodeId: Int64)
    case keypair_failure(description: String)
    case keypair_decryption_failure
    case keypair_does_not_exist
    
    case download_not_found
    case upload_not_found
    case upload_failed(statusCode: Int)
    case exceeds_maximum_s3_upload_size(fileSize: Int64, maximumSize: Int64)
    
    /* reason is one of
     NSURLErrorCancelledReasonUserForceQuitApplication
     NSURLErrorCancelledReasonBackgroundUpdatesDisabled
     NSURLErrorCancelledReasonInsufficientSystemResources */
    case background_download_cancelled(reason: Int, userInfo: [String: Any])
    
    case authorization_code_flow_in_progress(clientId: String, clientSecret: String, authorizationCode: String)
    case authorization_token_expired
    case oauth_error(errorModel: OAuthErrorModel)
    case oauth_error_unknown(statusCode: Int?, description: String?)
    
    case connection_timeout
    case offline
    case too_many_requests_sent(waitingTimeSeconds: Int)
}
