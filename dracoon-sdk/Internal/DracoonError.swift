//
//  DracoonError.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

public enum DracoonError: Error {
    case api(error: ModelErrorResponse?)
    case decode(error: Error)
    case nodes(error: Error)
    case shares(error: Error)
    case account(error: Error)
    
    case encrypted_share_no_password_provided
    
    case read_data_failure(at: URL)
    case node_path_invalid(path: String)
    case path_range_invalid
    case node_not_found(path: String)
    case file_does_not_exist(at: URL)
    
    case no_encryption_password
    case filekey_not_found
    case filekey_encryption_failure
    case encryption_cipher_failure
    case file_decryption_error(nodeId: Int64)
    case keypair_failure(description: String)
    case keypair_decryption_failure
    case keypair_does_not_exist
    
    case authorization_code_flow_in_progress(clientId: String, clientSecret: String, authorizationCode: String)
    case authorization_token_expired
    
    case connection_timeout
}

extension DracoonError {
    public var errorDescription: String? {
        switch self {
        case .api(let error):
            return error?.debugInfo ?? error?.message ?? error.debugDescription
        case .account(let error):
            return error.localizedDescription
        case .nodes(error: let error):
            return error.localizedDescription
        case .no_encryption_password:
            return "No encryption password set"
        case .filekey_not_found:
            return "File Key not found"
        case .filekey_encryption_failure:
            return "File Key could not be encrypted"
        case .encryption_cipher_failure:
            return "Encryption cipher could not be created"
        case .keypair_does_not_exist:
            return "User has no keypair"
        case .authorization_code_flow_in_progress(_, _, _):
            return "Code flow already in progress"
        case .authorization_token_expired:
            return "OAuth access token expired"
        case .encrypted_share_no_password_provided:
            return "No password provided for encrypted share"
        case .read_data_failure(let at):
            return "Failure at reading from \(at.path)"
        case .node_path_invalid(let path):
            return "Invalid node path \(path)"
        case .path_range_invalid:
            return "Invalid range path"
        case .node_not_found(let path):
            return "Node at \(path) not found"
        case .file_does_not_exist(let at):
            return "File at \(at) does not exist"
        case .file_decryption_error(let nodeId):
            return "Could not decrypt node with id \(nodeId)"
        case .keypair_decryption_failure:
            return "Could not decrypt key pair"
        default:
            return nil
        }
    }
}
