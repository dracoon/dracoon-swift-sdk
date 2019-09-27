//
//  DracoonApiCode.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 07.03.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

public enum DracoonApiCode : Int64, CustomStringConvertible, Codable {
    
    case UNKNOWN = 0
    
    // MARK: Authentication errors
    
    case AUTH_UNKNOWN_ERROR = 1000
    case AUTH_OAUTH_CLIENT_UNKNOWN = 1100
    case AUTH_OAUTH_CLIENT_UNAUTHORIZED = 1101
    case AUTH_OAUTH_GRANT_TYPE_NOT_ALLOWED = 1102
    case AUTH_OAUTH_AUTHORIZATION_REQUEST_INVALID = 1103
    case AUTH_OAUTH_AUTHORIZATION_SCOPE_INVALID = 1104
    case AUTH_OAUTH_AUTHORIZATION_ACCESS_DENIED = 1105
    case AUTH_OAUTH_TOKEN_REQUEST_INVALID = 1106
    case AUTH_OAUTH_TOKEN_CODE_INVALID = 1107
    case AUTH_OAUTH_REFRESH_REQUEST_INVALID = 1108
    case AUTH_OAUTH_REFRESH_TOKEN_INVALID = 1109
    case AUTH_OAUTH_CLIENT_NO_PERMISSION = 1150
    case AUTH_UNAUTHORIZED = 1200
    case AUTH_USER_TEMPORARY_LOCKED = 1300
    case AUTH_USER_LOCKED = 1301
    case AUTH_USER_EXPIRED = 1302
    
    //  MARK: Precondition errors
    
    case PRECONDITION_UNKNOWN_ERROR = 2000
    case PRECONDITION_MUST_ACCEPT_EULA = 2101
    case PRECONDITION_MUST_CHANGE_USER_NAME = 2102
    case PRECONDITION_MUST_CHANGE_PASSWORD = 2103
    
    // MARK: Validation errors
    
    case VALIDATION_UNKNOWN_ERROR = 3000
    case VALIDATION_FIELD_CANNOT_BE_EMPTY = 3001
    case VALIDATION_FIELD_NOT_ZERO_POSITIVE = 3002
    case VALIDATION_FIELD_NOT_POSITIVE = 3003
    case VALIDATION_FIELD_MAX_LENGTH_EXCEEDED = 3004
    case VALIDATION_FIELD_NOT_BETWEEN_0_10 = 3005
    case VALIDATION_FIELD_NOT_BETWEEN_0_9999 = 3006
    case VALIDATION_FIELD_NOT_BETWEEN_1_9999 = 3007
    case VALIDATION_INVALID_OFFSET_OR_LIMIT = 3008
    
    // Nodes
    
    case VALIDATION_FILE_CANNOT_BE_TARGET = 3100
    case VALIDATION_BAD_FILE_NAME = 3101
    case VALIDATION_EXPIRATION_DATE_IN_PAST = 3102
    case VALIDATION_EXPIRATION_DATE_TOO_LATE = 3103
    case VALIDATION_NODE_ALREADY_EXISTS = 3104
    case VALIDATION_ROOM_ALREADY_EXISTS = 3105
    case VALIDATION_FOLDER_ALREADY_EXISTS = 3106
    case VALIDATION_FILE_ALREADY_EXISTS = 3107
    case VALIDATION_NODES_NOT_IN_SAME_PARENT = 3108
    case VALIDATION_CANNOT_COPY_NODE_TO_OWN_PLACE_WITHOUT_RENAME = 3109
    case VALIDATION_CANNOT_MOVE_NODE_TO_OWN_PLACE = 3110
    case VALIDATION_ROOM_FOLDER_CAN_NOT_BE_OVERWRITTEN = 3111
    case VALIDATION_CANNOT_COPY_TO_CHILD = 3112
    case VALIDATION_CANNOT_MOVE_TO_CHILD = 3113
    case VALIDATION_CANNOT_COPY_ROOM = 3114
    case VALIDATION_CANNOT_MOVE_ROOM = 3115
    case VALIDATION_PATH_TOO_LONG = 3116
    case VALIDATION_NODE_NO_FAVORITE = 3117
    case VALIDATION_ROOM_NOT_ENCRYPTED = 3118
    case VALIDATION_SOURCE_ROOM_ENCRYPTED = 3119
    case VALIDATION_TARGET_ROOM_ENCRYPTED = 3120
    case VALIDATION_ROOM_ENCRYPTED = 3121
    case VALIDATION_ROOM_CANNOT_BE_UNENCRYPTED_WITH_FILES = 3122
    case VALIDATION_ROOM_CANNOT_BE_ENCRYPTED_WITH_FILES = 3123
    case VALIDATION_ROOM_ALREADY_HAS_RESCUE_KEY = 3124
    case VALIDATION_ROOM_CANNOT_SET_ENCRYPTED_WITH_RECYCLEBIN = 3125
    case VALIDATION_ROOM_CANNOT_SET_UNENCRYPTED_WITH_RECYCLEBIN = 3126
    case VALIDATION_ENCRYPTED_FILE_CAN_ONLY_BE_RESTORED_IN_ORIGINAL_ROOM = 3127
    case VALIDATION_KEEPSHARELINKS_ONLY_WITH_OVERWRITE = 3128
    
    // Shares
    
    case VALIDATION_DL_SHARE_CANNOT_CREATE_ON_ENCRYPTED_ROOM_FOLDER = 3200
    case VALIDATION_UL_SHARE_NAME_ALREADY_EXISTS = 3201
    
    // Customer
    
    case VALIDATION_PLACEHOLDER_CUSTOMER = 3400
    
    // Users
    
    case VALIDATION_PLACEHOLDER_USERS = 3500
    case VALIDATION_USER_HAS_NO_KEY_PAIR = 3550
    case VALIDATION_USER_KEY_PAIR_INVALID = 3551
    case VALIDATION_USER_FILE_KEY_MISSING = 3552
    
    // Groups
    
    case VALIDATION_PLACEHOLDER_GROUPS = 3600
    
    // Other
    
    case VALIDATION_PASSWORD_NOT_SECURE = 3800
    case VALIDATION_INVALID_EMAIL_ADDRESS = 3801
    
    // MARK: Permission errors
    
    case PERMISSION_UNKNOWN_ERROR = 4000
    case PERMISSION_MANAGE_ERROR = 4100
    case PERMISSION_READ_ERROR = 4101
    case PERMISSION_CREATE_ERROR = 4102
    case PERMISSION_UPDATE_ERROR = 4103
    case PERMISSION_DELETE_ERROR = 4104
    case PERMISSION_MANAGE_DL_SHARES_ERROR = 4105
    case PERMISSION_MANAGE_UL_SHARES_ERROR = 4106
    case PERMISSION_READ_RECYCLE_BIN_ERROR = 4107
    case PERMISSION_RESTORE_RECYCLE_BIN_ERROR = 4108
    case PERMISSION_DELETE_RECYCLE_BIN_ERROR = 4109
    
    // MARK: Server errors
    
    case SERVER_UNKNOWN_ERROR = 5000
    case SERVER_MALICIOUS_FILE_DETECTED = 5090
    
    // Nodes
    
    case SERVER_NODE_NOT_FOUND = 5100
    case SERVER_ROOM_NOT_FOUND = 5101
    case SERVER_FOLDER_NOT_FOUND = 5102
    case SERVER_FILE_NOT_FOUND = 5103
    case SERVER_SOURCE_NODE_NOT_FOUND = 5104
    case SERVER_TARGET_NODE_NOT_FOUND = 5105
    case SERVER_TARGET_ROOM_NOT_FOUND = 5106
    case SERVER_INSUFFICIENT_STORAGE = 5107
    case SERVER_INSUFFICIENT_CUSTOMER_QUOTA = 5108
    case SERVER_INSUFFICIENT_ROOM_QUOTA = 5109
    case SERVER_INSUFFICIENT_UL_SHARE_QUOTA = 5110
    case SERVER_RESTORE_VERSION_NOT_FOUND = 5111
    case SERVER_UPLOAD_NOT_FOUND = 5112
    
    // Shares
    
    case SERVER_DL_SHARE_NOT_FOUND = 5200
    case SERVER_UL_SHARE_NOT_FOUND = 5201
    
    // Customer
    
    case SERVER_PLACEHOLDER_CUSTOMER = 5400
    
    // Users
    
    case SERVER_USER_NOT_FOUND = 5500
    case SERVER_USER_KEY_PAIR_NOT_FOUND = 5550
    case SERVER_USER_KEY_PAIR_ALREADY_SET = 5551
    case SERVER_USER_FILE_KEY_NOT_FOUND = 5552
    case SERVER_AVATAR_NOT_FOUND = 5553
    
    // Groups
    
    case SERVER_PLACEHOLDER_GROUPS = 5600
    
    // Config
    
    case SERVER_SMS_IS_DISABLED = 5800
    case SERVER_SMS_COULD_NOT_BE_SENT = 5801
    
    public var description: String {
        switch self {
        case .UNKNOWN:
            return "An unknown error occurred."
        case .AUTH_UNKNOWN_ERROR:
            return "An authentication error occurred."
        case .AUTH_OAUTH_CLIENT_UNKNOWN:
            return "OAuth client is unknown."
        case .AUTH_OAUTH_CLIENT_UNAUTHORIZED:
            return "OAuth client is unauthorized."
        case .AUTH_OAUTH_GRANT_TYPE_NOT_ALLOWED:
            return "OAuth grant type is not allowed."
        case .AUTH_OAUTH_AUTHORIZATION_REQUEST_INVALID:
            return "OAuth authorization request is invalid."
        case .AUTH_OAUTH_AUTHORIZATION_SCOPE_INVALID:
            return "OAuth scope is invalid."
        case .AUTH_OAUTH_AUTHORIZATION_ACCESS_DENIED:
            return "OAuth access was denied."
        case .AUTH_OAUTH_TOKEN_REQUEST_INVALID:
            return "OAuth token request is invalid."
        case .AUTH_OAUTH_TOKEN_CODE_INVALID:
            return "OAuth authorization code is invalid."
        case .AUTH_OAUTH_REFRESH_REQUEST_INVALID:
            return "OAuth token refresh request is invalid."
        case .AUTH_OAUTH_REFRESH_TOKEN_INVALID:
            return "OAuth refresh token is invalid."
        case .AUTH_OAUTH_CLIENT_NO_PERMISSION:
            return "OAuth client has no permission to execute the action."
        case .AUTH_UNAUTHORIZED:
            return "Unauthorized."
        case .AUTH_USER_TEMPORARY_LOCKED:
            return "User is temporary locked."
        case .AUTH_USER_LOCKED:
            return "User is locked."
        case .AUTH_USER_EXPIRED:
            return "User is expired."
            
        case .PRECONDITION_UNKNOWN_ERROR:
            return "A precondition is not fulfilled."
        case .PRECONDITION_MUST_ACCEPT_EULA:
            return "User must accept EULA."
        case .PRECONDITION_MUST_CHANGE_USER_NAME:
            return "User must change his user name."
        case .PRECONDITION_MUST_CHANGE_PASSWORD:
            return "User must change his password."
            
        case .VALIDATION_UNKNOWN_ERROR:
            return "The server request was invalid."
        case .VALIDATION_FIELD_CANNOT_BE_EMPTY:
            return "Mandatory fields cannnot be empty."
        case .VALIDATION_FIELD_NOT_ZERO_POSITIVE:
            return "Field value must be zero or positive."
        case .VALIDATION_FIELD_NOT_POSITIVE:
            return "Field value must be positive."
        case .VALIDATION_FIELD_MAX_LENGTH_EXCEEDED:
            return "Maximum allowed field length is exceeded."
        case .VALIDATION_FIELD_NOT_BETWEEN_0_10:
            return "Field value must be between 0 and 10."
        case .VALIDATION_FIELD_NOT_BETWEEN_0_9999:
            return "Field value must be between 0 and 9999."
        case .VALIDATION_FIELD_NOT_BETWEEN_1_9999:
            return "Field value must be between 1 and 9999."
        case .VALIDATION_INVALID_OFFSET_OR_LIMIT:
            return "Invalid offset or limit."
            
        case .VALIDATION_FILE_CANNOT_BE_TARGET:
            return "File cannot be target of a copy or move operation."
        case .VALIDATION_BAD_FILE_NAME:
            return "Bad file name."
        case .VALIDATION_EXPIRATION_DATE_IN_PAST:
            return "Expiration date is in the past."
        case .VALIDATION_EXPIRATION_DATE_TOO_LATE:
            return "The year is too far in the future. Max year is limited to 9999."
        case .VALIDATION_NODE_ALREADY_EXISTS:
            return "Node exists already."
        case .VALIDATION_ROOM_ALREADY_EXISTS:
            return "A room with the same name already exists."
        case .VALIDATION_FOLDER_ALREADY_EXISTS:
            return "A folder with the same name already exists."
        case .VALIDATION_FILE_ALREADY_EXISTS:
            return "A file with the same name already exists."
        case .VALIDATION_NODES_NOT_IN_SAME_PARENT:
            return "Folders/files must be in same parent."
        case .VALIDATION_CANNOT_COPY_NODE_TO_OWN_PLACE_WITHOUT_RENAME:
            return "Node cannot be copied to its own place without renaming."
        case .VALIDATION_CANNOT_MOVE_NODE_TO_OWN_PLACE:
            return "Node cannot be moved to its own place."
        case .VALIDATION_ROOM_FOLDER_CAN_NOT_BE_OVERWRITTEN:
            return "A room or folder cannot be overwritten."
        case .VALIDATION_CANNOT_COPY_TO_CHILD:
            return "Node cannot be copied into its child node."
        case .VALIDATION_CANNOT_MOVE_TO_CHILD:
            return "Node cannot be moved into its child node."
        case .VALIDATION_CANNOT_COPY_ROOM:
            return "Rooms cannot be copied."
        case .VALIDATION_CANNOT_MOVE_ROOM:
            return "Rooms cannot be moved."
        case .VALIDATION_PATH_TOO_LONG:
            return "Path is too long."
        case .VALIDATION_NODE_NO_FAVORITE:
            return "Node is not marked as favorite."
        case .VALIDATION_ROOM_NOT_ENCRYPTED:
            return "Room is not encrypted."
        case .VALIDATION_SOURCE_ROOM_ENCRYPTED:
            return "Encrypted files cannot be copied or moved to an unencrypted room."
        case .VALIDATION_TARGET_ROOM_ENCRYPTED:
            return "Not encrypted files cannot be copied or moved to an encrypted room."
        case .VALIDATION_ROOM_ENCRYPTED:
            return "Room is encrypted."
        case .VALIDATION_ROOM_CANNOT_BE_UNENCRYPTED_WITH_FILES:
            return "Room with files cannot be unencrypted."
        case .VALIDATION_ROOM_CANNOT_BE_ENCRYPTED_WITH_FILES:
            return "Room with files cannot be encrypted."
        case .VALIDATION_ROOM_ALREADY_HAS_RESCUE_KEY:
            return "Only one room emergency password (rescue key) is allowed."
        case .VALIDATION_ROOM_CANNOT_SET_ENCRYPTED_WITH_RECYCLEBIN:
            return "Room with not empty recycle bin cannot be set encrypted."
        case .VALIDATION_ROOM_CANNOT_SET_UNENCRYPTED_WITH_RECYCLEBIN:
            return "Room with not empty recycle bin cannot be set unencrypted."
        case .VALIDATION_ENCRYPTED_FILE_CAN_ONLY_BE_RESTORED_IN_ORIGINAL_ROOM:
            return "Encrypted files cannot be restored inside another than its original room."
        case .VALIDATION_KEEPSHARELINKS_ONLY_WITH_OVERWRITE:
            return "Keep share links is only allowed with resolution strategy 'overwrite'."
            
        case .VALIDATION_DL_SHARE_CANNOT_CREATE_ON_ENCRYPTED_ROOM_FOLDER:
            return "A download share cannot be created on a encrypted room or folder."
        case .VALIDATION_UL_SHARE_NAME_ALREADY_EXISTS:
            return "Upload share name already exists."
            
        case .VALIDATION_PLACEHOLDER_CUSTOMER:
            return "Placeholder for customer validation errors"
            
        case .VALIDATION_PLACEHOLDER_USERS:
            return "Placeholder for users validation errors"
        case .VALIDATION_USER_HAS_NO_KEY_PAIR:
            return "User has no encryption key pair."
        case .VALIDATION_USER_KEY_PAIR_INVALID:
            return "Invalid encryption key pair."
        case .VALIDATION_USER_FILE_KEY_MISSING:
            return "File key has to be provided"
            
        case .VALIDATION_PLACEHOLDER_GROUPS:
            return "Placeholder for groups validation errors"
            
        case .VALIDATION_PASSWORD_NOT_SECURE:
            return "Password is not secure."
        case .VALIDATION_INVALID_EMAIL_ADDRESS:
            return "Invalid email address."
            
        case .PERMISSION_UNKNOWN_ERROR:
            return "User has no permissions to execute the action in this room."
        case .PERMISSION_MANAGE_ERROR:
            return "User has no permission to manage this room."
        case .PERMISSION_READ_ERROR:
            return "User has no permission to read nodes."
        case .PERMISSION_CREATE_ERROR:
            return "User has no permission to create nodes."
        case .PERMISSION_UPDATE_ERROR:
            return "User has no permission to change nodes."
        case .PERMISSION_DELETE_ERROR:
            return "User has no permission to delete nodes."
        case .PERMISSION_MANAGE_DL_SHARES_ERROR:
            return "User has no permission to manage download shares in this room."
        case .PERMISSION_MANAGE_UL_SHARES_ERROR:
            return "User has no permission to manage upload shares in this room."
        case .PERMISSION_READ_RECYCLE_BIN_ERROR:
            return "User has no permission to read recycle bin in this room."
        case .PERMISSION_RESTORE_RECYCLE_BIN_ERROR:
            return "User has no permission to restore recycle bin items in this room."
        case .PERMISSION_DELETE_RECYCLE_BIN_ERROR:
            return "User has no permission to delete recycle bin items in this room."
            
        case .SERVER_UNKNOWN_ERROR:
            return "An unknown server error occurred."
        case .SERVER_MALICIOUS_FILE_DETECTED:
            return "The AV scanner detected that the file could be malicious."
            
        case .SERVER_NODE_NOT_FOUND:
            return "Requested room/folder/file was not found."
        case .SERVER_ROOM_NOT_FOUND:
            return "Requested room was not found."
        case .SERVER_FOLDER_NOT_FOUND:
            return "Requested folder was not found."
        case .SERVER_FILE_NOT_FOUND:
            return "Requested file was not found."
        case .SERVER_SOURCE_NODE_NOT_FOUND:
            return "Source node not found."
        case .SERVER_TARGET_NODE_NOT_FOUND:
            return "Target room or folder was not found."
        case .SERVER_TARGET_ROOM_NOT_FOUND:
            return "Target room was not found."
        case .SERVER_INSUFFICIENT_STORAGE:
            return "Not enough free storage on the server."
        case .SERVER_INSUFFICIENT_CUSTOMER_QUOTA:
            return "Not enough quota for the customer."
        case .SERVER_INSUFFICIENT_ROOM_QUOTA:
            return "Not enough quota for the room."
        case .SERVER_INSUFFICIENT_UL_SHARE_QUOTA:
            return "Not enough quota for the upload share."
        case .SERVER_RESTORE_VERSION_NOT_FOUND:
            return "The restore version id was not found."
        case .SERVER_UPLOAD_NOT_FOUND:
            return "Upload was not found."
            
        case .SERVER_DL_SHARE_NOT_FOUND:
            return "Download share could not be found."
        case .SERVER_UL_SHARE_NOT_FOUND:
            return "Upload share could not be found."
            
        case .SERVER_PLACEHOLDER_CUSTOMER:
            return "Placeholder for customer errors"
        case .SERVER_USER_NOT_FOUND:
            return "User could not be found."
        case .SERVER_USER_KEY_PAIR_NOT_FOUND:
            return "Encryption key pair was not found."
        case .SERVER_USER_KEY_PAIR_ALREADY_SET:
            return "Encryption key pair was already set."
        case .SERVER_USER_FILE_KEY_NOT_FOUND:
            return "Encryption file key could not be found."
        case .SERVER_AVATAR_NOT_FOUND:
            return "Avatar could not be found."
            
        case .SERVER_PLACEHOLDER_GROUPS:
            return "Placeholder for groups errors"
            
        case .SERVER_SMS_IS_DISABLED:
            return "Sending SMS is disabled."
        case .SERVER_SMS_COULD_NOT_BE_SENT:
            return "SMS could not be sent."
        }
    }
}
