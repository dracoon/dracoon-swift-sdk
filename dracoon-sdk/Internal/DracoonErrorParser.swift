//
//  DracoonErrorParser.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 07.03.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

public class DracoonErrorParser {
    
    public enum RequestType {
        case other
        case createRoom
        case createFolder
        case updateRoom
        case updateFolder
        case updateFile
        case copyNodes
        case moveNodes
        case deleteNodes
        case getNodes
        case searchNodes
        case createDLShare
        case createULShare
        case deleteDLShare
        case deleteULShare
        case createUpload
        case getMissingFileKeys
    }
    
    public struct HTTPStatusCode {
        public static let BAD_REQUEST = 400
        public static let UNAUTHORIZED = 401
        public static let PAYMENT_REQUIRED = 402
        public static let FORBIDDEN = 403
        public static let NOT_FOUND = 404
        public static let CONFLICT = 409
        public static let PRECONDITION_FAILED = 412
        public static let TOO_MANY_REQUESTS = 429
        public static let BAD_GATEWAY = 502
        public static let GATEWAY_TIMEOUT = 504
        public static let INSUFFICIENT_STORAGE = 507
        public static let MALWARE_FOUND = 901
    }
    
    typealias Status = HTTPStatusCode
    
    public static let shared = DracoonErrorParser()
    
    public func parseApiErrorResponse(_ response: ModelErrorResponse, requestType: RequestType) -> DracoonApiCode {
        guard let httpStatusCode = response.code else {
            return DracoonApiCode.UNKNOWN
        }
        switch httpStatusCode {
        case Status.BAD_REQUEST:
            return self.parseBadRequest(response, requestType: requestType)
        case Status.UNAUTHORIZED:
            return self.parseUnauthorized(response, requestType: requestType)
        case Status.PAYMENT_REQUIRED:
            return DracoonApiCode.PRECONDITION_PAYMENT_REQUIRED
        case Status.FORBIDDEN:
            return self.parseForbidden(response, requestType: requestType)
        case Status.NOT_FOUND:
            return self.parseNotFound(response, requestType: requestType)
        case Status.CONFLICT:
            return self.parseConflict(response, requestType: requestType)
        case Status.PRECONDITION_FAILED:
            return self.parsePreconditionFailed(response, requestType: requestType)
        case Status.TOO_MANY_REQUESTS:
            return DracoonApiCode.SERVER_TOO_MANY_REQUESTS
        case Status.BAD_GATEWAY:
            return self.parseBadGateway(response, requestType: requestType)
        case Status.GATEWAY_TIMEOUT:
            return self.parseGatewayTimeout(response, requestType: requestType)
        case Status.INSUFFICIENT_STORAGE:
            return self.parseInsufficientStorage(response, requestType: requestType)
        case Status.MALWARE_FOUND:
            return self.parseMalwareFound(response, requestType: requestType)
        default:
            return DracoonApiCode.SERVER_UNKNOWN_ERROR
        }
    }
    
    private func parseBadRequest(_ response: ModelErrorResponse, requestType: RequestType) -> DracoonApiCode {
        guard let apiErrorCode = response.errorCode else {
            return DracoonApiCode.VALIDATION_UNKNOWN_ERROR
        }
        
        switch apiErrorCode {
        case -10002:
            return DracoonApiCode.VALIDATION_PASSWORD_NOT_SECURE
        case -40001:
            switch requestType {
            case .copyNodes:
                fallthrough
            case .moveNodes:
                return DracoonApiCode.VALIDATION_SOURCE_ROOM_ENCRYPTED
            default:
                return DracoonApiCode.VALIDATION_ROOM_NOT_ENCRYPTED
            }
        case -40002:
            switch requestType {
            case .copyNodes:
                fallthrough
            case .moveNodes:
                return DracoonApiCode.VALIDATION_TARGET_ROOM_ENCRYPTED
            default:
                return DracoonApiCode.VALIDATION_ROOM_ENCRYPTED
            }
        case -40003:
            return DracoonApiCode.VALIDATION_ROOM_CANNOT_BE_UNENCRYPTED_WITH_FILES
        case -40004:
            return DracoonApiCode.VALIDATION_ROOM_ALREADY_HAS_RESCUE_KEY
        case -40008:
            return DracoonApiCode.VALIDATION_ROOM_CANNOT_BE_ENCRYPTED_WITH_FILES
        case -40012:
            return DracoonApiCode.VALIDATION_ROOM_CANNOT_SET_ENCRYPTED_WITH_RECYCLEBIN
        case -40013:
            return DracoonApiCode.VALIDATION_ENCRYPTED_FILE_CAN_ONLY_BE_RESTORED_IN_ORIGINAL_ROOM
        case -40014:
            return DracoonApiCode.VALIDATION_USER_FILE_KEY_MISSING
        case -40018:
            return DracoonApiCode.VALIDATION_ROOM_CANNOT_SET_UNENCRYPTED_WITH_RECYCLEBIN
        case -40755:
            return DracoonApiCode.VALIDATION_BAD_FILE_NAME
        case -40761:
            return DracoonApiCode.VALIDATION_USER_FILE_KEY_MISSING
        case -41052:
            switch requestType {
            case .copyNodes:
                return DracoonApiCode.VALIDATION_CANNOT_COPY_ROOM
            case .moveNodes:
                return DracoonApiCode.VALIDATION_CANNOT_MOVE_ROOM
            default:
                return DracoonApiCode.VALIDATION_UNKNOWN_ERROR
            }
        case -41053:
            return DracoonApiCode.VALIDATION_FILE_CANNOT_BE_TARGET
        case -41054:
            return DracoonApiCode.VALIDATION_NODES_NOT_IN_SAME_PARENT
        case -41200:
            return DracoonApiCode.VALIDATION_PATH_TOO_LONG
        case -41301:
            return DracoonApiCode.VALIDATION_NODE_NO_FAVORITE
        case -41302:
            fallthrough
        case -41303:
            switch requestType {
            case .copyNodes:
                return DracoonApiCode.VALIDATION_CANNOT_COPY_NODE_TO_OWN_PLACE_WITHOUT_RENAME
            case .moveNodes:
                return DracoonApiCode.VALIDATION_CANNOT_MOVE_NODE_TO_OWN_PLACE
            default:
                return DracoonApiCode.VALIDATION_UNKNOWN_ERROR
            }
        case -70020:
            return DracoonApiCode.VALIDATION_USER_HAS_NO_KEY_PAIR
        case -70022:
            fallthrough
        case -70023:
            return DracoonApiCode.VALIDATION_USER_KEY_PAIR_INVALID
        case -80000:
            return DracoonApiCode.VALIDATION_FIELD_CANNOT_BE_EMPTY
        case -80001:
            return DracoonApiCode.VALIDATION_FIELD_NOT_POSITIVE
        case -80003:
            return DracoonApiCode.VALIDATION_FIELD_NOT_ZERO_POSITIVE
        case -80006:
            return DracoonApiCode.VALIDATION_EXPIRATION_DATE_IN_PAST
        case -80007:
            return DracoonApiCode.VALIDATION_FIELD_MAX_LENGTH_EXCEEDED
        case -80008:
            fallthrough
        case -80012:
            return DracoonApiCode.VALIDATION_EXPIRATION_DATE_TOO_LATE
        case -80009:
            return DracoonApiCode.VALIDATION_INVALID_EMAIL_ADDRESS
        case -80018:
            return DracoonApiCode.VALIDATION_FIELD_NOT_BETWEEN_0_9999
        case -80019:
            return DracoonApiCode.VALIDATION_FIELD_NOT_BETWEEN_1_9999
        case -80023:
            return DracoonApiCode.VALIDATION_INPUT_CONTAINS_INVALID_CHARACTERS
        case -80024:
            return DracoonApiCode.VALIDATION_INVALID_OFFSET_OR_LIMIT
        case -80030:
            return DracoonApiCode.SERVER_SMS_IS_DISABLED
        case -80034:
            return DracoonApiCode.VALIDATION_KEEPSHARELINKS_ONLY_WITH_OVERWRITE
        case -80035:
            return DracoonApiCode.VALIDATION_FIELD_NOT_BETWEEN_0_10
        case -80045:
            return DracoonApiCode.VALIDATION_INVALID_ETAGS
        case -80063:
            return DracoonApiCode.VALIDATION_TOO_MANY_ITEMS
        case -80064:
            return DracoonApiCode.VALIDATION_POLICY_VIOLATION
        case -90033:
            return DracoonApiCode.S3_DIRECT_UPLOAD_ENFORCED
        default:
            return DracoonApiCode.VALIDATION_UNKNOWN_ERROR
        }
    }
    
    private func parseUnauthorized(_ response: ModelErrorResponse, requestType: RequestType) -> DracoonApiCode {
        guard let apiErrorCode = response.errorCode else {
            return DracoonApiCode.AUTH_UNAUTHORIZED
        }
        if (apiErrorCode == -10006) {
            return DracoonApiCode.AUTH_OAUTH_CLIENT_NO_PERMISSION
        }
        return DracoonApiCode.AUTH_UNAUTHORIZED
    }
    
    private func parseForbidden(_ response: ModelErrorResponse, requestType: RequestType) -> DracoonApiCode {
        guard let apiErrorCode = response.errorCode else {
            return DracoonApiCode.PERMISSION_UNKNOWN_ERROR
        }
        
        switch apiErrorCode {
        case -10003:
            fallthrough
        case -10007:
            return DracoonApiCode.AUTH_USER_LOCKED
        case -10004:
            return DracoonApiCode.AUTH_USER_EXPIRED
        case -10005:
            return DracoonApiCode.AUTH_USER_TEMPORARY_LOCKED
        case -40761:
            return DracoonApiCode.SERVER_USER_FILE_KEY_NOT_FOUND
        case -70020:
            return DracoonApiCode.SERVER_USER_KEY_PAIR_NOT_FOUND
        default:
            switch requestType {
            case .createRoom:
                fallthrough
            case .createFolder:
                fallthrough
            case .createUpload:
                fallthrough
            case .copyNodes:
                return DracoonApiCode.PERMISSION_CREATE_ERROR
            case .updateRoom:
                fallthrough
            case .updateFolder:
                fallthrough
            case .updateFile:
                fallthrough
            case .moveNodes:
                return DracoonApiCode.PERMISSION_UPDATE_ERROR
            case .getNodes:
                fallthrough
            case .searchNodes:
                return DracoonApiCode.PERMISSION_READ_ERROR
            case .deleteNodes:
                return DracoonApiCode.PERMISSION_DELETE_ERROR
            case .createDLShare:
                fallthrough
            case .deleteDLShare:
                return DracoonApiCode.PERMISSION_MANAGE_DL_SHARES_ERROR
            case .createULShare:
                fallthrough
            case .deleteULShare:
                return DracoonApiCode.PERMISSION_MANAGE_UL_SHARES_ERROR
            default:
                return DracoonApiCode.PERMISSION_UNKNOWN_ERROR
            }
        }
    }
    
    private func parseNotFound(_ response: ModelErrorResponse, requestType: RequestType) -> DracoonApiCode {
        guard let apiErrorCode = response.errorCode else {
            return DracoonApiCode.SERVER_UNKNOWN_ERROR
        }
        
        switch apiErrorCode {
        case -40014:
            return DracoonApiCode.VALIDATION_USER_FILE_KEY_MISSING
        case -40751:
            return DracoonApiCode.SERVER_FILE_NOT_FOUND
        case -40761:
            return DracoonApiCode.SERVER_USER_FILE_KEY_NOT_FOUND
        case -40000:
            fallthrough
        case -41000:
            switch requestType {
            case .createRoom:
                return DracoonApiCode.SERVER_TARGET_ROOM_NOT_FOUND
            case .createFolder:
                return DracoonApiCode.SERVER_TARGET_NODE_NOT_FOUND
            case .updateRoom:
                fallthrough
            case .getMissingFileKeys:
                return DracoonApiCode.SERVER_ROOM_NOT_FOUND
            case .updateFolder:
                return DracoonApiCode.SERVER_FOLDER_NOT_FOUND
            default:
                return DracoonApiCode.SERVER_NODE_NOT_FOUND
            }
        case -41050:
            return DracoonApiCode.SERVER_SOURCE_NODE_NOT_FOUND
        case -41051:
            return DracoonApiCode.SERVER_TARGET_NODE_NOT_FOUND
        case -41100:
            return DracoonApiCode.SERVER_RESTORE_VERSION_NOT_FOUND
        case -60000:
            return DracoonApiCode.SERVER_DL_SHARE_NOT_FOUND
        case -60500:
            return DracoonApiCode.SERVER_UL_SHARE_NOT_FOUND
        case -20501:
            return DracoonApiCode.SERVER_UPLOAD_NOT_FOUND
        case -70020:
            return DracoonApiCode.SERVER_USER_KEY_PAIR_NOT_FOUND
        case -70028:
            return DracoonApiCode.SERVER_AVATAR_NOT_FOUND
        case -70120:
            return DracoonApiCode.SERVER_NOTIFICATION_CONFIG_NOT_FOUND
        case -70121:
            return DracoonApiCode.SERVER_NOTIFICATION_CHANNEL_NOT_FOUND
        case -70122:
            return DracoonApiCode.SERVER_NOTIFICATION_CHANNEL_DISABLED
        case -70123:
            return DracoonApiCode.SERVER_ILLEGAL_NOTIFICATION_CHANNEL
        case -70501:
            return DracoonApiCode.SERVER_USER_NOT_FOUND
        case -90034:
            return DracoonApiCode.S3_UPLOAD_ID_NOT_FOUND
        default:
            return DracoonApiCode.SERVER_UNKNOWN_ERROR
        }
    }
    
    private func parseConflict(_ response: ModelErrorResponse, requestType: RequestType) -> DracoonApiCode {
        let apiErrorCode = response.errorCode
        
        switch apiErrorCode {
        case -40010:
            return DracoonApiCode.VALIDATION_ROOM_FOLDER_CAN_NOT_BE_OVERWRITTEN
        case -41001:
            return DracoonApiCode.VALIDATION_NODE_ALREADY_EXISTS
        case -41304:
            switch requestType {
            case .copyNodes:
                return DracoonApiCode.VALIDATION_CANNOT_COPY_TO_CHILD
            case .moveNodes:
                return DracoonApiCode.VALIDATION_CANNOT_MOVE_TO_CHILD
            default:
                return DracoonApiCode.SERVER_UNKNOWN_ERROR
            }
        case -70021:
            return DracoonApiCode.SERVER_USER_KEY_PAIR_ALREADY_SET
        default:
            switch requestType {
            case .createRoom:
                fallthrough
            case .updateRoom:
                return DracoonApiCode.VALIDATION_ROOM_ALREADY_EXISTS
            case .createFolder:
                fallthrough
            case .updateFolder:
                return DracoonApiCode.VALIDATION_FOLDER_ALREADY_EXISTS
            case .updateFile:
                return DracoonApiCode.VALIDATION_FILE_ALREADY_EXISTS
            case .createULShare:
                return DracoonApiCode.VALIDATION_UL_SHARE_NAME_ALREADY_EXISTS
            default:
                return DracoonApiCode.SERVER_UNKNOWN_ERROR
            }
        }
    }
    
    private func parsePreconditionFailed(_ response: ModelErrorResponse, requestType: RequestType) -> DracoonApiCode {
        guard let apiErrorCode = response.errorCode else {
            return DracoonApiCode.PRECONDITION_UNKNOWN_ERROR
        }
        
        switch apiErrorCode {
        case -10103:
            return DracoonApiCode.PRECONDITION_MUST_ACCEPT_EULA
        case -10104:
            return DracoonApiCode.PRECONDITION_MUST_CHANGE_PASSWORD
        case -10106:
            return DracoonApiCode.PRECONDITION_MUST_CHANGE_USER_NAME
        case -90030:
            return DracoonApiCode.PRECONDITION_S3_STORAGE_DISABLED
        default:
            return DracoonApiCode.PRECONDITION_UNKNOWN_ERROR
        }
    }
    
    private func parseBadGateway(_ response: ModelErrorResponse, requestType: RequestType) -> DracoonApiCode {
        guard let apiErrorCode = response.errorCode else {
            return DracoonApiCode.SERVER_UNKNOWN_ERROR
        }
        
        if (apiErrorCode == -90090) {
            return DracoonApiCode.SERVER_SMS_COULD_NOT_BE_SENT
        }
        return DracoonApiCode.SERVER_UNKNOWN_ERROR
    }
    
    private func parseGatewayTimeout(_ response: ModelErrorResponse, requestType: RequestType) -> DracoonApiCode {
        guard let apiErrorCode = response.errorCode else {
            return DracoonApiCode.SERVER_UNKNOWN_ERROR
        }
        
        if (apiErrorCode == -90027) {
            return DracoonApiCode.S3_CONNECTION_FAILED
        }
        return DracoonApiCode.SERVER_UNKNOWN_ERROR
    }
    
    private func parseInsufficientStorage(_ response: ModelErrorResponse, requestType: RequestType) -> DracoonApiCode {
        guard let apiErrorCode = response.errorCode else {
            return DracoonApiCode.SERVER_INSUFFICIENT_STORAGE
        }
        
        switch apiErrorCode {
        case -40200:
            return DracoonApiCode.SERVER_INSUFFICIENT_ROOM_QUOTA
        case -50504:
            return DracoonApiCode.SERVER_INSUFFICIENT_UL_SHARE_QUOTA
        case -90200:
            return DracoonApiCode.SERVER_INSUFFICIENT_CUSTOMER_QUOTA
        default:
            return DracoonApiCode.SERVER_INSUFFICIENT_STORAGE
        }
    }
    
    private func parseMalwareFound(_ response: ModelErrorResponse, requestType: RequestType) -> DracoonApiCode {
        return DracoonApiCode.SERVER_MALICIOUS_FILE_DETECTED
    }
}
