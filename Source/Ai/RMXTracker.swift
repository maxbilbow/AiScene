//
//  RMXTracker.swift
//  AiScene
//
//  Created by Max Bilbow on 27/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit


class RMXTracker : NSObject {
    
    var rmxID: Int? {
        return self.sprite.rmxID
    }
    
    var sprite: RMXSprite
//    var hitTarget = false
    private var _target: RMXSprite?
    var target: RMXSprite? {
        return self.isActive ? _target : nil
    }
    
    var hasTarget: Bool {
        return _target != nil
    }
    
    var doOnArrival:((target: RMXSprite?)->())?
    
    var isAi: Bool {
        return self.sprite.type == .AI
    }
    
    init(sprite: RMXSprite) {
        self.sprite = sprite
        super.init()
        self.sprite.world.interface.collider.trackers.append(self)
    }
    
    static let IDLE = "Idle"
    
    var isActive = true
//    var itemToWatch: RMXSprite! = nil
    var timePassed = 0
    var state: String = IDLE
    
    let updateInterval = 1
    var lastPosition: RMXVector = RMXVector3Zero

    var isStuck: Bool {
        if self.hasTarget {
            return self.sprite.distanceTo(self.lastPosition) < 0.5// && self.sprite.distanceTo(target!.position) >= self.sprite.radius * target!.radius + 5
        } else {
            return false
        }
    }

    func removeTarget() {
        if self.isProjectile {
            self.sprite.isLocked = false
        }
        self.sprite.stopFollowing(self.target)
        self.setTarget(nil)
    }
    
    var isProjectile = false

    var speed: RMFloatB = 0

    
    func setTarget(target: RMXSprite?, speed: RMFloatB? = nil, afterTime limit: Int = 0, willJump: Bool = false, impulse: Bool = false, asProjectile: Bool = false, ignoreClaims: Bool = false, doOnArrival: ((target: RMXSprite?) -> ())? = nil) {
       
        if target != nil && target! == self.sprite {
//            self.setTarget(nil)
            return
        }
        
        if !self.sprite.isActiveSprite {
            if target != nil && !ignoreClaims && target!.hasFollowers {
                if  !asProjectile {
                    return
                }
            }
        }
        
        self.sprite.follow(target)
        
        self.doesJump = willJump
        self._limit = limit
        self._count = 0
        self._target = target
        self.isProjectile = asProjectile
        self.impulse = impulse
        
    
        self.speed = (speed ?? 1 ) * self.sprite.speed // / self.sprite.mass + 1)
        
        
        if self.impulse {
            self.speed *= 100 / (self.sprite.mass + 1)
            if self.sprite.isActiveSprite {
                NSLog("Implse: \(speed), actual \(self.speed), mass: \(self.sprite.mass)")
            }
        } else if self.sprite.isActiveSprite {
                NSLog("Speed: \(speed), actual \(self.speed), mass: \(self.sprite.mass)")
            }
        
        
//        NSLog("speed \(self.speed) mass: \(self.sprite.mass)")
        func doa(target: RMXSprite?) {
            if limit > 0 && asProjectile { //if holming missile with timer, do not let interferrence
                self.sprite.isLocked = false
            }
            doOnArrival?(target: target)
        }
        
        self.doOnArrival = doa

        if asProjectile { //if holming missile with timer, do not let interferrence
            self.sprite.isLocked = true
            if limit <= 0 {
                self._limit = 100
            }
        }
    }
    
    private var _count: Int = 0 ; private var _limit: Int = 0
   
    
    func checkForCollision(contact: SCNPhysicsContact) -> Bool {
        if let target = self.target {
            if contact.getDefender(forChallenger: self.sprite).rmxID == target.rmxID {
                self.doOnArrival?(target: target)
                self.removeTarget()
                return true
            }
        }
        return false
    }
    var impulse = false
    var doesJump = true
    
    var world: RMSWorld {
        return self.sprite.world
    }
    
    internal func headToTarget() {
       
        if !self.world.aiOn {
            if self.isAi {
                return
            } else if self.sprite.holder?.type != .PLAYER {
//                self.sprite.isLocked = false
                self.sprite.holder?.releaseItem()
            }
        }
        let isStuck = self.isStuck
        self.lastPosition = self.sprite.position
        if let target = self.target {
            if _limit > 0 && _count > _limit {
                self.doOnArrival?(target: self.target)
                _count = 0
            } else {
                ++_count
                let direction = RMXVector3Normalize(target.position - self.sprite.position)
               
                self.sprite.applyForce(direction * self.speed, atPosition: self.isProjectile ? RMXVector3Zero : self.sprite.front,  impulse: self.impulse)
                if self.doesJump && isStuck {
                    self.sprite.jump()
                }
                
            }
        }
    }

}