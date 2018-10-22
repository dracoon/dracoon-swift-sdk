//
//  UploadCallback.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

public class UploadCallback {
    
    public var onStarted:((String) -> Void)?
    public var onError:((Error) -> Void)?
    public var onCanceled:(() -> Void)?
    public var onProgress:((Float) -> Void)?
    public var onComplete:((Node) -> Void)?
    
    public init() {}
}
