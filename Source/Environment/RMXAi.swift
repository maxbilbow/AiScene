//
//  RMXAi.swift
//  AiScene
//
//  Created by Max Bilbow on 19/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import SceneKit
import Foundation




@available(OSX 10.10, *)
class AiPoppy : RMXAi {
   
    var itemToWatch: SCNNode?
    var speed:RMFloat {
        return self.sprite.speed
    }
    
    override var args: [RMXSpriteType] {
        return [RMXSpriteType.PLAYER, RMXSpriteType.AI]
    }
    //        poppy.world?.interface.collider.trackers.append(poppy.tracker)
    private var _count: Int = 0; private let _limit = 100

    var master: RMXSprite!
    
    convenience init(poppy: RMXSprite, master: RMXSprite){
        self.init(sprite: poppy)
        self.master = master
    }
    required init(sprite: RMXSprite) {
        self.master = sprite.world.activeSprite
        super.init(sprite: sprite)
    }
    
    
    
    override func run(sender: AnyObject?, updateAtTime time: NSTimeInterval) -> Void {
        super.run(sender, updateAtTime: time)
        if self.master.hasItem && !self.master.isHolding(self.sprite) {
            self.sprite.releaseItem()
            self.itemToWatch = self.master.item?.node
            self.sprite.tracker.setTarget(itemToWatch?.sprite, doOnArrival: { (target: RMXSprite?) -> () in
                if self.master.isHolding(target) {
                    self.sprite.world.interface.av.playSound("pop1", info: self.sprite)
                    ++self._count
                    if self._count > self._limit {
                        if self.master.isActiveSprite {
                            repeat {
                                self.master = self.getTarget()
                            } while self.master == self.sprite
                        } else {
                            self.master = self.sprite.world.activeSprite
                        }
                        self.sprite.tracker.setTarget(self.master, ignoreClaims: true)
                        self._count = 0
                    }
                } else {
                    self._count = 0
                    self.sprite.grab(target)
                    self.sprite.tracker.setTarget(self.master, ignoreClaims: true, doOnArrival: { (target: RMXSprite?) -> () in
                        self.sprite.world.interface.av.playSound("pop2", info: self.sprite.node)
                        self.sprite.releaseItem()
                        
                    })
                }
                
            })
        }
        if self.sprite.isLocked {
            self.master = self.sprite.world.activeSprite
        }

    }
}

@available(OSX 10.10, *)
class AiRandom: RMXAi {
    override var state: String? {
        return super.state
    }
    
    override var args: [RMXSpriteType] {
        return [ RMXSpriteType.PLAYER, RMXSpriteType.AI ]
    }

    override func run(sender: AnyObject?, updateAtTime time: NSTimeInterval) -> Void {
        super.run(sender, updateAtTime: time)
        if !self.world.aiOn { return }
        if self.sprite.hasItem && !self.sprite.tracker.hasTarget {
            self.sprite.tracker.setTarget(self.getTarget(), ignoreClaims: false, willJump: true, afterTime: 100, doOnArrival: { (target) -> () in
                if !self.sprite.throwItem(atObject: target, withForce: 1, tracking: true) {
                    self.sprite.throwItem(atObject: target, withForce: 1, tracking: false)
                }
            })
        }
        if !self.sprite.hasItem && !self.sprite.tracker.hasTarget { //after time to prevent grabbing (ish)
            let target = self.getTarget(RMXSpriteType.PASSIVE)
            self.sprite.tracker.setTarget(target, willJump: true, afterTime: 100, doOnArrival: { (target: RMXSprite?) -> () in
                if self.sprite.grab(target) {
                    self.sprite.tracker.setTarget(self.getTarget(), ignoreClaims: false, willJump: true, afterTime: 100, doOnArrival: { (target) -> () in
                        if !self.sprite.throwItem(atObject: target, withForce: 1, tracking: true) {
                            self.sprite.throwItem(atObject: target, withForce: 1, tracking: false)
                        }
                    })
                }
            })
            
        }
        
    }
    
    

}

@available(OSX 10.10, *)
class AiTeamPlayer : AiRandom {
    
    struct InWhichTeams {
        var inc, exc: [String]
        init(inc: String? = nil, exc: String? = nil){
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

    
    var inWhichTeams: InWhichTeams!
    required init(sprite: RMXSprite) {
        super.init(sprite: sprite)
        self.inWhichTeams = InWhichTeams(exc: self.sprite.attributes.teamID)
        sprite.attributes.addObserver(self, forKeyPath: "teamID", options: NSKeyValueObservingOptions.New, context: UnsafeMutablePointer<Void>())
        sprite.attributes.addObserver(self, forKeyPath: "isAlive", options: NSKeyValueObservingOptions.New, context: UnsafeMutablePointer<Void>())
//        self.sprite.timer.addTimer(interval: 1, target: self, selector: "checkTeam", repeats: true)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let keyPath = keyPath {
            switch keyPath {
            case "teamID":
                RMLog("\(self.sprite.name!)'s team did change from \(self.inWhichTeams.exc[0]) to \((object as! SpriteAttributes).teamID)", id: "Observers")
                self.inWhichTeams.exc[0] = self.sprite.attributes.teamID
                break
            case "isAlive":
                if (object as? SpriteAttributes)!.isAlive ?? false {
                    RMLog("\(self.sprite.name!) was revived!", id: "Observers")
                } else {
                    self.sprite.timer.addTimer(5, target: self.sprite.attributes, selector: "deRetire", repeats: false)
                    RMLog("\(self.sprite.name!) died!", id: "Observers")
                }
                break
            default:
                RMLog("KeyPath: \(self.sprite.attributes.teamID) not recognised")
                break
            }
        }
    }
    
    func checkTeam(){
        
        if self.sprite.attributes.isTeamCaptain {
//            NSLog("I am \(self.sprite.name) on team \(self.sprite.attributes.teamID)")
        }
    }
    
    override func run(sender: AnyObject?, updateAtTime time: NSTimeInterval) {
        if self.sprite.attributes.isAlive {
            super.run(sender, updateAtTime: time)
        }
    }

    
    internal func getTargetPlayer(args: InWhichTeams...) -> RMXSprite? {
        for condition in args {
            let players = self.world.liveTeamPlayers.filter({(player)-> Bool in
                for teamID in condition.exc { //exclude team if...
                    if teamID == player.attributes.teamID || player == self.sprite {
                        return false
                    }
                }
                
                for teamID in condition.inc { //include team if...
                    if teamID == player.attributes.teamID {
                        return true
                    }
                }
                return true
            })
    
            if players.count > 0 {
                let n = random() % (players.count)
                return players[n]
                }
            
        }
        return nil
    }
    
}



@available(OSX 10.10, *)
extension RMXAi {
//    static var autoStabilise: Bool = true
    class func autoStablise(sprite: RMXSprite) {
        let ai = { (node: SCNNode!) -> Void in
//            if sprite.world.aiOn { NSLog(sprite.name) }
            if sprite.world.hasGravity {
                sprite.physicsBody?.applyForce(sprite.world.gravity * sprite.mass, atPosition: sprite.bottom, impulse: false)
            }
        }
        sprite.addBehaviour(ai)
        
        
    }

    
    @available(*,deprecated=0)
    static var randomTimeInterval: Int {
        return  random() % 600 + 100
    }
    

    class func selectTargetPlayer(inWorld world: RMSWorld, inTeam: String = RMXSprite.TEAMLESS_MAVERICS, notInTeam: String = RMXSprite.TEAMLESS_MAVERICS) -> RMXSprite? {
        
        if inTeam != RMXSprite.TEAMLESS_MAVERICS && inTeam == notInTeam { return nil }
        
        let players = world.liveTeamPlayers.filter({(player)-> Bool in
            return ( inTeam == RMXSprite.TEAMLESS_MAVERICS || player.attributes.teamID == inTeam ) && ( notInTeam == RMXSprite.TEAMLESS_MAVERICS || player.attributes.teamID != inTeam )
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
    
    
    
    
    
    static func addRandomMovement(to players: [RMXSprite]) {
        for sprite in players {
            if Int(sprite.attributes.teamID) ?? 1 >= 0 && sprite.type == .AI && !sprite.isUnique {
                sprite.aiDelegate = AiRandom(sprite: sprite)
            }
        }
        
    }

    
    
    
    static func offenciveBehaviour(to players: [RMXSprite]) {
        for sprite in players {
            if sprite.type == .AI && !sprite.isUnique && Int(sprite.attributes.teamID) ?? 1 > 0 {
                sprite.aiDelegate = AiTeamPlayer(sprite: sprite)
            }
        }
        
    }


}