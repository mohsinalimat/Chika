//
//  RegisterSceneFlow.swift
//  Chika
//
//  Created by Mounir Ybanez on 11/18/17.
//  Copyright © 2017 Nir. All rights reserved.
//

import UIKit

protocol RegisterSceneFlow: class {
    
    func goToHome() -> Bool
    func showError(_ error: Error)
}

extension RegisterScene {
    
    class Flow: RegisterSceneFlow {
        
        struct Waypoint {
            
            var home: AppRootWaypoint
        }
        
        weak var scene: UIViewController?
        var waypoint: Waypoint
        
        init(waypoint: Waypoint) {
            self.waypoint = waypoint
        }
        
        convenience init() {
            let home = HomeScene.RootWaypoint()
            let waypoint = Waypoint(home: home)
            self.init(waypoint: waypoint)
        }
        
        func goToHome() -> Bool {
            guard let scene = scene else {
                return false
            }
            
            return waypoint.home.makeRoot(from: scene.view.window)
        }
        
        func showError(_ error: Error) {
            let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            scene?.present(alert, animated: true, completion: nil)
        }
    }
}
