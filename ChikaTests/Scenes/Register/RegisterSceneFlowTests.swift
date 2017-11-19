//
//  RegisterSceneFlowTests.swift
//  ChikaTests
//
//  Created by Mounir Ybanez on 11/18/17.
//  Copyright © 2017 Nir. All rights reserved.
//

import XCTest
@testable import Chika

class RegisterSceneFlowTests: XCTestCase {
    
    // CONTEXT: Constructor should instantiate homeSceneFlow
    // property with default class HomeScene.Flow
    func testInitA() {
        let flow = RegisterScene.Flow()
        XCTAssertTrue(flow.waypoint.homeScene is HomeScene.EntryWaypoint)
    }
    
    // CONTEXT: showError function should show an alert
    // controller coming from the error parameter
    func testShowErrorA() {
        let scene = UIViewController()
        let flow = RegisterScene.Flow()
        let window = UIWindow(frame: UIScreen.main.bounds)
        let error = AppError("Flow error")
        
        window.rootViewController = scene
        window.makeKeyAndVisible()
        flow.scene = scene
        flow.showError(error)
        
        XCTAssertTrue(scene.presentedViewController is UIAlertController)
        let alert = scene.presentedViewController as! UIAlertController
        XCTAssertEqual(alert.title, "Error")
        XCTAssertEqual(alert.message, "\(error)")
    }
    
    // CONTEXT: goToHome function should return false given
    // that scene is nil
    func testGoToHomeA() {
        let flow = RegisterScene.Flow()
        flow.scene = nil
        let ok = flow.goToHome()
        XCTAssertFalse(ok)
    }
    
    // CONTEXT: goToHome function should return true given that
    // the waypoint.homeScene.enter returns true and the
    // scene should be dismissed given that it is presented
    func testGoToHomeB() {
        let entry = EntryWaypointMock()
        let waypoint = RegisterScene.Flow.Waypoint(homeScene: entry)
        let flow = RegisterScene.Flow(waypoint: waypoint)
        let scene = RegisterSceneMock()
        flow.scene = scene
        scene.isPresented = true
        entry.isEnterOK = true
        let ok = flow.goToHome()
        XCTAssertTrue(ok)
        XCTAssertFalse(scene.isBeingPresented)
    }
    
    // CONTEXT: goToHome function should return true given that
    // the waypoint.homeScene.enter returns true and the scene
    // is not being presented
    func testGoToHomeC() {
        let entry = EntryWaypointMock()
        let waypoint = RegisterScene.Flow.Waypoint(homeScene: entry)
        let flow = RegisterScene.Flow(waypoint: waypoint)
        let scene = RegisterSceneMock()
        flow.scene = scene
        scene.isPresented = false
        entry.isEnterOK = true
        let ok = flow.goToHome()
        XCTAssertTrue(ok)
    }
}