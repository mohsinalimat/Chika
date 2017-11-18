//
//  RegisterSceneFlowMock.swift
//  ChikaTests
//
//  Created by Mounir Ybanez on 11/18/17.
//  Copyright © 2017 Nir. All rights reserved.
//

import XCTest
@testable import Chika

class RegisterSceneFlowMock: RegisterSceneFlow {

    class Callback {
        
        var goToHome: (() -> Void)?
        var showError: ((Error) -> Void)?
    }
    
    var callback: Callback
    
    init() {
        self.callback = Callback()
    }
    
    func goToHome() -> Bool {
        callback.goToHome?()
        return true
    }
    
    func showError(_ error: Error) {
        callback.showError?(error)
    }
}
