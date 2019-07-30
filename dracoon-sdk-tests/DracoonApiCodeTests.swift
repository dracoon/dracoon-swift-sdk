//
//  DracoonApiCodeTests.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 30.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import XCTest
@testable import dracoon_sdk

class DracoonApiCodeTests: XCTestCase {
    
    
    func testAuthenticationApiErrorCodes() {
        XCTAssert(DracoonApiCode.AUTH_UNKNOWN_ERROR.rawValue == 1000)
        XCTAssertEqual(DracoonApiCode.AUTH_UNKNOWN_ERROR.description, "An authentication error occurred.")
        
        XCTAssert(DracoonApiCode.AUTH_OAUTH_CLIENT_UNKNOWN.rawValue == 1100)
        XCTAssertEqual(DracoonApiCode.AUTH_OAUTH_CLIENT_UNKNOWN.description, "OAuth client is unknown.")
        
        XCTAssert(DracoonApiCode.AUTH_OAUTH_CLIENT_UNAUTHORIZED.rawValue == 1101)
        XCTAssertEqual(DracoonApiCode.AUTH_OAUTH_CLIENT_UNAUTHORIZED.description, "OAuth client is unauthorized.")
        
        XCTAssert(DracoonApiCode.AUTH_OAUTH_GRANT_TYPE_NOT_ALLOWED.rawValue == 1102)
        XCTAssertEqual(DracoonApiCode.AUTH_OAUTH_GRANT_TYPE_NOT_ALLOWED.description, "OAuth grant type is not allowed.")
        
        XCTAssert(DracoonApiCode.AUTH_OAUTH_AUTHORIZATION_REQUEST_INVALID.rawValue == 1103)
        XCTAssertEqual(DracoonApiCode.AUTH_OAUTH_AUTHORIZATION_REQUEST_INVALID.description, "OAuth authorization request is invalid.")
        
        XCTAssert(DracoonApiCode.AUTH_OAUTH_AUTHORIZATION_SCOPE_INVALID.rawValue == 1104)
        XCTAssertEqual(DracoonApiCode.AUTH_OAUTH_AUTHORIZATION_SCOPE_INVALID.description, "OAuth scope is invalid.")
        
        XCTAssert(DracoonApiCode.AUTH_OAUTH_AUTHORIZATION_ACCESS_DENIED.rawValue == 1105)
        XCTAssertEqual(DracoonApiCode.AUTH_OAUTH_AUTHORIZATION_ACCESS_DENIED.description, "OAuth access was denied.")
        
        XCTAssert(DracoonApiCode.AUTH_OAUTH_TOKEN_REQUEST_INVALID.rawValue == 1106)
        XCTAssertEqual(DracoonApiCode.AUTH_OAUTH_TOKEN_REQUEST_INVALID.description, "OAuth token request is invalid.")
        
        XCTAssert(DracoonApiCode.AUTH_OAUTH_TOKEN_CODE_INVALID.rawValue == 1107)
        XCTAssertEqual(DracoonApiCode.AUTH_OAUTH_TOKEN_CODE_INVALID.description, "OAuth authorization code is invalid.")
        
        XCTAssert(DracoonApiCode.AUTH_OAUTH_REFRESH_REQUEST_INVALID.rawValue == 1108)
        XCTAssertEqual(DracoonApiCode.AUTH_OAUTH_REFRESH_REQUEST_INVALID.description, "OAuth token refresh request is invalid.")
        
        XCTAssert(DracoonApiCode.AUTH_OAUTH_REFRESH_TOKEN_INVALID.rawValue == 1109)
        XCTAssertEqual(DracoonApiCode.AUTH_OAUTH_REFRESH_TOKEN_INVALID.description, "OAuth refresh token is invalid.")
        
        XCTAssert(DracoonApiCode.AUTH_OAUTH_CLIENT_NO_PERMISSION.rawValue == 1150)
        XCTAssertEqual(DracoonApiCode.AUTH_OAUTH_CLIENT_NO_PERMISSION.description, "OAuth client has no permission to execute the action.")
        
        XCTAssert(DracoonApiCode.AUTH_UNAUTHORIZED.rawValue == 1200)
        XCTAssertEqual(DracoonApiCode.AUTH_UNAUTHORIZED.description, "Unauthorized.")
        
        XCTAssert(DracoonApiCode.AUTH_USER_TEMPORARY_LOCKED.rawValue == 1300)
        XCTAssertEqual(DracoonApiCode.AUTH_USER_TEMPORARY_LOCKED.description, "User is temporary locked.")
        
        XCTAssert(DracoonApiCode.AUTH_USER_LOCKED.rawValue == 1301)
        XCTAssertEqual(DracoonApiCode.AUTH_USER_LOCKED.description, "User is locked.")
        
        XCTAssert(DracoonApiCode.AUTH_USER_EXPIRED.rawValue == 1302)
        XCTAssertEqual(DracoonApiCode.AUTH_USER_EXPIRED.description, "User is expired.")
    }
    
    func testPreconditionApiErrorCodes() {
        
        XCTAssert(DracoonApiCode.PRECONDITION_UNKNOWN_ERROR.rawValue == 2000)
        XCTAssertEqual(DracoonApiCode.PRECONDITION_UNKNOWN_ERROR.description, "A precondition is not fulfilled.")
        
        XCTAssert(DracoonApiCode.PRECONDITION_MUST_ACCEPT_EULA.rawValue == 2101)
        XCTAssertEqual(DracoonApiCode.PRECONDITION_MUST_ACCEPT_EULA.description, "User must accept EULA.")
        
        XCTAssert(DracoonApiCode.PRECONDITION_MUST_CHANGE_USER_NAME.rawValue == 2102)
        XCTAssertEqual(DracoonApiCode.PRECONDITION_MUST_CHANGE_USER_NAME.description, "User must change his user name.")
        
        XCTAssert(DracoonApiCode.PRECONDITION_MUST_CHANGE_PASSWORD.rawValue == 2103)
        XCTAssertEqual(DracoonApiCode.PRECONDITION_MUST_CHANGE_PASSWORD.description, "User must change his password.")
        
       
    }
    
    func testValidationApiErrorCodes() {
        
        XCTAssert(DracoonApiCode.VALIDATION_UNKNOWN_ERROR.rawValue == 3000)
        XCTAssertEqual(DracoonApiCode.VALIDATION_UNKNOWN_ERROR.description, "The server request was invalid.")
        
        XCTAssert(DracoonApiCode.VALIDATION_FIELD_CANNOT_BE_EMPTY.rawValue == 3001)
        XCTAssertEqual(DracoonApiCode.VALIDATION_FIELD_CANNOT_BE_EMPTY.description, "Mandatory fields cannnot be empty.")
        
        XCTAssert(DracoonApiCode.VALIDATION_FIELD_NOT_ZERO_POSITIVE.rawValue == 3002)
        XCTAssertEqual(DracoonApiCode.VALIDATION_FIELD_NOT_ZERO_POSITIVE.description, "Field value must be zero or positive.")
        
        XCTAssert(DracoonApiCode.VALIDATION_FIELD_NOT_POSITIVE.rawValue == 3003)
        XCTAssertEqual(DracoonApiCode.VALIDATION_FIELD_NOT_POSITIVE.description, "Field value must be positive.")
        
        XCTAssert(DracoonApiCode.VALIDATION_FIELD_MAX_LENGTH_EXCEEDED.rawValue == 3004)
        XCTAssertEqual(DracoonApiCode.VALIDATION_FIELD_MAX_LENGTH_EXCEEDED.description, "Maximum allowed field length is exceeded.")
        
        XCTAssert(DracoonApiCode.VALIDATION_FIELD_NOT_BETWEEN_0_10.rawValue == 3005)
        XCTAssertEqual(DracoonApiCode.VALIDATION_FIELD_NOT_BETWEEN_0_10.description, "Field value must be between 0 and 10.")
        
        XCTAssert(DracoonApiCode.VALIDATION_FIELD_NOT_BETWEEN_0_9999.rawValue == 3006)
        XCTAssertEqual(DracoonApiCode.VALIDATION_FIELD_NOT_BETWEEN_0_9999.description, "Field value must be between 0 and 9999.")
        
        XCTAssert(DracoonApiCode.VALIDATION_FIELD_NOT_BETWEEN_1_9999.rawValue == 3007)
        XCTAssertEqual(DracoonApiCode.VALIDATION_FIELD_NOT_BETWEEN_1_9999.description, "Field value must be between 1 and 9999.")
        
        XCTAssert(DracoonApiCode.VALIDATION_INVALID_OFFSET_OR_LIMIT.rawValue == 3008)
        XCTAssertEqual(DracoonApiCode.VALIDATION_INVALID_OFFSET_OR_LIMIT.description, "Invalid offset or limit.")
        
        // Nodes
        
        XCTAssert(DracoonApiCode.VALIDATION_FILE_CANNOT_BE_TARGET.rawValue == 3100)
        XCTAssertEqual(DracoonApiCode.VALIDATION_FILE_CANNOT_BE_TARGET.description, "File cannot be target of a copy or move operation.")
        
        XCTAssert(DracoonApiCode.VALIDATION_BAD_FILE_NAME.rawValue == 3101)
        XCTAssertEqual(DracoonApiCode.VALIDATION_BAD_FILE_NAME.description, "Bad file name.")
        
        XCTAssert(DracoonApiCode.VALIDATION_EXPIRATION_DATE_IN_PAST.rawValue == 3102)
        XCTAssertEqual(DracoonApiCode.VALIDATION_EXPIRATION_DATE_IN_PAST.description, "Expiration date is in the past.")
        
        XCTAssert(DracoonApiCode.VALIDATION_EXPIRATION_DATE_TOO_LATE.rawValue == 3103)
        XCTAssertEqual(DracoonApiCode.VALIDATION_EXPIRATION_DATE_TOO_LATE.description, "The year is too far in the future. Max year is limited to 9999.")
        
        XCTAssert(DracoonApiCode.VALIDATION_NODE_ALREADY_EXISTS.rawValue == 3104)
        XCTAssertEqual(DracoonApiCode.VALIDATION_NODE_ALREADY_EXISTS.description, "Node exists already.")
        
        XCTAssert(DracoonApiCode.VALIDATION_ROOM_ALREADY_EXISTS.rawValue == 3105)
        XCTAssertEqual(DracoonApiCode.VALIDATION_ROOM_ALREADY_EXISTS.description, "A room with the same name already exists.")
        
        XCTAssert(DracoonApiCode.VALIDATION_FOLDER_ALREADY_EXISTS.rawValue == 3106)
        XCTAssertEqual(DracoonApiCode.VALIDATION_FOLDER_ALREADY_EXISTS.description, "A folder with the same name already exists.")
        
        XCTAssert(DracoonApiCode.VALIDATION_FILE_ALREADY_EXISTS.rawValue == 3107)
        XCTAssertEqual(DracoonApiCode.VALIDATION_FILE_ALREADY_EXISTS.description, "A file with the same name already exists.")
        
        XCTAssert(DracoonApiCode.VALIDATION_NODES_NOT_IN_SAME_PARENT.rawValue == 3108)
        XCTAssertEqual(DracoonApiCode.VALIDATION_NODES_NOT_IN_SAME_PARENT.description, "Folders/files must be in same parent.")
        
        XCTAssert(DracoonApiCode.VALIDATION_CANNOT_COPY_NODE_TO_OWN_PLACE_WITHOUT_RENAME.rawValue == 3109)
        XCTAssertEqual(DracoonApiCode.VALIDATION_CANNOT_COPY_NODE_TO_OWN_PLACE_WITHOUT_RENAME.description, "Node cannot be copied to its own place without renaming.")
        
        XCTAssert(DracoonApiCode.VALIDATION_CANNOT_MOVE_NODE_TO_OWN_PLACE.rawValue == 3110)
        XCTAssertEqual(DracoonApiCode.VALIDATION_CANNOT_MOVE_NODE_TO_OWN_PLACE.description, "Node cannot be moved to its own place.")
        
        XCTAssert(DracoonApiCode.VALIDATION_ROOM_FOLDER_CAN_NOT_BE_OVERWRITTEN.rawValue == 3111)
        XCTAssertEqual(DracoonApiCode.VALIDATION_ROOM_FOLDER_CAN_NOT_BE_OVERWRITTEN.description, "A room or folder cannot be overwritten.")
        
        XCTAssert(DracoonApiCode.VALIDATION_CANNOT_COPY_TO_CHILD.rawValue == 3112)
        XCTAssertEqual(DracoonApiCode.VALIDATION_CANNOT_COPY_TO_CHILD.description, "Node cannot be copied into its child node.")
        
        XCTAssert(DracoonApiCode.VALIDATION_CANNOT_MOVE_TO_CHILD.rawValue == 3113)
        XCTAssertEqual(DracoonApiCode.VALIDATION_CANNOT_MOVE_TO_CHILD.description, "Node cannot be moved into its child node.")
        
        XCTAssert(DracoonApiCode.VALIDATION_CANNOT_COPY_ROOM.rawValue == 3114)
        XCTAssertEqual(DracoonApiCode.VALIDATION_CANNOT_COPY_ROOM.description, "Rooms cannot be copied.")
        
        XCTAssert(DracoonApiCode.VALIDATION_CANNOT_MOVE_ROOM.rawValue == 3115)
        XCTAssertEqual(DracoonApiCode.VALIDATION_CANNOT_MOVE_ROOM.description, "Rooms cannot be moved.")
        
        XCTAssert(DracoonApiCode.VALIDATION_PATH_TOO_LONG.rawValue == 3116)
        XCTAssertEqual(DracoonApiCode.VALIDATION_PATH_TOO_LONG.description, "Path is too long.")
        
        XCTAssert(DracoonApiCode.VALIDATION_NODE_NO_FAVORITE.rawValue == 3117)
        XCTAssertEqual(DracoonApiCode.VALIDATION_NODE_NO_FAVORITE.description, "Node is not marked as favorite.")
        
        XCTAssert(DracoonApiCode.VALIDATION_ROOM_NOT_ENCRYPTED.rawValue == 3118)
        XCTAssertEqual(DracoonApiCode.VALIDATION_ROOM_NOT_ENCRYPTED.description, "Room is not encrypted.")
        
        XCTAssert(DracoonApiCode.VALIDATION_SOURCE_ROOM_ENCRYPTED.rawValue == 3119)
        XCTAssertEqual(DracoonApiCode.VALIDATION_SOURCE_ROOM_ENCRYPTED.description, "Encrypted files cannot be copied or moved to an unencrypted room.")
        
        XCTAssert(DracoonApiCode.VALIDATION_TARGET_ROOM_ENCRYPTED.rawValue == 3120)
        XCTAssertEqual(DracoonApiCode.VALIDATION_TARGET_ROOM_ENCRYPTED.description, "Not encrypted files cannot be copied or moved to an encrypted room.")
        
        XCTAssert(DracoonApiCode.VALIDATION_ROOM_ENCRYPTED.rawValue == 3121)
        XCTAssertEqual(DracoonApiCode.VALIDATION_ROOM_ENCRYPTED.description, "Room is encrypted.")
        
        XCTAssert(DracoonApiCode.VALIDATION_ROOM_CANNOT_BE_UNENCRYPTED_WITH_FILES.rawValue == 3122)
        XCTAssertEqual(DracoonApiCode.VALIDATION_ROOM_CANNOT_BE_UNENCRYPTED_WITH_FILES.description, "Room with files cannot be unencrypted.")
        
        XCTAssert(DracoonApiCode.VALIDATION_ROOM_CANNOT_BE_ENCRYPTED_WITH_FILES.rawValue == 3123)
        XCTAssertEqual(DracoonApiCode.VALIDATION_ROOM_CANNOT_BE_ENCRYPTED_WITH_FILES.description, "Room with files cannot be encrypted.")
        
        XCTAssert(DracoonApiCode.VALIDATION_ROOM_ALREADY_HAS_RESCUE_KEY.rawValue == 3124)
        XCTAssertEqual(DracoonApiCode.VALIDATION_ROOM_ALREADY_HAS_RESCUE_KEY.description, "Only one room emergency password (rescue key) is allowed.")
        
        XCTAssert(DracoonApiCode.VALIDATION_ROOM_CANNOT_SET_ENCRYPTED_WITH_RECYCLEBIN.rawValue == 3125)
        XCTAssertEqual(DracoonApiCode.VALIDATION_ROOM_CANNOT_SET_ENCRYPTED_WITH_RECYCLEBIN.description, "Room with not empty recycle bin cannot be set encrypted.")
        
        XCTAssert(DracoonApiCode.VALIDATION_ROOM_CANNOT_SET_UNENCRYPTED_WITH_RECYCLEBIN.rawValue == 3126)
        XCTAssertEqual(DracoonApiCode.VALIDATION_ROOM_CANNOT_SET_UNENCRYPTED_WITH_RECYCLEBIN .description, "Room with not empty recycle bin cannot be set unencrypted.")
        
        XCTAssert(DracoonApiCode.VALIDATION_ENCRYPTED_FILE_CAN_ONLY_BE_RESTORED_IN_ORIGINAL_ROOM.rawValue == 3127)
        XCTAssertEqual(DracoonApiCode.VALIDATION_ENCRYPTED_FILE_CAN_ONLY_BE_RESTORED_IN_ORIGINAL_ROOM.description, "Encrypted files cannot be restored inside another than its original room.")
        
        XCTAssert(DracoonApiCode.VALIDATION_KEEPSHARELINKS_ONLY_WITH_OVERWRITE.rawValue == 3128)
        XCTAssertEqual(DracoonApiCode.VALIDATION_KEEPSHARELINKS_ONLY_WITH_OVERWRITE.description, "Keep share links is only allowed with resolution strategy 'overwrite'.")
        
        // Shares
        
        XCTAssert(DracoonApiCode.VALIDATION_DL_SHARE_CANNOT_CREATE_ON_ENCRYPTED_ROOM_FOLDER.rawValue == 3200)
        XCTAssertEqual(DracoonApiCode.VALIDATION_DL_SHARE_CANNOT_CREATE_ON_ENCRYPTED_ROOM_FOLDER.description, "A download share cannot be created on a encrypted room or folder.")
        
        XCTAssert(DracoonApiCode.VALIDATION_UL_SHARE_NAME_ALREADY_EXISTS.rawValue == 3201)
        XCTAssertEqual(DracoonApiCode.VALIDATION_UL_SHARE_NAME_ALREADY_EXISTS.description, "Upload share name already exists.")
        
        // Customer
        
        XCTAssert(DracoonApiCode.VALIDATION_PLACEHOLDER_CUSTOMER.rawValue == 3400)
        XCTAssertEqual(DracoonApiCode.VALIDATION_PLACEHOLDER_CUSTOMER.description, "Placeholder for customer validation errors")
        
        // Users
        
        XCTAssert(DracoonApiCode.VALIDATION_PLACEHOLDER_USERS.rawValue == 3500)
        XCTAssertEqual(DracoonApiCode.VALIDATION_PLACEHOLDER_USERS.description, "Placeholder for users validation errors")
        
        XCTAssert(DracoonApiCode.VALIDATION_USER_HAS_NO_KEY_PAIR.rawValue == 3550)
        XCTAssertEqual(DracoonApiCode.VALIDATION_USER_HAS_NO_KEY_PAIR.description, "User has no encryption key pair.")
        
        XCTAssert(DracoonApiCode.VALIDATION_USER_KEY_PAIR_INVALID.rawValue == 3551)
        XCTAssertEqual(DracoonApiCode.VALIDATION_USER_KEY_PAIR_INVALID.description, "Invalid encryption key pair.")
        
        XCTAssert(DracoonApiCode.VALIDATION_USER_FILE_KEY_MISSING.rawValue == 3552)
        XCTAssertEqual(DracoonApiCode.VALIDATION_USER_FILE_KEY_MISSING.description, "File key has to be provided")
        
        // Groups
        
        XCTAssert(DracoonApiCode.VALIDATION_PLACEHOLDER_GROUPS.rawValue == 3600)
        XCTAssertEqual(DracoonApiCode.VALIDATION_PLACEHOLDER_GROUPS.description, "Placeholder for groups validation errors")
        
        // Other
        
        XCTAssert(DracoonApiCode.VALIDATION_PASSWORD_NOT_SECURE.rawValue == 3800)
        XCTAssertEqual(DracoonApiCode.VALIDATION_PASSWORD_NOT_SECURE.description, "Password is not secure.")
        
        XCTAssert(DracoonApiCode.VALIDATION_INVALID_EMAIL_ADDRESS.rawValue == 3801)
        XCTAssertEqual(DracoonApiCode.VALIDATION_INVALID_EMAIL_ADDRESS.description, "Invalid email address.")
        
    }
}
