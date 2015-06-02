//
//  RMXAi.swift
//  AiScene
//
//  Created by Max Bilbow on 19/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import SceneKit
import Foundation

typealias AiBehaviour = (SCNNode!) -> Void

protocol RMXAiDelegate {
    var state: String? { get set }
    var behaviours: [String:() -> String?]? { get set }
    var sprite: RMXSprite { get }
    init(sprite: RMXSprite)
    func run(node: SCNNode!) -> Void
    func selectTarget() -> RMXSprite?
}


class AiPoppy : RMXAiDelegate {
    var state: String?
    var behaviours: [String:() -> String?]?
    var sprite: RMXSprite
    var itemToWatch: SCNNode?
    var speed:RMFloatB {
        return self.sprite.speed
    }
    //        poppy.world?.interface.collider.trackers.append(poppy.tracker)
    private var _count: Int = 0; private let _limit = 100

    var master: RMXSprite!
    
    convenience init(poppy: RMXSprite, master: RMXSprite){
        self.init(sprite: poppy)
        self.master = master
    }
    required init(sprite: RMXSprite) {
        self.sprite = sprite
//        self.speed = sprite.speed// 150 * (sprite.mass + 1)
//        sprite.setSpeed(speed: speed)
        self.master = sprite.world.activeSprite
    }
    
    func selectTarget() -> RMXSprite? {
        return RMXAi.randomSprite(self.sprite.world, type: .PLAYER_OR_AI)
    }
    
    func run(node: SCNNode!) -> Void {
        if self.master.hasItem && !self.master.isHolding(self.sprite) {
            self.sprite.releaseItem()
            itemToWatch = self.master.item!.node
            self.sprite.tracker.setTarget(target: itemToWatch?.sprite, doOnArrival: { (target: RMXSprite?) -> () in
                if self.master.isHolding(target) {
                    self.sprite.world.interface.av.playSound("pop1", info: self.sprite)
                    ++self._count
                    if self._count > self._limit {
                        if self.master.isActiveSprite {
                            do {
                                self.master = self.selectTarget()
                            } while self.master == self.sprite
                        } else {
                            self.master = self.sprite.world.activeSprite
                        }
                        self.sprite.tracker.setTarget(target: self.master)
                        self._count = 0
                    }
                } else {
                    self._count = 0
                    self.sprite.grab(target)
                    self.sprite.tracker.setTarget(target: self.master, doOnArrival: { (target: RMXSprite?) -> () in
                        self.sprite.world.interface.av.playSound("pop2", info: self.sprite.position)
                        self.sprite.releaseItem()
                        self.sprite.tracker.setTarget()
                        
                    })
                }
                
            })
        }
        if self.sprite.isLocked {
            self.master = self.sprite.world.activeSprite
        }

    }
}

class AiRandom: RMXAiDelegate {
    var state: String?
    var behaviours: [String:() -> String?]?
    var sprite: RMXSprite
    var world: RMSWorld {
        return self.sprite.world
    }
    required init(sprite: RMXSprite) {
        self.sprite = sprite
    }
    func run(node: SCNNode!) -> Void {
        if !self.world.aiOn { return }
        if !self.sprite.tracker.hasTarget && !self.sprite.hasItem { //after time to prevent grouing (ish)
            self.sprite.tracker.setTarget(target: RMXAi.randomSprite(self.world,type: .PASSIVE), willJump: true, afterTime: 100, doOnArrival: { (target: RMXSprite?) -> () in
                if self.sprite.grab(target) {
                    self.sprite.tracker.setTarget(target: self.selectTarget(), willJump: true, afterTime: 100, doOnArrival: { (target) -> () in
                        
                        self.sprite.throwItem(atSprite: target, withForce: 1)
                        //                            NSLog("node thrown at \(target?.name)")
                        self.sprite.tracker.setTarget()
                        //                            NSLog("target set to nil")
                    })
                }
                else {
                    //                        NSLog("Failed to grab \(target?.name)")
                }
            })
            
        }
        
    }
    func selectTarget() -> RMXSprite? {
        return RMXAi.randomSprite(world,type: .PLAYER_OR_AI)
    }
}

class AiTeamPlayer : AiRandom {
    
    override func selectTarget() -> RMXSprite? {
        return RMXAi.selectTargetPlayer(inWorld: self.world, notInTeam: self.sprite.attributes.teamID)
    }
    
}

class RMXAi {
//    static var autoStabilise: Bool = true
    class func autoStablise(sprite: RMXSprite) {
        let ai = { (node: SCNNode!) -> Void in
//            if sprite.world.aiOn { NSLog(sprite.name) }
            if sprite.world.hasGravity {
                sprite.physicsBody?.applyForce(sprite.world.gravity * sprite.mass, atPosition: sprite.bottom, impulse: false)
            }
        }
        sprite.addAi(ai)
        
        
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
    
    
    static func addRandomMovement(to players: [RMXSprite]) {
        for sprite in players {
            if sprite.attributes.teamID == 0 && sprite.type == .AI && !sprite.isUnique {
                sprite.aiDelegate = AiRandom(sprite: sprite)
            }
        }
        
    }

    
    
    
    static func offenciveBehaviour(to players: [RMXSprite]) {
        for sprite in players {
            if sprite.type == .AI && !sprite.isUnique && sprite.attributes.teamID > 0 {
                sprite.aiDelegate = AiTeamPlayer(sprite: sprite)
            }
        }
        
    }


}