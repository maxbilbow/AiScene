//
//  GameView.swift
//  SceneCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import SceneKit
import Foundation

class GameView: SCNView  {
    
    @available(OSX 10.10, *)
    var world: RMSWorld? {
        return self.interface?.world
    }
    
    @available(OSX 10.10, *)
    var activeSprite: RMXSprite? {
        return self.world?.activeSprite
    }
    
    @available(OSX 10.10, *)
    var interface: RMXInterface? {
        return (self.gvc as? GameViewController)?.interface
    }
    
    var gvc: ViewController!
    
    
}
