//
//  CryptoError.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public enum CryptoError: Error {
    case generate(String)
    case encrypt(String)
    case decrypt(String)
}
extension CryptoError: Equatable {
    public static func == (lhs: CryptoError, rhs: CryptoError) -> Bool {
        switch (lhs, rhs) {
        case (.generate, .generate):
            return lhs.localizedDescription == rhs.localizedDescription
        case (.encrypt, .encrypt):
            return lhs.localizedDescription == rhs.localizedDescription
        case (.decrypt, .decrypt):
            return lhs.localizedDescription == rhs.localizedDescription
        default:
            return false;
        }
    }
}
