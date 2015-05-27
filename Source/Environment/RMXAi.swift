//
//  RMXAi.swift
//  AiScene
//
//  Created by Max Bilbow on 19/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import SceneKit
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
    
    class func playFetch(poppy: RMXSprite, master: RMXSprite) {
        var itemToWatch: RMXNode?
        let speed:RMFloatB = 150 * (poppy.mass + 1)
        poppy.speed = speed
        poppy.world?.interface.collider.trackers.append(poppy.tracker)
        
        let READY_TO_CHASE = "ready"; let CHASING = "chasing"; let BRINGING_IT_BACK = "fetching"
        poppy.behaviours.append { (isOn: Bool) -> () in
            if master.hasItem && !master.isHolding(poppy) {
                poppy.releaseItem()
                poppy.tracker.state = READY_TO_CHASE
                itemToWatch = master.item!.node
                poppy.tracker.setTarget(target: itemToWatch, doOnArrival: { (target: RMXNode?) -> () in
                    if master.isHolding(target) {
                        poppy.world?.interface.collider.sounds["pop1"]?.play()
//                            poppy.tracker.pauseFor(10)
                    } else {
                        poppy.grab(node: target)
                        poppy.tracker.setTarget(target: master.node, doOnArrival: { (target: RMXNode?) -> () in
                            poppy.world?.interface.collider.sounds["pop2"]?.play()
                            poppy.releaseItem()
                            poppy.tracker.state = RMXTracker.IDLE
                            poppy.tracker.setTarget()
                            
                        })
                    }
                    
                })
            }
        }
    }
    

    
    

    
    static let RANDOM_MOVEMENT = true
    
    static var randomTimeInterval: Int {
        return  random() % 600 + 300
    }
    static func randomSprite(world: RMSWorld, type: RMXSpriteType = .PASSIVE) -> RMXSprite? {
        return SpriteArray.get(random() % RMXSprite.COUNT, inArray: world.children)
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
                        sprite.grab(item: t)
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