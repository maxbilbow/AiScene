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
        let poppy: RMXSprite = RMXSprite.new(parent: world, type: .AI, isUnique: true).asShape(radius: 3, shape: .DOG)//.asPlayerOrAI()

        poppy.setPosition(position: RMXVector3Make(100,RMSWorld.RADIUS,-50))
        
        var itemToWatch: RMXSprite! = nil
        var timePassed = 0
        var state: PoppyState = .IDLE
        let speed:RMFloatB = 1800 * poppy.mass
        let updateInterval = 1
        
        poppy.behaviours.append { (isOn: Bool) -> () in
//            NSLog("State: \(state.rawValue) - Pos: \(poppy.position.print)")
            func idle(sender: RMXSprite, objects: [AnyObject]? = []) -> AnyObject? {
                sender.lookAround(theta: speed / 10)
                sender.accelerateForward(speed)
                return nil
            }
            
            func fetch(sender: RMXSprite, objects: [AnyObject]?) -> AnyObject? {
                //                sender.body.hasGravity = (objects?[0] as! RMXSprite).hasGravity
                return sender.grabItem(item: itemToWatch)
            }
            
            func drop(sender: RMXSprite, objects: [AnyObject]?) -> AnyObject?  {
                sender.releaseItem()
                return nil
            }
            
            func getReady(sender: RMXSprite, objects: [AnyObject]?)  -> AnyObject? {
                sender.completeStop()
                return nil
            }
            
            let observer = world.observer
            switch (state) {
            case .IDLE:
                if observer.hasItem {
                    itemToWatch = observer.item
                    state = .READY_TO_CHASE
                } else {
                    idle(poppy)
                    RMXLog("Idle: \(state.rawValue), velocity: \(poppy.velocity.print)")
                }
                break
            case .READY_TO_CHASE:
                if !observer.hasItem {
                    state = .CHASING
                } else {
                    RMXLog("Ready to Chase: \(state.rawValue), velocity: \(poppy.velocity.print)")
                    poppy.headTo(itemToWatch, speed: speed, doOnArrival: getReady)
                }
                break
            case .CHASING:
                if  observer.hasItem {
                    itemToWatch = observer.item
                    state = .READY_TO_CHASE
                } else if poppy.hasItem {
                    itemToWatch = nil
                    state = .FETCHING
                } else {
                    RMXLog("Chasing: \(state.rawValue), velocity: \(poppy.velocity.print)")
                    poppy.headTo(itemToWatch, speed: speed, doOnArrival: fetch, objects: observer)
                }
                break
            case .FETCHING:
                if !poppy.hasItem  {
                    state = .IDLE
                } else {
                    poppy.headTo(observer, speed: speed, doOnArrival: drop)
                    RMXLog("Fetching: \(state.rawValue), velocity: \(poppy.velocity.print)")
                }
                break
            default:
                if observer.hasItem {
                    state = .READY_TO_CHASE
                } else {
                    state = .IDLE
                    
                }
                fatalError("no state set")
            }
        }
        poppy.setColor(GLKVector4Make(0.1,0.1,0.1,1.0))
        /*
        #if SceneKit
            let r: RMFloatB = 0.3
            #else
            let r = poppy.radius / 2
            #endif
        let head = RMXSprite.new(parent: poppy).asShape(scale: RMXVector3Make(r,r,r),shape: .SPHERE)
        head.setRadius(r)
        head.setColor(RMXVector4Make(0.1,0.1,0.1,0.1))
        head.startingPoint = RMXVector3Make(0,head.node.scale.y, -head.node.scale.z)
        head.node.position = head.startingPoint!
        poppy.insertChild(head) */
        
       
        return poppy
    }
    

    
    #if OPENGL_OSX
    static func SetUpGLProxy(type: RMXWorldType) -> RMSWorld {
        RMXGLProxy.run(type)
        return RMXGLProxy.world
    }
    #endif
}


