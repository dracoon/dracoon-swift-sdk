//
//  DracoonErrorParserTest.swift
//  dracoon-sdk-tests
//
//  Created by Mathias Schreiner on 26.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import XCTest
@testable import dracoon_sdk

class DracoonErrorParserTest: XCTestCase {
    
    let errorParser = DracoonErrorParser()
    
    func testHTTPStatusCodes() {
        XCTAssert(DracoonErrorParser.HTTPStatusCode.BAD_REQUEST == 400)
        XCTAssert(DracoonErrorParser.HTTPStatusCode.UNAUTHORIZED == 401)
        XCTAssert(DracoonErrorParser.HTTPStatusCode.PAYMENT_REQUIRED == 402)
        XCTAssert(DracoonErrorParser.HTTPStatusCode.FORBIDDEN == 403)
        XCTAssert(DracoonErrorParser.HTTPStatusCode.NOT_FOUND == 404)
        XCTAssert(DracoonErrorParser.HTTPStatusCode.CONFLICT == 409)
        XCTAssert(DracoonErrorParser.HTTPStatusCode.PRECONDITION_FAILED == 412)
        XCTAssert(DracoonErrorParser.HTTPStatusCode.TOO_MANY_REQUESTS == 429)
        XCTAssert(DracoonErrorParser.HTTPStatusCode.BAD_GATEWAY == 502)
        XCTAssert(DracoonErrorParser.HTTPStatusCode.GATEWAY_TIMEOUT == 504)
        XCTAssert(DracoonErrorParser.HTTPStatusCode.INSUFFICIENT_STORAGE == 507)
        XCTAssert(DracoonErrorParser.HTTPStatusCode.MALWARE_FOUND == 901)
    }
    
    func testStatusCodeUnknown() {
        var modelToTest = ModelErrorResponse(code: nil, message: nil, debugInfo: nil, errorCode: 0)
        var apiCode = errorParser.parseApiErrorResponse(modelToTest, requestType: .other)
        XCTAssert(apiCode == DracoonApiCode.UNKNOWN)
        
        modelToTest = ModelErrorResponse(code: 0, message: nil, debugInfo: nil, errorCode: 0)
        apiCode = errorParser.parseApiErrorResponse(modelToTest, requestType: .other)
        XCTAssert(apiCode == DracoonApiCode.SERVER_UNKNOWN_ERROR)
    }
    
    func testBadRequestApiCodes() {
        let code = 400
        var expectedApiCode, returnedApiCode: DracoonApiCode
        
        expectedApiCode = DracoonApiCode.VALIDATION_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: nil)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_PASSWORD_NOT_SECURE
        returnedApiCode = self.parseError(code: code, errorCode: -10002)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_ROOM_NOT_ENCRYPTED
        returnedApiCode = self.parseError(code: code, errorCode: -40001)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_SOURCE_ROOM_ENCRYPTED
        returnedApiCode = self.parseError(code: code, errorCode: -40001, requestType: .copyNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_SOURCE_ROOM_ENCRYPTED
        returnedApiCode = self.parseError(code: code, errorCode: -40001, requestType: .moveNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_ROOM_ENCRYPTED
        returnedApiCode = self.parseError(code: code, errorCode: -40002)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_TARGET_ROOM_ENCRYPTED
        returnedApiCode = self.parseError(code: code, errorCode: -40002, requestType: .copyNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_TARGET_ROOM_ENCRYPTED
        returnedApiCode = self.parseError(code: code, errorCode: -40002, requestType: .moveNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_ROOM_CANNOT_BE_UNENCRYPTED_WITH_FILES
        returnedApiCode = self.parseError(code: code, errorCode: -40003)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_ROOM_ALREADY_HAS_RESCUE_KEY
        returnedApiCode = self.parseError(code: code, errorCode: -40004)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_ROOM_CANNOT_BE_ENCRYPTED_WITH_FILES
        returnedApiCode = self.parseError(code: code, errorCode: -40008)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_ROOM_CANNOT_SET_ENCRYPTED_WITH_RECYCLEBIN
        returnedApiCode = self.parseError(code: code, errorCode: -40012)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_ENCRYPTED_FILE_CAN_ONLY_BE_RESTORED_IN_ORIGINAL_ROOM
        returnedApiCode = self.parseError(code: code, errorCode: -40013)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_USER_FILE_KEY_MISSING
        returnedApiCode = self.parseError(code: code, errorCode: -40014)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_ROOM_CANNOT_SET_UNENCRYPTED_WITH_RECYCLEBIN
        returnedApiCode = self.parseError(code: code, errorCode: -40018)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_BAD_FILE_NAME
        returnedApiCode = self.parseError(code: code, errorCode: -40755)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_USER_FILE_KEY_MISSING
        returnedApiCode = self.parseError(code: code, errorCode: -40761)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: -41052)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_CANNOT_COPY_ROOM
        returnedApiCode = self.parseError(code: code, errorCode: -41052, requestType: .copyNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_CANNOT_MOVE_ROOM
        returnedApiCode = self.parseError(code: code, errorCode: -41052, requestType: .moveNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_FILE_CANNOT_BE_TARGET
        returnedApiCode = self.parseError(code: code, errorCode: -41053)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_NODES_NOT_IN_SAME_PARENT
        returnedApiCode = self.parseError(code: code, errorCode: -41054)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_PATH_TOO_LONG
        returnedApiCode = self.parseError(code: code, errorCode: -41200)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_NODE_NO_FAVORITE
        returnedApiCode = self.parseError(code: code, errorCode: -41301)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: -41302)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_CANNOT_COPY_NODE_TO_OWN_PLACE_WITHOUT_RENAME
        returnedApiCode = self.parseError(code: code, errorCode: -41302, requestType: .copyNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_CANNOT_MOVE_NODE_TO_OWN_PLACE
        returnedApiCode = self.parseError(code: code, errorCode: -41302, requestType: .moveNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: -41303)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_CANNOT_COPY_NODE_TO_OWN_PLACE_WITHOUT_RENAME
        returnedApiCode = self.parseError(code: code, errorCode: -41303, requestType: .copyNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_CANNOT_MOVE_NODE_TO_OWN_PLACE
        returnedApiCode = self.parseError(code: code, errorCode: -41303, requestType: .moveNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_USER_HAS_NO_KEY_PAIR
        returnedApiCode = self.parseError(code: code, errorCode: -70020)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_USER_KEY_PAIR_INVALID
        returnedApiCode = self.parseError(code: code, errorCode: -70022)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_USER_KEY_PAIR_INVALID
        returnedApiCode = self.parseError(code: code, errorCode: -70023)
        XCTAssert(expectedApiCode == returnedApiCode)

        expectedApiCode = DracoonApiCode.VALIDATION_FIELD_CANNOT_BE_EMPTY
        returnedApiCode = self.parseError(code: code, errorCode: -80000)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_FIELD_NOT_POSITIVE
        returnedApiCode = self.parseError(code: code, errorCode: -80001)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_FIELD_NOT_ZERO_POSITIVE
        returnedApiCode = self.parseError(code: code, errorCode: -80003)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_EXPIRATION_DATE_IN_PAST
        returnedApiCode = self.parseError(code: code, errorCode: -80006)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_FIELD_MAX_LENGTH_EXCEEDED
        returnedApiCode = self.parseError(code: code, errorCode: -80007)
        XCTAssert(expectedApiCode == returnedApiCode)

        expectedApiCode = DracoonApiCode.VALIDATION_EXPIRATION_DATE_TOO_LATE
        returnedApiCode = self.parseError(code: code, errorCode: -80008)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_EXPIRATION_DATE_TOO_LATE
        returnedApiCode = self.parseError(code: code, errorCode: -80012)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_INVALID_EMAIL_ADDRESS
        returnedApiCode = self.parseError(code: code, errorCode: -80009)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_FIELD_NOT_BETWEEN_0_9999
        returnedApiCode = self.parseError(code: code, errorCode: -80018)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_FIELD_NOT_BETWEEN_1_9999
        returnedApiCode = self.parseError(code: code, errorCode: -80019)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_INPUT_CONTAINS_INVALID_CHARACTERS
        returnedApiCode = self.parseError(code: code, errorCode: -80023)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_INVALID_OFFSET_OR_LIMIT
        returnedApiCode = self.parseError(code: code, errorCode: -80024)
        XCTAssert(expectedApiCode == returnedApiCode)

        expectedApiCode = DracoonApiCode.SERVER_SMS_IS_DISABLED
        returnedApiCode = self.parseError(code: code, errorCode: -80030)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_KEEPSHARELINKS_ONLY_WITH_OVERWRITE
        returnedApiCode = self.parseError(code: code, errorCode: -80034)
        XCTAssert(expectedApiCode == returnedApiCode)

        expectedApiCode = DracoonApiCode.VALIDATION_FIELD_NOT_BETWEEN_0_10
        returnedApiCode = self.parseError(code: code, errorCode: -80035)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_INVALID_ETAGS
        returnedApiCode = self.parseError(code: code, errorCode: -80045)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_TOO_MANY_ITEMS
        returnedApiCode = self.parseError(code: code, errorCode: -80063)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_POLICY_VIOLATION
        returnedApiCode = self.parseError(code: code, errorCode: -80064)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.S3_DIRECT_UPLOAD_ENFORCED
        returnedApiCode = self.parseError(code: code, errorCode: -90033)
        XCTAssert(expectedApiCode == returnedApiCode)
    }
    
    func testUnauthorizedApiCodes() {
        let code = 401
        var expectedApiCode, returnedApiCode: DracoonApiCode
        
        expectedApiCode = DracoonApiCode.AUTH_UNAUTHORIZED
        returnedApiCode = self.parseError(code: code, errorCode: nil)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.AUTH_UNAUTHORIZED
        returnedApiCode = self.parseError(code: code, errorCode: 0)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.AUTH_OAUTH_CLIENT_NO_PERMISSION
        returnedApiCode = self.parseError(code: code, errorCode: -10006)
        XCTAssert(expectedApiCode == returnedApiCode)
    }
    
    func testPaymentRequiredApiCodes() {
        let code = 402
        var expectedApiCode, returnedApiCode: DracoonApiCode
        
        expectedApiCode = DracoonApiCode.PRECONDITION_PAYMENT_REQUIRED
        returnedApiCode = self.parseError(code: code, errorCode: nil)
        XCTAssert(expectedApiCode == returnedApiCode)
    }
    
    func testForbiddenApiCodes() {
        let code = 403
        var expectedApiCode, returnedApiCode: DracoonApiCode
        
        expectedApiCode = DracoonApiCode.PERMISSION_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: nil)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.AUTH_USER_LOCKED
        returnedApiCode = self.parseError(code: code, errorCode: -10003)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.AUTH_USER_LOCKED
        returnedApiCode = self.parseError(code: code, errorCode: -10007)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.AUTH_USER_EXPIRED
        returnedApiCode = self.parseError(code: code, errorCode: -10004)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.AUTH_USER_TEMPORARY_LOCKED
        returnedApiCode = self.parseError(code: code, errorCode: -10005)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_USER_FILE_KEY_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -40761)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_USER_KEY_PAIR_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -70020)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_CREATE_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .createRoom)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_CREATE_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .createFolder)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_CREATE_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .createUpload)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_CREATE_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .copyNodes)
        XCTAssert(expectedApiCode == returnedApiCode)

        expectedApiCode = DracoonApiCode.PERMISSION_UPDATE_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .updateRoom)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_UPDATE_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .updateFolder)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_UPDATE_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .updateFile)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_UPDATE_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .moveNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_READ_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .getNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_READ_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .searchNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_DELETE_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .deleteNodes)
        XCTAssert(expectedApiCode == returnedApiCode)

        expectedApiCode = DracoonApiCode.PERMISSION_MANAGE_DL_SHARES_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .createDLShare)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_MANAGE_DL_SHARES_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .deleteDLShare)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_MANAGE_UL_SHARES_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .createULShare)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PERMISSION_MANAGE_UL_SHARES_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .deleteULShare)
        XCTAssert(expectedApiCode == returnedApiCode)
    }
    
    func testNotFoundApiCodes() {
        let code = 404
        var expectedApiCode, returnedApiCode: DracoonApiCode
        
        expectedApiCode = DracoonApiCode.SERVER_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: nil)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_USER_FILE_KEY_MISSING
        returnedApiCode = self.parseError(code: code, errorCode: -40014)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_FILE_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -40751)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_USER_FILE_KEY_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -40761)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_NODE_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -40000)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_TARGET_ROOM_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -40000, requestType: .createRoom)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_TARGET_NODE_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -40000, requestType: .createFolder)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_ROOM_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -40000, requestType: .updateRoom)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_FOLDER_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -40000, requestType: .updateFolder)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_ROOM_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -40000, requestType: .getMissingFileKeys)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_NODE_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -41000)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_TARGET_ROOM_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -41000, requestType: .createRoom)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_TARGET_NODE_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -41000, requestType: .createFolder)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_ROOM_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -41000, requestType: .updateRoom)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_FOLDER_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -41000, requestType: .updateFolder)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_ROOM_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -41000, requestType: .getMissingFileKeys)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_SOURCE_NODE_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -41050)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_TARGET_NODE_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -41051)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_RESTORE_VERSION_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -41100)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_DL_SHARE_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -60000)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_UL_SHARE_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -60500)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_UPLOAD_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -20501)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_AVATAR_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -70028)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_USER_KEY_PAIR_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -70020)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_NOTIFICATION_CONFIG_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -70120)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_NOTIFICATION_CHANNEL_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -70121)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_NOTIFICATION_CHANNEL_DISABLED
        returnedApiCode = self.parseError(code: code, errorCode: -70122)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_ILLEGAL_NOTIFICATION_CHANNEL
        returnedApiCode = self.parseError(code: code, errorCode: -70123)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_USER_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -70501)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.S3_UPLOAD_ID_NOT_FOUND
        returnedApiCode = self.parseError(code: code, errorCode: -90034)
        XCTAssert(expectedApiCode == returnedApiCode)
    }
    
    func testConflictApiCodes() {
        let code = 409
        var expectedApiCode, returnedApiCode: DracoonApiCode
        
        expectedApiCode = DracoonApiCode.SERVER_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: nil)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_ROOM_FOLDER_CAN_NOT_BE_OVERWRITTEN
        returnedApiCode = self.parseError(code: code, errorCode: -40010)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_NODE_ALREADY_EXISTS
        returnedApiCode = self.parseError(code: code, errorCode: -41001)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: -41304)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_CANNOT_COPY_TO_CHILD
        returnedApiCode = self.parseError(code: code, errorCode: -41304, requestType: .copyNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_CANNOT_MOVE_TO_CHILD
        returnedApiCode = self.parseError(code: code, errorCode: -41304, requestType: .moveNodes)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_USER_KEY_PAIR_ALREADY_SET
        returnedApiCode = self.parseError(code: code, errorCode: -70021)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_ROOM_ALREADY_EXISTS
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .createRoom)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_ROOM_ALREADY_EXISTS
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .updateRoom)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_FOLDER_ALREADY_EXISTS
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .createFolder)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_FOLDER_ALREADY_EXISTS
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .updateFolder)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_FILE_ALREADY_EXISTS
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .updateFile)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.VALIDATION_UL_SHARE_NAME_ALREADY_EXISTS
        returnedApiCode = self.parseError(code: code, errorCode: 0, requestType: .createULShare)
        XCTAssert(expectedApiCode == returnedApiCode)
    }
    
    func testPreconditionFailedApiCodes() {
        let code = 412
        var expectedApiCode, returnedApiCode: DracoonApiCode
        
        expectedApiCode = DracoonApiCode.PRECONDITION_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: nil)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PRECONDITION_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PRECONDITION_MUST_ACCEPT_EULA
        returnedApiCode = self.parseError(code: code, errorCode: -10103)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PRECONDITION_MUST_CHANGE_PASSWORD
        returnedApiCode = self.parseError(code: code, errorCode: -10104)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PRECONDITION_MUST_CHANGE_USER_NAME
        returnedApiCode = self.parseError(code: code, errorCode: -10106)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.PRECONDITION_S3_STORAGE_DISABLED
        returnedApiCode = self.parseError(code: code, errorCode: -90030)
        XCTAssert(expectedApiCode == returnedApiCode)
    }
    
    func testTooManyRequestsApiCodes() {
        let code = 429
        var expectedApiCode, returnedApiCode: DracoonApiCode
        
        expectedApiCode = DracoonApiCode.SERVER_TOO_MANY_REQUESTS
        returnedApiCode = self.parseError(code: code, errorCode: nil)
        XCTAssert(expectedApiCode == returnedApiCode)
    }
    
    func testBadGatewayApiCodes() {
        let code = 502
        var expectedApiCode, returnedApiCode: DracoonApiCode
        
        expectedApiCode = DracoonApiCode.SERVER_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: nil)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_SMS_COULD_NOT_BE_SENT
        returnedApiCode = self.parseError(code: code, errorCode: -90090)
        XCTAssert(expectedApiCode == returnedApiCode)
    }
    
    func testGatewayTimeoutApiCodes() {
        let code = 504
        var expectedApiCode, returnedApiCode: DracoonApiCode
        
        expectedApiCode = DracoonApiCode.SERVER_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: nil)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_UNKNOWN_ERROR
        returnedApiCode = self.parseError(code: code, errorCode: 0)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.S3_CONNECTION_FAILED
        returnedApiCode = self.parseError(code: code, errorCode: -90027)
        XCTAssert(expectedApiCode == returnedApiCode)
    }
    
    func testInsufficientStorageApiCodes() {
        let code = 507
        var expectedApiCode, returnedApiCode: DracoonApiCode
        
        expectedApiCode = DracoonApiCode.SERVER_INSUFFICIENT_STORAGE
        returnedApiCode = self.parseError(code: code, errorCode: nil)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_INSUFFICIENT_STORAGE
        returnedApiCode = self.parseError(code: code, errorCode: 0)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_INSUFFICIENT_ROOM_QUOTA
        returnedApiCode = self.parseError(code: code, errorCode: -40200)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_INSUFFICIENT_UL_SHARE_QUOTA
        returnedApiCode = self.parseError(code: code, errorCode: -50504)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_INSUFFICIENT_CUSTOMER_QUOTA
        returnedApiCode = self.parseError(code: code, errorCode: -90200)
        XCTAssert(expectedApiCode == returnedApiCode)
    }
    
    func testMalwareFoundApiCodes() {
        let code = 901
        var expectedApiCode, returnedApiCode: DracoonApiCode
        
        expectedApiCode = DracoonApiCode.SERVER_MALICIOUS_FILE_DETECTED
        returnedApiCode = self.parseError(code: code, errorCode: nil)
        XCTAssert(expectedApiCode == returnedApiCode)
        
        expectedApiCode = DracoonApiCode.SERVER_MALICIOUS_FILE_DETECTED
        returnedApiCode = self.parseError(code: code, errorCode: 0)
        XCTAssert(expectedApiCode == returnedApiCode)
    }
    
    func parseError(code: Int, errorCode: Int?, requestType: DracoonErrorParser.RequestType = .other) -> DracoonApiCode {
        let modelToTest = ModelErrorResponse(code: code, errorCode: errorCode)
        return errorParser.parseApiErrorResponse(modelToTest, requestType: requestType)
    }
}

extension ModelErrorResponse {
    init(code: Int, errorCode: Int?) {
        self.init(code: code, message: nil, debugInfo: nil, errorCode: errorCode)
    }
}
