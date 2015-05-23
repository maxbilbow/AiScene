//
//  GameView.swift
//  SceneCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import SceneKit

class GameView: SCNView  {
    
    var world: RMSWorld? {
        return self.interface?.world
    }
    
    var activeSprite: RMXSprite? {
        return self.world!.activeSprite
    }
    
    
    var interface: RMXInterface?
    var gvc: GameViewController?
    
    func initialize(gvc: GameViewController, interface: RMXInterface){
        self.gvc = gvc
        self.interface = interface
        self.delegate = self.interface
    
        AiCubo.setUpWorld(self.interface, type: .TEST)
    }
    
        
      
    func setWorld(type: RMXWorldType){
        if self.world!.type != type {
            self.world!.setWorldType(worldType: type)
        }
    }
    
    
    
    

    
}
