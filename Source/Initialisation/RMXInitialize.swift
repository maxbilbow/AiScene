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
    enum MoveState { case MOVING, TURNING, IDLE }
    static func addRandomMovement(to sprite: RMXSprite) {
        if let world = sprite.world {
            
            var timeLimit = self.randomTimeInterval
            var timePassed = 0
            let speed:RMFloatB = (RMFloatB(random() % 150) + 100) * sprite.mass
            var print = false //sprite.rmxID == 5
            var state: MoveState = .MOVING
            RMXLog("Adding AI to \(sprite.name), PRINT: \(print)")
            sprite.addBehaviour{ (isOn:Bool) -> () in
                if !isOn { if print { RMXLog("AI is OFF") }; return }
//                if !self.RANDOM_MOVEMENT { return }
                
                if print {  RMXLog("Start") }
                switch state {
                case .TURNING:
                    if print { RMXLog("Turning with force: \(speed)") }
                    if sprite.hasItem {
//                        sprite.turnToFace(world.activeSprite)
                        
                        sprite.throwItem(500)
                    }
                    sprite.lookAround(theta: speed / 10)
                    
                    
                /*
                    let rmxID = random() % RMXSprite.COUNT
                    if let target = world.childSpriteArray.get(rmxID) {
                        sprite.headTo(target, speed: speed, doOnArrival: { (sender, objects) -> AnyObject? in
                            sprite.grabItem(item: target)
                            return nil
                        })
                    } */
                    timePassed++
                    if timePassed > timeLimit {
                        state = .MOVING
                        timeLimit = self.randomTimeInterval
                    }
                case .MOVING:
                    if print { RMXLog("Moving with force: \(speed)") }
                    sprite.accelerateForward(speed)
                    timePassed++
                    if timePassed > timeLimit {
                        state = .TURNING
                        timeLimit = random() % 600 + 10
                    }
                    break
                default:
                    fatalError()
                }
            }
        } else {
            fatalError("Sprite came without world")
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
        let poppy: RMXSprite = RMXSprite.new(parent: world, type: .AI, isUnique: true).asShape(radius: 3, shape: .DOG).asPlayerOrAI()

        poppy.initPosition(startingPoint: RMXVector3Make(100,poppy.node.scale.y / 2,-50))
        var itemToWatch: RMXSprite! = nil
//        poppy.isAlwaysActive = true
        var timePassed = 0
        var state: PoppyState = .IDLE
        var speed: RMFloatB = 0.01
        let updateInterval = 1
        
        poppy.behaviours.append { (isOn: Bool) -> () in
            
            func idle(sender: RMXSprite, objects: [AnyObject]? = []) -> AnyObject? {
                sender.lookAround(theta: 1)
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
                }
                break
            case .READY_TO_CHASE:
                if !observer.hasItem {
                    state = .CHASING
                } else {
                    poppy.headTo(itemToWatch, speed: speed * 10, doOnArrival: getReady)
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
                    poppy.headTo(itemToWatch, speed: speed * 10, doOnArrival: fetch, objects: observer)
                }
                break
            case .FETCHING:
                if !poppy.hasItem  {
                    state = .IDLE
                } else {
                    poppy.headTo(observer, speed: speed * 10, doOnArrival: drop)
                }
                break
            default:
                if observer.hasItem {
                    state = .READY_TO_CHASE
                } else {
                    state = .IDLE
                    
                }
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


