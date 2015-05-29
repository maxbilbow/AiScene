//
//  RMXAi.swift
//  AiScene
//
//  Created by Max Bilbow on 19/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import SceneKit
import Foundation

typealias AiBehaviour = (RMXNode!) -> Void
class RMXAi {
//    static var autoStabilise: Bool = true
    class func autoStablise(sprite: RMXSprite) {
        let ai = { (node: RMXNode!) -> Void in
//            if sprite.world.aiOn { NSLog(sprite.name) }
            if sprite.world.hasGravity {
                sprite.physicsBody?.applyForce(sprite.world.gravity * sprite.mass, atPosition: sprite.bottom, impulse: false)
            }
        }
        sprite.addAi(ai)
        
        
    }

    class func playFetch(poppy: RMXSprite, var master: RMXSprite) {
        var itemToWatch: RMXNode?
        let speed:RMFloatB = 150 * (poppy.mass + 1)
        poppy.speed = speed
        //        poppy.world?.interface.collider.trackers.append(poppy.tracker)
        var count: Int = 0; let limit = 100
        let ai =  { (node: SCNNode!) -> Void in
            
            if master.hasItem && !master.isHolding(poppy) {
                poppy.releaseItem()
                itemToWatch = master.item!.node
                poppy.tracker.setTarget(target: itemToWatch?.sprite, doOnArrival: { (target: RMXSprite?) -> () in
                    if master.isHolding(target) {
                        poppy.world.interface.av.playSound("pop1", info: poppy)
                        ++count
                        if count > limit {
                            if master.isActiveSprite {
                                do {
                                    master = self.randomSprite(poppy.world, type: .PLAYER_OR_AI)!
                                } while master == poppy
                                //master.isActiveSprite ? self.randomSprite(poppy.world!, type: .PLAYER_OR_AI)! : poppy.world!.activeSprite!
                            } else {
                                master = poppy.world.activeSprite!
                            }
                            poppy.tracker.setTarget(target: master)
                            count = 0
                        }
                    } else {
                        count = 0
                        poppy.grab(item: target)
                        poppy.tracker.setTarget(target: master, doOnArrival: { (target: RMXSprite?) -> () in
                            poppy.world.interface.av.playSound("pop2", info: poppy.position)
                            poppy.releaseItem()
                            poppy.tracker.setTarget()
                            
                        })
                    }
                    
                })
            }
            if poppy.isHeld {
                master = poppy.world.activeSprite!
            }
        }
//        let action = SCNAction.runBlock(ai)
        
        poppy.addAi( ai )
    }
    
    
    static var randomTimeInterval: Int {
        return  random() % 600 + 100
    }
    
    static func randomSprite(world: RMSWorld, type: RMXSpriteType = .PASSIVE) -> RMXSprite? {
        var sprite: RMXSprite?
        switch type {
        case .AI, .PASSIVE:
            do {
                sprite =  RMX.spriteWith(ID: random() % RMXSprite.COUNT, inArray: world.children)
            } while sprite?.type != type
            return sprite
        case .PLAYER_OR_AI:
            do {
                sprite = RMX.spriteWith(ID: random() % RMXSprite.COUNT, inArray: world.children)
            } while sprite?.type != .AI && sprite?.type != .PLAYER
            return sprite
        default:
            return RMX.spriteWith(ID: random() % RMXSprite.COUNT, inArray: world.children)
        }
    }
    
    enum MoveState { case MOVING, TURNING, IDLE }
    
    
    static func addRandomMovement(to sprite: RMXSprite) {
        
        let speed:RMFloatB = (RMFloatB(random() % 50) + 50) * sprite.mass
        sprite.speed = speed
        let world = sprite.world
//            sprite.world?.interface.collider.trackers.append(sprite.tracker)
        let action = { (node: SCNNode!) -> Void in
            if !world.aiOn { return }
            if !sprite.tracker.hasTarget && !sprite.hasItem {
                sprite.tracker.setTarget(target: self.randomSprite(world, type: .PASSIVE), doOnArrival: { (target: RMXSprite?) -> () in
                    if target!.isHeld {
                        sprite.grab(item: target!.holder)
                    } else if target != nil && !target!.isUnique {
                        sprite.grab(item: target)
                    }
                    sprite.tracker.setTarget(target: world.activeSprite, afterTime: self.randomTimeInterval, doOnArrival: { (target) -> () in
                        
                        sprite.throwItem(strength: 200 , atNode: self.randomSprite(world,type: .PLAYER_OR_AI)?.node)
                        sprite.tracker.setTarget()
                    })
                })
            }
        }
        sprite.addAi(action)//{ (node: RMXNode!) -> Void in
//                sprite.node.runAction(action, forKey: "Random")
//            })
        
    }


}