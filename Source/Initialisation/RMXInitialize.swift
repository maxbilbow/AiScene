//
//  RMXInitialize.swift
//  RattleGL
//
//  Created by Max Bilbow on 23/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit


extension RMX {
    

    static func buildScene(world: RMSWorld) -> RMSWorld{
        
//        let poppy = self.makePoppy(world: world)
//
        let observer = world.activeSprite
//        let actors = [ 0:observer, 1:poppy ]
        

            for child in world.children {
                let sprite = child
                if !sprite.isUnique && sprite.type == RMXSpriteType.AI {
                    RMXAi.addRandomMovement(to: child)
                }
            }
    
        return world
    }
    
    
    
    static func makePoppy(#world: RMSWorld) -> RMXSprite{
        let poppy: RMXSprite = RMXSprite.new(parent: world, node: RMXModels.getNode(shapeType: ShapeType.DOG.rawValue, mode: .AI, radius: 10), type: .AI, isUnique: true).asPlayerOrAI()
        
        poppy.setPosition(position: RMXVector3Make(100,10,-50))
        
        RMXAi.playFetch(poppy, master: world.activeSprite)
        RMXAi.autoStablise(poppy)
        
        poppy.setColor(GLKVector4Make(0.1,0.1,0.1,1.0))

       
        return poppy
    }
    

    
    enum KeyboardType { case French, UK }
    
    ///Adapt the keyboard for different layouts.
    static func setKeyboard(inteface: RMSKeys, type: KeyboardType = .UK) {
        switch type {
        case .French:
            inteface.set(action: RMXInterface.MOVE_FORWARD, characters: "z")
            inteface.set(action: RMXInterface.MOVE_LEFT, characters: "q")
            inteface.set(action: RMXInterface.MOVE_DOWN, characters: "a")
            inteface.set(action: RMXInterface.ROLL_LEFT, characters: "w")
            
            inteface.set(action: RMXInterface.NEXT_CAMERA, characters: "=")
            inteface.set(action: RMXInterface.PREV_CAMERA, characters: ":")
            
            inteface.set(action: RMXInterface.ZOOM_IN, characters: "-")
            inteface.set(action: RMXInterface.ZOOM_OUT, characters: ")")
            break
        default:
            break
        }
    }
}


