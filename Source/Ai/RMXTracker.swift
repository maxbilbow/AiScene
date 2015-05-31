//
//  RMXTracker.swift
//  AiScene
//
//  Created by Max Bilbow on 27/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit


class RMXTracker {
    
    var rmxID: Int {
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
    
    var doOnArrival, doOnLeave, doWhileTouching: ((target: RMXSprite?)->())?
    
    var isAi: Bool = false
    
    init(sprite: RMXSprite) {
        self.isAi = sprite.type == .AI
        self.sprite = sprite
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

    var isProjectile = false
    func setTarget(target: RMXSprite? = nil, var speed: RMFloatB? = nil, afterTime limit: Int = 0, willJump: Bool = false, impulse: Bool = false, asProjectile: Bool = false, doOnArrival: ((target: RMXSprite?) -> ())? = nil) {
        if target != nil && target! == self.sprite {
            self.setTarget()
            return
        }
        self.doesJump = willJump
        self.impulse = impulse
        _limit = limit
        _count = 0
        _target = target
        self.isProjectile = asProjectile
    
        let oldSpeed = self.sprite.speed
        if impulse && speed == nil {
            speed = oldSpeed / self.sprite.mass
        } else if speed == nil {
            speed = oldSpeed
        } 
        
        func doa(target: RMXSprite?) {
            doOnArrival?(target: target)
            self.sprite.setSpeed(speed: oldSpeed)
            self.sprite.isLocked = false
        }
        
        self.sprite.setSpeed(speed: speed)
        
        self.doOnArrival = doa
        
        if limit > 0 && asProjectile { //if holming missile with timer, do not let interferrence
            self.sprite.isLocked = true
        }
    }
    
    private var _count: Int = 0 ; private var _limit: Int = 0
   
    
    func checkForCollision(contact: SCNPhysicsContact) -> Bool {
        if let target = self.target {
            if contact.nodeA == self.sprite.node || contact.nodeB == self.sprite.node || contact.nodeB == self.sprite.item?.node || contact.nodeA == self.sprite.item?.node {
                if target.rmxID == self.sprite.rmxID || contact.nodeB == target.node || contact.nodeA == target.node {
                    self.doOnArrival?(target: target)
                    return true
                }
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
        if !self.world.aiOn && self.isAi { return }
        if let target = self.target {
            if _limit > 0 && _count > _limit {
                self.doOnArrival?(target: self.target)
                _count = 0
            } else {
                ++_count
                let direction = RMXVector3Normalize(target.position - self.sprite.position)
                self.sprite.applyForce(direction * self.sprite.speed, atPosition: self.isProjectile ? RMXVector3Zero : self.sprite.front,  impulse: self.impulse)
                if self.doesJump && self.isStuck {
                    self.lastPosition = self.sprite.position
                    self.sprite.jump()
                    
                } else {
                    self.lastPosition = self.sprite.position
                }
                
            }
        }
    }

}