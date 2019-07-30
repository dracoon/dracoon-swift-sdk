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
    }
}
