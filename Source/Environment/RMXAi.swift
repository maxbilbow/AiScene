//
//  RMXAi.swift
//  AiScene
//
//  Created by Max Bilbow on 19/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import SceneKit
import Foundation
//import RMXKit



@available(OSX 10.9, *)
class AiPoppy : RMXAi {
    enum PoppyState { //: AiState {
        case Idle, ChasingBall, ExpectingBallToBeThrown, BringingBallBack
    }
    
//    var state: AiState = PoppyState.Idle
    
    var sprite: RMXNode {
        return self.pawn as! RMXNode
    }
    
    var itemToWatch: SCNNode?
    var speed: RMFloat {
        return self.sprite.speed
    }
    
    override var args: [RMXSpriteType] {
        return [RMXSpriteType.PLAYER, RMXSpriteType.AI]
    }
    //        poppy.world?.interface.collider.trackers.append(poppy.tracker)
    private var _count: Int = 0; private let _limit = 100

    var master: RMXNode!
    
    convenience init(poppy: RMXNode, master: RMXNode){
        self.init(pawn: poppy)
        self.master = master
    }
    required override init(pawn: RMXPawn) {
        self.master = (pawn as! RMXNode).scene.activeSprite
        super.init(pawn: pawn)
    }
    
    
    
    override func run(sender: AnyObject?, updateAtTime time: NSTimeInterval) -> Void {
        super.run(sender, updateAtTime: time)
        if self.master.isHoldingItem && self.master.item?.rmxID != self.sprite.rmxID {
            self.sprite.releaseItem()
            self.itemToWatch = self.master.item
            self.sprite.tracker.setTarget(self.itemToWatch?.rmxNode, doOnArrival: { (target) -> () in
                if self.master.item?.rmxID != target?.rmxID {
                    RMSoundBox.current.playSound("pop1", info: self.sprite)
                    ++self._count
                    if self._count > self._limit {
                        if self.master.isLocalPlayer {
                            repeat {
                                self.master = self.getTarget() as? RMXNode
                            } while self.master.rmxID == self.sprite.rmxID
                        } else {
                            self.master = self.sprite.scene.activeSprite
                        }
                        self.sprite.tracker.setTarget(self.master)
                        self._count = 0
                    }
                } else {
                    self._count = 0
                    self.sprite.grabItem(target)
                    self.sprite.tracker.setTarget(self.master, doOnArrival: { (target) -> () in
                        RMSoundBox.current.playSound("pop2", info: self.sprite)
                        self.sprite.releaseItem()
                        
                    })
                }
                
            })
        }
        if self.sprite.isLocked {
            self.master = self.sprite.scene.activeSprite
        }

    }
}

@available(OSX 10.10, *)
class AiRandom: RMXAi {
    var sprite: RMXNode {
        return self.pawn as! RMXNode
    }
//    override var state: AiState? {
//        return super.state
//    }
    
    override var args: [RMXSpriteType] {
        return [ RMXSpriteType.PLAYER, RMXSpriteType.AI ]
    }

    override func run(sender: AnyObject?, updateAtTime time: NSTimeInterval) -> Void {
        super.run(sender, updateAtTime: time)
        if !self.world.aiOn { return }
        if self.sprite.isHoldingItem && !self.sprite.tracker.hasTarget {
            self.sprite.tracker.setTarget(self.getTarget() as? RMXNode, willJump: true, afterTime: 100, doOnArrival: { (target) -> () in
                if !self.sprite.throwItem(at: target, withForce: 1, tracking: true) {
                    self.sprite.throwItem(at: target, withForce: 1, tracking: false)
                }
            })
        }
        if !self.sprite.isHoldingItem && !self.sprite.tracker.hasTarget { //after time to prevent grabbing (ish)
            let target = self.getTarget(RMXSpriteType.PASSIVE) as? RMXNode
            self.sprite.tracker.setTarget(target, willJump: true, afterTime: 100, doOnArrival: { (target: RMXNode?) -> () in
                if self.sprite.grabItem(target) {
                    self.sprite.tracker.setTarget(self.getTarget() as? RMXNode, willJump: true, afterTime: 100, doOnArrival: { (target) -> () in
                        if !self.sprite.throwItem(at: target, withForce: 1, tracking: true) {
                            self.sprite.throwItem(at: target, withForce: 1, tracking: false)
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
    required override init(pawn: RMXPawn) {
        super.init(pawn: pawn)
        let pawn = pawn as! RMXNode
        self.inWhichTeams = InWhichTeams(exc: self.sprite.attributes.teamID)
        pawn.attributes.addObserver(self, forKeyPath: "teamID", options: NSKeyValueObservingOptions.New, context: UnsafeMutablePointer<Void>())
        pawn.attributes.addObserver(self, forKeyPath: "isAlive", options: NSKeyValueObservingOptions.New, context: UnsafeMutablePointer<Void>())
//        self.pawn.timer.addTimer(interval: 1, target: self, selector: "checkTeam", repeats: true)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let keyPath = keyPath {
            switch keyPath {
            case "teamID":
                RMLog("\(self.pawn.name!)'s team did change from \(self.inWhichTeams.exc[0]) to \((object as! SpriteAttributes).teamID)", id: "Observers")
                self.inWhichTeams.exc[0] = self.sprite.attributes.teamID
                break
            case "isAlive":
                if (object as? SpriteAttributes)!.isAlive ?? false {
                    RMLog("\(self.sprite.name!) was revived!", id: "Observers")
                } else {
                    //self.sprite.timer?.addTimer(5, target: self.sprite.attributes, selector: "deRetire", repeats: false)
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

    
    func getTargetPlayer(args: InWhichTeams...) -> RMXPawn? {
        for condition in args {
            let players = self.sprite.scene.liveTeamPlayers.filter({(player)-> Bool in
                for teamID in condition.exc { //exclude team if...
                    if teamID == player.attributes.teamID || player.rmxID == self.sprite.rmxID {
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



//@available(OSX 10.9, *)
extension RMXAi {
//    static var autoStabilise: Bool = true
    class func autoStablise(sprite: RMXNode) {
        if sprite.isActor {
            var scalar: RMFloat = 1
            if #available(OSX 10.11, iOS 9.0, *) {
                sprite.physicsBody?.affectedByGravity = false
                for node in sprite.childNodes {
                    node.physicsBody?.affectedByGravity = false
                }
                scalar = 2
            } else {
                scalar = 1
            }
        let ai = { (node: AnyObject!) -> Void in
//            if sprite.world.aiOn { NSLog(sprite.name) }
            if sprite.scene.hasGravity {
                sprite.physicsBody?.applyForce(sprite.scene.gravity * RMFloat(sprite.physicsBody!.mass) * scalar, atPosition: sprite.bottom, impulse: false)
//                if sprite.isLocalPlayer {
//                    print("height: \(sprite.height.print), g: \(sprite.scene.gravity.print), Bottom: \(sprite.bottom.print), Top: \(sprite.top.print)")
//                }
            }
        }
        sprite.addBehaviour(ai)
        }
        
    }

    
    @available(*,deprecated=0)
    static var randomTimeInterval: Int {
        return  random() % 600 + 100
    }
    

    class func selectTargetPlayer(inWorld world: RMXWorld, inTeam: String = RMXNode.TEAMLESS_MAVERICS, notInTeam: String = RMXNode.TEAMLESS_MAVERICS) -> RMXNode? {
        
        if inTeam != RMXNode.TEAMLESS_MAVERICS && inTeam == notInTeam { return nil }
        
        let players = (world as! RMXScene).liveTeamPlayers.filter({(player)-> Bool in
            return ( inTeam == RMXNode.TEAMLESS_MAVERICS || player.attributes.teamID == inTeam ) && ( notInTeam == RMXNode.TEAMLESS_MAVERICS || player.attributes.teamID != inTeam )
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
    
    
    
    
    
    static func addRandomMovement(to players: [RMXNode]) {
        for sprite in players {
            if Int(sprite.attributes.teamID) ?? 1 >= 0 && sprite.type == .AI && !sprite.isUnique {
                sprite.aiDelegate = AiRandom(pawn: sprite)
            }
        }
        
    }

    
    
    
    static func offenciveBehaviour(to players: [RMXNode]) {
        for sprite in players {
            if sprite.type == .AI && !sprite.isUnique && Int(sprite.attributes.teamID) ?? 1 > 0 {
                sprite.aiDelegate = AiTeamPlayer(pawn: sprite)
            }
        }
        
    }


}