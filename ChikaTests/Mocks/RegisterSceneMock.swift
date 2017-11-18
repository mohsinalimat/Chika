//
//  RegisterSceneMock.swift
//  ChikaTests
//
//  Created by Mounir Ybanez on 11/18/17.
//  Copyright © 2017 Nir. All rights reserved.
//

@testable import Chika

class RegisterSceneMock: RegisterScene {

    var isPresented: Bool = false
    
    override var isBeingPresented: Bool {
        return isPresented
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        isPresented = false
        return
    }
}
