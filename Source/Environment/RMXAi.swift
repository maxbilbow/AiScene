//
//  RMXAi.swift
//  AiScene
//
//  Created by Max Bilbow on 19/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

typealias AiBehaviour = (Bool) -> ()
class RMXAi {
    static var autoStabilise: Bool = true
    class func autoStablise(sprite: RMXSprite) {
        let ai: AiBehaviour = { (isOn) -> () in
            if self.autoStabilise && sprite.world!.hasGravity {
                //var bottom = sprite.upVector * sprite.boundingBox.min.y * sprite.scale
//                bottom.y *= sprite.height
                var force = sprite.world!.gravity * sprite.mass
                if sprite.usesWorldCoordinates {
//                    force *= RMX.gravity * -1
                }
                sprite.physicsBody?.applyForce(force, atPosition: sprite.bottom, impulse: false)
            }
        }
        sprite.addBehaviour(ai)
    }
    
    class func isStuck(sprite: RMXSprite, target: RMXSprite?, lastPosition: RMXVector) -> Bool {
        if let target = target {
            return sprite.distanceTo(point: lastPosition) < 1 && sprite.distanceTo(target ?? sprite) >= target.radius + sprite.radius
        } else {
            return false
        }
    }
    
    class func playFetch(poppy: RMXSprite, master observer: RMXSprite) {
        var itemToWatch: RMXSprite! = nil
        var timePassed = 0
        var state: PoppyState = .IDLE
        let speed:RMFloatB = 150 * (poppy.mass + 1)
        let updateInterval = 1
        var lastPosition: RMXVector = poppy.position
//        var lastDistToTarget: RMFloatB = 0
        
        poppy.behaviours.append { (isOn: Bool) -> () in
            //            NSLog("State: \(state.rawValue) - Pos: \(poppy.position.print)")
            func idle(sender: RMXSprite, objects: [AnyObject]? = []) -> AnyObject? {
//                sender.lookAround(theta: speed / 10)
                //sender.accelerateForward(speed)
                return nil
            }

            
            
            
            
            func fetch(sender: RMXSprite, objects: [AnyObject]?) -> AnyObject? {
                //                sender.body.hasGravity = (objects?[0] as! RMXSprite).hasGravity
                return sender.grabItem(item: itemToWatch)
            }
            
            func drop(sender: RMXSprite, objects: [AnyObject]?) -> AnyObject?  {
                sender.releaseItem()
                sender.completeStop()
                return nil
            }
            
            func getReady(sender: RMXSprite, objects: [AnyObject]?)  -> AnyObject? {
                sender.completeStop()
                return nil
            }
            
            func doIfStuck() {
                if self.isStuck(poppy, target: itemToWatch ?? observer, lastPosition: lastPosition) {
                    poppy.jump()
                } else {
                    lastPosition = poppy.position
//                    lastDistToTarget = poppy.distanceTo(itemToWatch ?? observer)
                }
            }
            
            switch (state) {
            case .IDLE:
                if let item = observer.item {
                    if item != poppy {
                        itemToWatch = item
                        state = .READY_TO_CHASE
                    }
                } else {
                    idle(poppy)
                    RMXLog("Idle: \(state.rawValue), pos: \(poppy.position.print)")
                }
                break
            case .READY_TO_CHASE:
                if !observer.hasItem {
                    state = .CHASING
                } else {
                    RMXLog("Ready to Chase: \(state.rawValue),  pos: \(poppy.position.print)")
                    poppy.headTo(itemToWatch, speed: speed, doOnArrival: getReady)
                    doIfStuck()
                }
                break
            case .CHASING:
                if  observer.hasItem {
                    itemToWatch = nil
                    state = .IDLE
                } else if poppy.hasItem {
                    itemToWatch = nil
                    state = .FETCHING
                } else {
                    RMXLog("Chasing: \(state.rawValue),  pos: \(poppy.position.print)")
                    poppy.headTo(itemToWatch, speed: speed, doOnArrival: fetch, objects: observer)
                    doIfStuck()
                }
                break
            case .FETCHING:
                if !poppy.hasItem || observer.hasItem {
                    state = .IDLE
                }  else {
                    poppy.headTo(observer, speed: speed, doOnArrival: drop)
                    RMXLog("Fetching: \(state.rawValue),  pos: \(poppy.position.print)")
                    doIfStuck()
                }
                break
            default:
                    state = .IDLE
                fatalError("no state set")
            }
        }
    
    }

    
    static let RANDOM_MOVEMENT = true
    
    static var randomTimeInterval: Int {
        return  random() % 600 + 300
    }
    static func randomSprite(world: RMSWorld, type: RMXSpriteType = .PASSIVE) -> RMXSprite? {
        return world.childSpriteArray.get(random() % RMXSprite.COUNT)
    }
    
    enum MoveState { case MOVING, TURNING, IDLE }
    
    static func addRandomMovement(to sprite: RMXSprite) {
        if let world = sprite.world {
            var target: RMXSprite? = self.randomSprite(world)
            var lastPosition: RMXVector = sprite.position
            var distToTarget: RMFloatB = 0
            
//            var isStuck: Bool {
//                return sprite.distanceTo(point: lastPosition) < 1 && sprite.distanceTo(target ?? sprite) >= distToTarget
//            }

            let timeLimit = self.randomTimeInterval
            var timePassed = 0
            let speed:RMFloatB = (RMFloatB(random() % 50) + 50) * sprite.mass
            var print = false //sprite.rmxID == 5

            
            
            var chasingAction: () -> (AnyObject?) =  {
                if let t = target {
                    if !t.isUnique {//.type != RMXSpriteType.BACKGROUND {
                        sprite.grabItem(item: t)
                        target = nil
                        timePassed = -timeLimit
                    } else {
                        RMXLog("Won't grab \(t.name)")
                        target = self.randomSprite(world)
                    }
                }
                return nil
            }
            
            var throwingAction: () -> AnyObject? = {
                if let item = sprite.item {
                    sprite.throwItem(strength: 80, atNode: item.node)
                    target = self.randomSprite(world)
                }
                return nil
            }
            
            RMXLog("Adding AI to \(sprite.name), PRINT: \(print)")
            sprite.addBehaviour{ (isOn:Bool) -> () in
                if !isOn { if print { RMXLog("AI is OFF") }; return }
                //                if !self.RANDOM_MOVEMENT { return }
                
                
                
                if let tgt = target {
                    if self.isStuck(sprite, target: target, lastPosition: lastPosition) {
                        sprite.jump()
                    }
                    
                    sprite.headTo(tgt, speed: speed, doOnArrival: { (sender, objects) -> AnyObject? in
                        return chasingAction()
                    })
                } else if let itemInHand = sprite.item {
                    //                    target = self.randomSprite(world)
                    sprite.headTo(world.activeSprite!, speed: speed, doOnArrival: { (sender, objects) -> AnyObject? in
                        return throwingAction()
                    })

                } else {
                    target = self.randomSprite(world)
                }
                
                if timePassed > timeLimit {
                    //                    timeLimit = self.randomTimeInterval
                    lastPosition = sprite.position
                    distToTarget = target != nil ? sprite.distanceTo(target!) : 0
                    if sprite.hasItem {
                        throwingAction()
                    }
                } else {
                    timePassed++
                }
            }
        }
    }

}