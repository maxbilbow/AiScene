//
//  RMXScene.swift
//  AiScene
//
//  Created by Max Bilbow on 18/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation


#if SceneKit
    import SceneKit
    typealias RMXScene = SCNScene
#elseif SpriteKit
    import SpriteKit
    typealias RMXScene = SKScene
#endif


extension RMSWorld {
    
    class func DefaultScene() -> RMXScene {
        #if SceneKit
        return RMXScene(named: "art.scnassets/ship.dae")!
        #elseif SpriteKit
        return RMXScene(fileNamed:"Spaceship")
        #endif
    }
    
    
}