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
        poppy.setSpeed(speed: speed)
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
                                //master.isActiveSprite ? self.randomSprite(poppy.world!, type: .PLAYER_OR_AI)! : poppy.world!.activeSprite
                            } else {
                                master = poppy.world.activeSprite
                            }
                            poppy.tracker.setTarget(target: master)
                            count = 0
                        }
                    } else {
                        count = 0
                        poppy.grab(target)
                        poppy.tracker.setTarget(target: master, doOnArrival: { (target: RMXSprite?) -> () in
                            poppy.world.interface.av.playSound("pop2", info: poppy.position)
                            poppy.releaseItem()
                            poppy.tracker.setTarget()
                            
                        })
                    }
                    
                })
            }
            if poppy.isLocked {
                master = poppy.world.activeSprite
            }
        }
//        let action = SCNAction.runBlock(ai)
        
        poppy.addAi( ai )
    }
    
    
    static var randomTimeInterval: Int {
        return  random() % 600 + 100
    }
    

    static func selectTargetPlayer(inWorld world: RMSWorld, inTeam: Int = -1, notInTeam: Int = -1) -> RMXSprite? {
        
        if inTeam != -1 && inTeam == notInTeam { return nil }
        
        let players = world.liveTeamPlayers.filter({(player)-> Bool in
            return ( inTeam == -1 || player.attributes.teamID == inTeam ) && ( notInTeam == -1 || player.attributes.teamID != inTeam )
        })
        
//        NSLog("count: \(players.count)")
        if players.count > 0 {
            let n = random() % (players.count)
//            NSLog("no: \(n)")
            return players[n]
        } else {
//            NSLog("returning nil")
            return nil
        }
        
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
            return nil//RMX.spriteWith(ID: random() % RMXSprite.COUNT, inArray: world.children)
        }
    }
    
    enum MoveState { case MOVING, TURNING, IDLE }
    
    
    static func addRandomMovement(to sprite: RMXSprite) {
        if sprite.attributes.teamID < 0 || sprite.type != .AI || sprite.type == .PLAYER {
            return
        }
        let speed:RMFloatB = (RMFloatB(random() % 50) + 50) * sprite.mass
        sprite.setSpeed()//speed: speed)
        let world = sprite.world
//            sprite.world?.interface.collider.trackers.append(sprite.tracker)
        let action = { (node: SCNNode!) -> Void in
            if !world.aiOn { return }
            if !sprite.tracker.hasTarget && !sprite.hasItem {
                sprite.tracker.setTarget(target: self.randomSprite(world, type: .PASSIVE), willJump: true, doOnArrival: { (target: RMXSprite?) -> () in
                    if sprite.grab(target) {
                        sprite.tracker.setTarget(target: self.randomSprite(world,type: .PLAYER_OR_AI), afterTime: self.randomTimeInterval, doOnArrival: { (target) -> () in
                            
                            sprite.throwItem(atSprite: target )
                            sprite.tracker.setTarget()
                        })
                    }
                })
            }
        }
        sprite.addAi(action)//{ (node: RMXNode!) -> Void in
//                sprite.node.runAction(action, forKey: "Random")
//            })
        
    }

    
    static func offenciveBehaviour(to sprite: RMXSprite) {
        if sprite.attributes.teamID <= 0 || sprite.type == .PLAYER {
            return
        }
        let speed:RMFloatB = 50 * RMFloatB(sprite.mass)
        sprite.setSpeed(speed: speed)
        let world = sprite.world
        //            sprite.world?.interface.collider.trackers.append(sprite.tracker)
        let action = { (node: SCNNode!) -> Void in
            if !world.aiOn { return }
            if !sprite.tracker.hasTarget && !sprite.hasItem { //after time to prevent grouing (ish)
                sprite.tracker.setTarget(target: self.randomSprite(world,type: .PASSIVE), afterTime: 1800, doOnArrival: { (target: RMXSprite?) -> () in
                    if sprite.grab(target) {
                        sprite.tracker.setTarget(target: self.selectTargetPlayer(inWorld: world, notInTeam: sprite.attributes.teamID), afterTime: self.randomTimeInterval, doOnArrival: { (target) -> () in
                            
                            sprite.throwItem(atSprite: target, withForce: 1)
//                            NSLog("node thrown at \(target?.name)")
                            sprite.tracker.setTarget()
//                            NSLog("target set to nil")
                        })
                    }
                    else {
//                        NSLog("Failed to grab \(target?.name)")
                    }
                })
            }
        }
        sprite.addAi(action)//{ (node: RMXNode!) -> Void in
        //                sprite.node.runAction(action, forKey: "Random")
        //            })
        
    }


}