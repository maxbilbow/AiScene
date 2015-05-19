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
    static let RANDOM_MOVEMENT = true
    static var randomTimeInterval: Int {
        return  random() % 600 + 1
    }
    static func randomSprite(world: RMSWorld) -> RMXSprite? {
        return world.childSpriteArray.get(random() % RMXSprite.COUNT)
    }
    enum MoveState { case MOVING, TURNING, IDLE }
    static func addRandomMovement(to sprite: RMXSprite) {
        if let world = sprite.world {
            
            let timeLimit = self.randomTimeInterval
            var timePassed = 0
            let speed:RMFloatB = (RMFloatB(random() % 50) + 50) * sprite.mass
            var print = false //sprite.rmxID == 5
            var target: RMXSprite? = self.randomSprite(world)
            RMXLog("Adding AI to \(sprite.name), PRINT: \(print)")
            sprite.addBehaviour{ (isOn:Bool) -> () in
                if !isOn { if print { RMXLog("AI is OFF") }; return }
//                if !self.RANDOM_MOVEMENT { return }
                
                
                if let tgt = target {
                        sprite.headTo(tgt, speed: speed, doOnArrival: { (sender, objects) -> AnyObject? in
                            if !tgt.isUnique {
                                sprite.grabItem(item: tgt)
                                target = nil
                            } else {
                                RMXLog("Won't grab \(tgt.name)")
                            }
                            return nil
                        })
                } else {
//                    target = self.randomSprite(world)
                    sprite.headTo(world.activeSprite, speed: 50)
                }

                if timePassed > timeLimit {
//                    timeLimit = self.randomTimeInterval
                    if sprite.hasItem {
                        sprite.throwItem(500)
                        target = self.randomSprite(world)
                    }
                } else {
                    timePassed++
                }
            }
         }
    }
    

    static func buildScene(world: RMSWorld) -> RMSWorld{
        
//        let poppy = self.makePoppy(world: world)
//
        let observer = world.activeSprite
//        let actors = [ 0:observer, 1:poppy ]
        

            for child in world.children {
                let sprite = child
                if !sprite.isUnique && sprite.type == RMXSpriteType.AI {
                    addRandomMovement(to: child)
                }
            }
    
        return world
    }
    
    
    
    static func makePoppy(#world: RMSWorld) -> RMXSprite{
        let poppy: RMXSprite = RMXSprite.new(parent: world, node: RMXModels.getNode(shapeType: ShapeType.DOG.rawValue, mode: .AI, radius: 10), type: .AI, isUnique: true)

        poppy.setPosition(position: RMXVector3Make(100,10,-50))
        
        RMXAi.playFetch(poppy, master: world.activeSprite)
        RMXAi.autoStablise(poppy)
        
        poppy.setColor(GLKVector4Make(0.1,0.1,0.1,1.0))

       
        return poppy
    }
    

    
    #if OPENGL_OSX
    static func SetUpGLProxy(type: RMXWorldType) -> RMSWorld {
        RMXGLProxy.run(type)
        return RMXGLProxy.world
    }
    #endif
}


