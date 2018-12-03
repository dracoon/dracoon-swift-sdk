//
//  DownloadCallback.swift
//  dracoon-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

public class DownloadCallback {
    
    public var onError:((Error) -> Void)?
    public var onCanceled:(() -> Void)?
    public var onProgress:((Float) -> Void)?
    public var onComplete:((URL) -> Void)?
    
    public init() {}
}
