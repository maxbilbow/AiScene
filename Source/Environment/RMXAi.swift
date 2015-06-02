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
typealias AiCollisionBehaviour = (SCNPhysicsContact) -> Void
struct InWhichTeams {
    var inc, exc: [Int]
    init(inc: Int? = nil, exc: Int? = nil){
        if let i = inc {
            self.inc = [ i ]
        } else {
            self.inc = []
        }
        if let e = exc {
            self.exc = [ e ]
        } else {
            self.exc = []
        }
    }
}

protocol RMXAiDelegate : NSObjectProtocol {
    var state: String? { get set }
    var args: [Any]? { get }
    var behaviours: [String:() -> String?]? { get set }
    var sprite: RMXSprite { get }
    init(sprite: RMXSprite)
    func run(node: SCNNode!) -> Void
    func getTarget(args: Any? ...) -> RMXSprite?
}


class AiPoppy : NSObject, RMXAiDelegate {
    var state: String?
    var args: [Any]? {
        return nil
    }
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
        super.init()
    }
    
    func getTarget(args: Any? ...) -> RMXSprite? {
        return RMXAi.randomSprite(self.sprite.world, type: .PLAYER_OR_AI)
    }
    
    func run(node: SCNNode!) -> Void {
        if self.master.hasItem && !self.master.isHolding(self.sprite) {
            self.sprite.releaseItem()
            self.itemToWatch = self.master.item?.node
            self.sprite.tracker.setTarget(itemToWatch?.sprite, doOnArrival: { (target: RMXSprite?) -> () in
                if self.master.isHolding(target) {
                    self.sprite.world.interface.av.playSound("pop1", info: self.sprite)
                    ++self._count
                    if self._count > self._limit {
                        if self.master.isActiveSprite {
                            do {
                                self.master = self.getTarget()
                            } while self.master == self.sprite
                        } else {
                            self.master = self.sprite.world.activeSprite
                        }
                        self.sprite.tracker.setTarget(self.master)
                        self._count = 0
                    }
                } else {
                    self._count = 0
                    self.sprite.grab(target)
                    self.sprite.tracker.setTarget(self.master, doOnArrival: { (target: RMXSprite?) -> () in
                        self.sprite.world.interface.av.playSound("pop2", info: self.sprite.position)
                        self.sprite.releaseItem()
                        self.sprite.tracker.removeTarget()
                        
                    })
                }
                
            })
        }
        if self.sprite.isLocked {
            self.master = self.sprite.world.activeSprite
        }

    }
}

class AiRandom: NSObject, RMXAiDelegate {
    var state: String?
    var args: [Any]? {
        return [ RMXSpriteType.PLAYER_OR_AI ]
    }
    
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
        if !self.sprite.tracker.hasTarget && !self.sprite.hasItem { //after time to prevent grabbing (ish)
            self.sprite.tracker.setTarget(self.getTarget(RMXSpriteType.PASSIVE), willJump: true, afterTime: 100, doOnArrival: { (target: RMXSprite?) -> () in
                if self.sprite.grab(target) {
                    self.sprite.tracker.setTarget(self.getTarget(self.args), willJump: true, afterTime: 100, doOnArrival: { (target) -> () in
                        
                        self.sprite.throwItem(atSprite: target, withForce: 1)
                        //                            NSLog("node thrown at \(target?.name)")
                        self.sprite.tracker.removeTarget()
                        //                            NSLog("target set to nil")
                    })
                }
                else {
                    //                        NSLog("Failed to grab \(target?.name)")
                }
            })
            
        }
        
    }
    
    func getTarget(args: Any? ...) -> RMXSprite? {
        for arg in args {
            if let condition = arg as? InWhichTeams {
                let players = self.world.liveTeamPlayers.filter({(player)-> Bool in
                    for teamID in condition.inc {
                        if teamID == player.attributes.teamID {
                            return true
                        }
                    }
                    for teamID in condition.exc {
                        if teamID == player.attributes.teamID {
                            return false
                        }
                    }
                    return true
                })
                if players.count > 0 {
                    let n = random() % (players.count)
                    return players[n]
                } else {
                    return self.getTarget(RMXSpriteType.BACKGROUND)
                }
            } else if let condition = arg as? RMXSpriteType {
                return RMXAi.randomSprite(self.world,type: condition)
            }
        }
        
        return RMXAi.randomSprite(world,type: .PLAYER_OR_AI)
    }
}

class AiTeamPlayer : AiRandom {
    var inWhichTeams: InWhichTeams!
    required init(sprite: RMXSprite) {
        super.init(sprite: sprite)
        self.inWhichTeams = InWhichTeams(exc: self.sprite.attributes.teamID)
        self.sprite.timer.timers.append(NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkTeam", userInfo: nil, repeats: true))
    }
    
    func checkTeam(){
        self.inWhichTeams.exc[0] = self.sprite.attributes.teamID
        if self.sprite.attributes.isTeamCaptain {
//            NSLog("I am \(self.sprite.name) on team \(self.sprite.attributes.teamID)")
        }
    }
    override var args: [Any]? {
        return [ self.inWhichTeams ]
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