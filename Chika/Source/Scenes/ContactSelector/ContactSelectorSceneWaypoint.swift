//
//  ContactSelectorSceneWaypoint.swift
//  Chika
//
//  Created Mounir Ybanez on 12/18/17.
//  Copyright © 2017 Nir. All rights reserved.
//

import UIKit

protocol ContactSelectorSceneEntryWaypoint {
    
    func withDelegate(_ aDelegate: ContactSelectorSceneDelegate?) -> AppEntryWaypoint
}

extension ContactSelectorScene {
    
    class EntryWaypoint: AppEntryWaypoint, ContactSelectorSceneEntryWaypoint {
        
        struct Factory {
            
            var scene: ContactSelectorSceneFactory
        }
        
        var factory: Factory
        weak var delegate: ContactSelectorSceneDelegate?
        
        init(factory: Factory) {
            self.factory = factory
        }
        
        convenience init() {
            let scene = ContactSelectorScene.Factory()
            let factory = Factory(scene: scene)
            self.init(factory: factory)
        }
        
        func enter(from parent: UIViewController) -> Bool {
            guard let nav = parent.navigationController else {
                return false
            }
            
            let scene = factory.scene.build(withDelegate: delegate)
            nav.pushViewController(scene, animated: true)
            delegate = nil
            
            return true
        }
        
        func withDelegate(_ aDelegate: ContactSelectorSceneDelegate?) -> AppEntryWaypoint {
            delegate = aDelegate
            return self
        }
    }
    
    class ExitWaypoint: AppExitWaypoint {
        
        weak var scene: UIViewController?
        
        func exit() -> Bool {
            guard let nav = scene?.navigationController, nav.topViewController == scene else {
                return false
            }
            
            nav.popViewController(animated: true)
            return true
        }
    }
}
