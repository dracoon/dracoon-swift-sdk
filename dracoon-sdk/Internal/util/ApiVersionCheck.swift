//
//  ApiVersionCheck.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 07.07.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import Foundation

class ApiVersionCheck {
    
    public static let CryptoUpdateVersion = "4.24.0"
    
    public static func isRequiredServerVersion(requiredVersion: String, currentApiVersion: String) -> Bool {
        let serverComponents = currentApiVersion.components(separatedBy: ".")
        let requiredComponents = requiredVersion.components(separatedBy: ".")
        guard serverComponents.count >= 3, requiredComponents.count >= 3 else {
            return false
        }
        guard let major = Int(serverComponents[0]), let minor = Int(serverComponents[1]),
            let requiredMajor = Int(requiredComponents[0]), let requiredMinor = Int(requiredComponents[1]) else {
                return false
        }
        
        return major >= requiredMajor && minor >= requiredMinor
    }
}
