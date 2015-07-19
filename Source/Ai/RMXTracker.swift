//
//  RMXTracker.swift
//  AiScene
//
//  Created by Max Bilbow on 27/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit
//import RMXKit

class RMXTracker : NSObject {
    
    var rmxID: Int? {
        return self.sprite.rmxID
    }
    
    var sprite: RMXNode
//    var hitTarget = false
    private var _target: RMXNode?
    var target: RMXNode? {
        return self.isActive ? _target : nil
    }
    
    var hasTarget: Bool {
        return _target != nil
    }
    
    private var doOnArrival:((target: RMXNode?)->())?
    
    var isAi: Bool {
        return self.sprite.type == .AI
    }
    
    init(sprite: RMXNode) {
        self.sprite = sprite
        super.init()
        sprite.scene.collisionTrackers.append(self)
    }
    
    var isActive = true
//    var itemToWatch: RMXSprite! = nil
    var timePassed = 0
    
    let updateInterval = 1
    
    var lastPosition: SCNVector3 = SCNVector3Zero

    var isStuck: Bool {
        if self.hasTarget {
            return self.sprite.distanceToPoint(self.lastPosition) < 0.5// && self.sprite.distanceTo(target!.position) >= self.sprite.radius * target!.radius + 5
        } else {
            return false
        }
    }

//    func removeTarget() {
//        if self.isProjectile {
//            self.sprite.isLocked = false
//        }
//        self.sprite.stopFollowing(self.target)
//        self.setTarget(nil)
//    }
    
    var isProjectile = false

    var speed: RMFloat = 0

    
    func setTarget(target: RMXNode?, speed: RMFloat? = nil, afterTime limit: Int = 0, willJump: Bool = false, impulse: Bool = false, asProjectile: Bool = false, doOnArrival: ((target: RMXNode?) -> ())? = nil) -> Bool {
//        let oldTarget = self.target// ; let newTarget = target

        if let target = target {
            if target.rmxID == self.sprite.rmxID {
                self._target = nil
                return false
            }
        
            
            self.doesJump = willJump
            self._limit = limit
            self._count = 0
            self._target = target
            self.isProjectile = asProjectile
            self.impulse = impulse
            
        
            self.speed = (speed ?? 1 ) * self.sprite.speed // / self.sprite.mass + 1)
            
            
            if self.impulse {
                self.speed *= 100 / (1 + RMFloat(self.sprite.physicsBody?.mass ?? 0))
                if self.sprite.isLocalPlayer {
                    RMLog("Implse: \(speed), actual \(self.speed), mass: \(self.sprite.physicsBody?.mass)")
                }
            } else if self.sprite.isLocalPlayer {
                    RMLog("Speed: \(speed), actual \(self.speed), mass: \(self.sprite.physicsBody?.mass)")
            }
            
            
            
            self.doOnArrival = doOnArrival

            if asProjectile { //if holming missile with timer, do not let interferrence
                self.sprite.isLocked = true
                if limit <= 0 {
                    self._limit = 100
                }
            }
        }
        return self.hasTarget
    }
    
    internal func didReachTarget(target: RMXNode?) -> Bool {
        if self.hasTarget {
            if self.isProjectile { //if holming missile with timer, do not let interferrence
                self.sprite.isLocked = false
            }
            self._target = nil
            self.doOnArrival?(target: target)
            return true
        } else {
            return false
        }
    }
    private var _count: Int = 0 ; private var _limit: Int = 0
   
    
    @available(OSX 10.10, *)
    func checkForCollision(contact: SCNPhysicsContact) -> Bool {
        if let target = self.target {
            return (contact.getDefender(forChallenger: self.sprite) as? RMXNode)?.rmxID == target.rmxID && self.didReachTarget(target)
        }
        return false
    }
    
    var impulse = false
    var doesJump = true
    
    var world: RMXScene {
        return self.sprite.scene
    }
    
    func abort() {
        self.doOnArrival = nil
        self.didReachTarget(self.target)
    }
    
    func headToTarget(node: AnyObject!) -> Void {
       
        if !self.world.aiOn {
            if self.isAi {
                return
            } else if self.sprite.holder?.type != .PLAYER {
//                self.sprite.isLocked = false
                self.sprite.holder?.releaseItem()
            }
        }
        let isStuck = self.isStuck
        self.lastPosition = self.sprite.getPosition()
        if let target = self.target {
            if !target.attributes.isAlive && !self.isProjectile {
                self.abort()
            }
            if _limit > 0 && _count > _limit {
                self.didReachTarget(self.target)
                _count = 0
            } else {
                ++_count
                let direction = (target.getPosition() - self.sprite.getPosition()).normalized
               
                self.sprite.applyForce(direction * self.speed, atPosition: self.isProjectile ? SCNVector3Zero : self.sprite.front,  impulse: self.impulse)
                if self.doesJump && isStuck {
                    self.sprite.jump()
                }
                
            }
        }
    }

}