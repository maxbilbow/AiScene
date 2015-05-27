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

    
    class func playFetch(poppy: RMXSprite, var master: RMXSprite) {
        var itemToWatch: RMXNode?
        let speed:RMFloatB = 150 * (poppy.mass + 1)
        poppy.speed = speed
//        poppy.world?.interface.collider.trackers.append(poppy.tracker)
        var count: Int = 0; let limit = 100
        
        poppy.behaviours.append { (isOn: Bool) -> () in
            if master.hasItem && !master.isHolding(poppy) {
                poppy.releaseItem()
                itemToWatch = master.item!.node
                poppy.tracker.setTarget(target: itemToWatch, doOnArrival: { (target: RMXNode?) -> () in
                    if master.isHolding(target) {
                        poppy.world?.interface.collider.sounds["pop1"]?.play()
                        ++count
                        if count > limit {
                            if master.isActiveSprite {
                                do {
                                   master = self.randomSprite(poppy.world!, type: .PLAYER_OR_AI)!
                                } while master == poppy
                               //master.isActiveSprite ? self.randomSprite(poppy.world!, type: .PLAYER_OR_AI)! : poppy.world!.activeSprite!
                            } else {
                                master = poppy.world!.activeSprite!
                            }
                            poppy.tracker.setTarget(target: master.node)
                            count = 0
                        }
                    } else {
                        count = 0
                        poppy.grab(node: target)
                        poppy.tracker.setTarget(target: master.node, doOnArrival: { (target: RMXNode?) -> () in
                            poppy.world?.interface.collider.sounds["pop2"]?.play()
                            poppy.releaseItem()
                            poppy.tracker.setTarget()
                            
                        })
                    }
                    
                })
            }
            if poppy.isHeld {
                master = poppy.world!.activeSprite!
            }
        }
    }
    
    
    static var randomTimeInterval: Int {
        return  random() % 600 + 100
    }
    
    static func randomSprite(world: RMSWorld, type: RMXSpriteType = .PASSIVE) -> RMXSprite? {
        var sprite: RMXSprite?
        switch type {
        case .AI, .PASSIVE:
            do {
                sprite = SpriteArray.get(random() % RMXSprite.COUNT, inArray: world.children)
            } while sprite?.type != type
            return sprite
        case .PLAYER_OR_AI:
            do {
                sprite = SpriteArray.get(random() % RMXSprite.COUNT, inArray: world.children)
            } while sprite?.type != .AI && sprite?.type != .PLAYER
            return sprite
        default:
            return SpriteArray.get(random() % RMXSprite.COUNT, inArray: world.children)
        }
    }
    
    enum MoveState { case MOVING, TURNING, IDLE }
    
    
    static func addRandomMovement(to sprite: RMXSprite) {
        let speed:RMFloatB = (RMFloatB(random() % 50) + 50) * sprite.mass
        sprite.speed = speed
        if let world = sprite.world {
//            sprite.world?.interface.collider.trackers.append(sprite.tracker)
            sprite.behaviours.append { (isOn: Bool) -> () in
                if !isOn { return }
                if !sprite.tracker.hasTarget && !sprite.hasItem {
                    sprite.tracker.setTarget(target: self.randomSprite(world, type: .PASSIVE)?.node, doOnArrival: { (target: RMXNode?) -> () in
                        if target!.isHeld {
                            sprite.grab(item: target!.holder)
                        } else if !(target!.sprite!.isUnique) {
                            sprite.grab(node: target)
                        }
                        sprite.tracker.setTarget(target: world.activeSprite?.node, afterTime: self.randomTimeInterval, doOnArrival: { (target) -> () in
                            sprite.throwItem(strength: 200 , atNode: target)
                            sprite.tracker.setTarget()
                        })
                    })
                }
            }
        }
    }


}