//
//  GameView.swift
//  SceneCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import SceneKit
import AVFoundation

class GameView: SCNView  {
    
    var world: RMSWorld? {
        return self.interface?.world
    }
    
    var activeSprite: RMXSprite? {
        return self.world?.activeSprite
    }
    
    
    var interface: RMXInterface? {
        return self.gvc.interface
    }
    
    var gvc: GameViewController!
    
    
}
