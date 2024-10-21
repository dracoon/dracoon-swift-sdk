//
//  TestState.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 21.10.24.
//  Copyright © 2024 Dracoon. All rights reserved.
//

class TestState: @unchecked Sendable {
    
    private var _onValueCalled: Bool = false
    private var _onErrorCalled: Bool = false
    
    var onValueCalled: Bool {
        get {
            return _onValueCalled
        }
        set {
            _onValueCalled = newValue
        }
    }
    
    var onErrorCalled: Bool {
        get {
            return _onErrorCalled
        }
        set {
            _onErrorCalled = newValue
        }
    }
    
}
